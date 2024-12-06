import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/event_storage_firestore.dart';
import '../utils/notification_restoration_service.dart';
import '../utils/notification_service.dart';

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
    // Instanz von EventStorageFirestore
    final eventStorage = EventStorageFirestore();

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
                          content:
                              Text('Alte Benachrichtigungen wurden gelöscht!')),
                    );
                  }
                } else if (value == 'deleteAllNotifications') {
                  // Sicherheitsabfrage für alle Benachrichtigungen
                  final confirm = await _showConfirmationDialog(
                    context,
                    title: 'Bestätigung erforderlich',
                    content: 'Sollen alle Benachrichtigungen gelöscht werden?',
                  );
                  if (confirm == true) {
                    // Alle Benachrichtigungen löschen
                    await _notificationService.removeAllNotifications();
                    setState(() {
                      _loadPendingNotifications(); // Liste aktualisieren
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Keine Events gefunden.')),
                      );
                    }
                  }
                }
              }),
        ],
      ),

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
                );
              },
            );
          }
        },
      ),

      // Variante einzelne Notification reaktivieren
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ID des Events speichert, für das die Benachrichtigungen wiederhergestellt werden sollen.
          const String eventId = "QsqTxxuJ4SRyn7Igr8oQ";

          try {
            // Instanz des NotificationService
            final notificationService = NotificationService();
            // Instanz des NotificationRestorationService, der den EventStorage
            // und den NotificationService als Parameter verwendet
            final restorationService = NotificationRestorationService(
                eventStorage, notificationService);

            // Benachrichtigungen für ein einzelnes Event wieder herstellen
            await restorationService.restoreNotificationsForEvent(eventId);

            // Überprüft, ob der Context noch gültig ist
            if (context.mounted) {
              // SnackBar-Meldung
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Benachrichtigungen für das Event wiederhergestellt!'),
                ),
              );
            }
          } catch (e) {
            // Falls ein Fehler auftritt
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fehler: ${e.toString()}'),
                ),
              );
            }
          }
        },
        tooltip: 'Benachrichtigungen wiederherstellen',
        child: const Icon(Icons.restore),
      ),

      // // Variante alle Notification
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // Instanz von NotificationRestorationService
      //     final eventStorage = EventStorage();
      //     final notificationService = NotificationService();
      //     final restorationService =
      //         NotificationRestorationService(eventStorage, notificationService);

      //     // Benachrichtigungen für alle Events wiederherstellen
      //     await restorationService.restoreDeletedNotifications();

      //     // Feedback für den Benutzer
      //     if (context.mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text('Benachrichtigungen wiederhergestellt!'),
      //         ),
      //       );
      //     }
      //   },
      //   tooltip: 'Benachrichtigungen wiederherstellen',
      //   child: const Icon(Icons.restore),
      // ),

      // // Reaktivieren von Notification
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     const eventId = "wYSeCsgfPSh3CGXeNK3c";

      //     // Benachrichtigungen für das Event wiederherstellen
      //     await _eventStorage.restoreNotifications(eventId);

      //     // Feedback für den Benutzer
      //     if (context.mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //             content: Text('Benachrichtigungen wiederhergestellt!')),
      //       );
      //     }
      //   },
      //   tooltip: 'Benachrichtigungen wiederherstellen',
      //   child: const Icon(Icons.restore),
      // ),
    );
  }
}
