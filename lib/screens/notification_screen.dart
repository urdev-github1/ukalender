import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/notification_service.dart';
import '../utils/event_storage.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<PendingNotificationRequest>> _pendingNotifications;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  void _loadPendingNotifications() {
    _pendingNotifications = _notificationService.getPendingNotifications();
  }

  /// Temporär entfernt!
  // // Funktion zum Löschen einer Benachrichtigung
  // Future<void> _removeNotification(int id) async {
  //   await _notificationService.removeNotification(id);
  //   setState(() {
  //     _loadPendingNotifications(); // Liste neu laden nach dem Löschen
  //   });
  // }

  // Sicherheitsabfrage vor dem Löschen der Notifications
  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instanz von EventStorage
    final eventStorage = EventStorage();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 128, 166, 175),
      appBar: AppBar(
          title: const Text(
            'Aktivierte Erinnerungen',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 128, 166, 175),
          actions: <Widget>[
            // Alte Notifications löschen
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                iconColor: Colors.black,
                itemBuilder: (context) => [
                      // Die Menüeinträge des Popup-Menüs
                      const PopupMenuItem(
                        value: 'deleteNotification',
                        child: Text('Alte Benachrichtigungen löschen'),
                      ),
                      // Alle Notifications löschen
                      const PopupMenuItem(
                        value: 'deleteAllNotifications',
                        child: Text(
                          'Alle Benachrichtigungen löschen',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                // Der Callback, der ausgeführt wird, wenn ein Menüeintrag ausgewählt wird
                onSelected: (value) async {
                  //
                  if (value == 'deleteNotification') {
                    final now = DateTime.now();
                    final snapshot = await eventStorage.getEventStream().first;

                    // Prüfen, ob Daten geladen sind
                    if (snapshot.docs.isNotEmpty) {
                      for (var doc in snapshot.docs) {
                        final eventData = doc.data() as Map<String, dynamic>;
                        final eventTime = eventData['eventTime'] != null
                            ? DateTime.parse(eventData['eventTime'])
                            : null;

                        // Wenn das Event in der Vergangenheit liegt
                        if (eventTime != null && eventTime.isBefore(now)) {
                          final notificationIds =
                              eventData['notificationIds'] as List<dynamic>?;
                          // Überprüfen, ob notificationIds vorhanden sind
                          if (notificationIds != null) {
                            for (var id in notificationIds) {
                              if (id is int) {
                                // Benachrichtigung mit der entsprechenden ID entfernen
                                await NotificationService()
                                    .removeNotification(id);
                              }
                            }
                          }
                        }
                      }
                    }
                    // Überprüfen, ob der BuildContext immer noch gültig ist
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Alte Benachrichtigungen wurden gelöscht!')),
                      );
                    }
                  } else if (value == 'deleteAllNotifications') {
                    // Sicherheitsabfrage für alle Benachrichtigungen
                    final confirm = await _showConfirmationDialog(
                      context,
                      title: 'Bestätigung erforderlich',
                      content:
                          'Sollen alle Benachrichtigungen gelöscht werden?',
                    );
                    if (confirm == true) {
                      // Alle Benachrichtigungen löschen
                      await _notificationService.removeAllNotifications();
                      setState(() {
                        _loadPendingNotifications(); // Liste aktualisieren
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Keine Events gefunden.')),
                        );
                      }
                    }
                  }
                }),
          ]),

      // Der `body`-Parameter wird mit einem `FutureBuilder` gesetzt, der auf eine Future wartet,
      // die eine Liste von `PendingNotificationRequest`-Objekten zurückgibt.
      body: FutureBuilder<List<PendingNotificationRequest>>(
        // Die Future, auf die gewartet wird, wird hier gesetzt.
        future: _pendingNotifications,
        // Der `builder`-Callback wird aufgerufen, sobald der Zustand der Future sich ändert.
        builder: (context, snapshot) {
          // Wenn die Future noch nicht abgeschlossen ist (wird gerade geladen),
          // wird ein `CircularProgressIndicator` angezeigt.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Fehler beim Laden der Benachrichtigungen'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Keine ausstehenden Benachrichtigungen'));
            // Falls die Future erfolgreich abgeschlossen wurde und Daten zurückgegeben hat,
            // wird eine `ListView` mit den Benachrichtigungen angezeigt.
          } else {
            List<PendingNotificationRequest> notifications = snapshot.data!;
            // 'ListView.builder' wird verwendet, um eine scrollbare Liste zu erstellen.
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                // Ein `ListTile` wird für jedes Benachrichtigungsobjekt erstellt.
                return ListTile(
                  title: Text(
                    '${notifications[index].id}: ${notifications[index].title}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  subtitle: Text(
                    '${notifications[index].body}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),

                  /// Temporär entfernt!
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.black38),
                  //   onPressed: () =>
                  //       _removeNotification(notifications[index].id),
                  // ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../utils/notification_service.dart';

// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   // Holt alle ausstehenden Benachrichtigungen
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     final NotificationService notificationService = NotificationService();
//     return await notificationService.getPendingNotifications();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ausstehende Benachrichtigungen'),
//       ),
//       body: FutureBuilder<List<PendingNotificationRequest>>(
//         future: getPendingNotifications(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return const Center(
//                 child: Text('Fehler beim Laden der Benachrichtigungen'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//                 child: Text('Keine ausstehenden Benachrichtigungen'));
//           } else {
//             List<PendingNotificationRequest> notifications = snapshot.data!;
//             return ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(notifications[index].title ?? 'Kein Titel'),
//                   subtitle: Text(notifications[index].body ?? 'Keine Details'),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../utils/database_helper.dart';
// import '../utils/notification_service.dart';
// import '../models/notification_model.dart';

// class NotificationScreen extends StatelessWidget {
//   final List<NotificationModel> notifications;

//   const NotificationScreen({super.key, required this.notifications});

//   // Auslesen der Notification (Erinnerungszeiten) aus der Datenbank
//   Future<void> getAllNotificationFromDb() async {
//     final db = DatabaseHelper.instance;
//     final notifications = await db.getNotifications();

//     for (var notification in notifications) {
//       if (notification.id == null) {
//         //print('Fehler: Benachrichtigung hat keine ID.');
//         continue; // Überspringt Benachrichtigungen ohne ID
//       }

//       // Plant die Notifications neu
//       await NotificationService.scheduleNotification(
//         notification.id!, // Die ID ist hier sicher nicht null
//         notification.title,
//         'Erinnerung an ein bevorstehendes Event!',
//         notification.notificationTime,
//         'msdeveloper@gmx.net',
//       );
//     }
//   }

//   // Löscht alle Notifications und Datenbankinhalte
//   Future<void> deleteAllNotifications() async {
//     await NotificationService().cancelAllNotifications();
//     //await DatabaseService.instance.remove();
//   }

//   //
//   String formatNotificationTime(DateTime notificationTime) {
//     return DateFormat('dd.MM.yyyy \'um\' HH:mm \'Uhr\'')
//         .format(notificationTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Benachrichtigungen'),
//         backgroundColor: Colors.orange,
//       ),
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // Button zum Wiederherstellen aller Notifications
//               ElevatedButton(
//                   onPressed: () async {
//                     await NotificationService().cancelAllNotifications();
//                     await getAllNotificationFromDb(); // Auslesen der Erinnerungszeiten aus der DB
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                           content: Text('Die Notification wurden aktiviert')));
//                     }
//                   },
//                   child: const Text('Restore Notification')),
//               // Button zum Löschen aller Notifications und Datenbankinhalte
//               ElevatedButton(
//                 onPressed: () async {
//                   if (await showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Achtung!'),
//                       content: const Text('Bist du wirklich sicher?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.of(context).pop(false),
//                           child: const Text('Nein'),
//                         ),
//                         TextButton(
//                           onPressed: () => Navigator.of(context).pop(true),
//                           child: const Text('Ja'),
//                         ),
//                       ],
//                     ),
//                   )) {
//                     await deleteAllNotifications();
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                           content: Text('ALLE DATEN WURDEN GELÖSCHT!')));
//                     }
//                   }
//                 },
//                 child: const Text('DELETE ALL'),
//               )
//             ],
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 final alarmNumber =
//                     (index % 3) + 1; // Numbering each alarm from 1 to 3
//                 return ListTile(
//                   title: Text(notification.title),
//                   subtitle: Text(
//                     '$alarmNumber. Alarm: ${formatNotificationTime(notification.notificationTime)}',
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
