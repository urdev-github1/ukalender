// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   // Instanz des lokalen Benachrichtigungsplugin
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // //
//   // static final DatabaseHelper dbHelper = DatabaseHelper();

//   //
//   static Future<void> onDidReceiveBackgroundNotificationResponse(
//       NotificationResponse notificationResponce) async {}

//   // Callback für im Vordergrund empfangene Benachrichtigungen.
//   static Future<void> onDidReceiveNotification(
//       BuildContext context, NotificationResponse notificationResponse) async {
//     if (notificationResponse.payload != null) {
//       // Zeigt eine Snackbar an, wenn eine Benachrichtigung empfangen wird
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Du hast eine Benachrichtigung: ${notificationResponse.payload}'),
//           duration: const Duration(seconds: 10),
//           action: SnackBarAction(
//             label: 'Schließen',
//             onPressed: () {
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//             },
//           ),
//         ),
//       );
//     }
//   }

//   // Initialisierung der Notification (Benachrichtigung)
//   static Future<void> init() async {
//     // Initialisierung der Android-Einstellungen
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // Initialisierung der iOS-Einstellungen
//     const DarwinInitializationSettings i0SInitializationSettings =
//         DarwinInitializationSettings();

//     // Kombination der Initialisierungseinstellungen von Android und iOS
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: androidInitializationSettings,
//       iOS: i0SInitializationSettings,
//     );

//     // Initialisierung des Plugins
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveBackgroundNotificationResponse:
//           onDidReceiveBackgroundNotificationResponse,
//       onDidReceiveNotificationResponse:
//           onDidReceiveBackgroundNotificationResponse,
//     );

//     // Erlaubnis zum Anzeigen von Benachrichtigungen auf Android anfordern
//     await flutterLocalNotificationsPlugin
//         // Ruft die plattformspezifische Implementierung des Plugins ab.
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         // Fordert Berechtigungen für die Benachrichtigungen auf Android an.
//         ?.requestNotificationsPermission();
//   }

//   // *** Showing an Instant Notification ***

//   // Anzeige einer sofortigen Benachrichtigung
//   static Future<void> showInstantNotification(String title, String body) async {
//     // Die Details der Benachrichtigung festlegen
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       // ID, Kanalname, Wichtigkeit, Priorität, Icon
//       android: AndroidNotificationDetails(
//         'Calendar',
//         'Calendar_App',
//         importance: Importance.max,
//         priority: Priority.max,
//         enableVibration: false, // Vibration deaktivieren
//         // Pfad zum kleinen Icon festlegen.
//         icon: '@mipmap/ic_launcher',
//       ),
//       // Standard-Benachrichtigungs-Details für iOS.
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     // Die Benachrichtigung anzeigen
//     await flutterLocalNotificationsPlugin.show(
//       10, // Eindeutige ID für die Benachrichtigung.
//       title, // Titel der Benachrichtigung.
//       body, // Beschreibung der Benachrichtigung.
//       platformChannelSpecifics, // Plattformspezifischen Benachrichtigungs-Details.
//       //payload: 'instant_notification'
//     );
//   }

//   // *** Showing Scheduling a Notification ***

//   // Anzeige einer geplanten Benachrichtigung (Titel, Inhalt, Zeitpkt. der Benachrichtigung)
//   static Future<void> scheduleNotification(int id, String title, String body,
//       DateTime scheduledDateTime, String recipientEmail) async {
//     try {
//       // Details der Benachrichtigung definieren
//       const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         // ID, Kanalname, Wichtigkeit, Priorität, Icon
//         android: AndroidNotificationDetails(
//           'Calendar',
//           'Calendar_App',
//           importance: Importance.max,
//           priority: Priority.max,
//           enableVibration: false, // Vibration deaktivieren
//           // Pfad zum kleinen Icon festlegen.
//           icon: '@mipmap/ic_launcher',
//         ),
//         // Standard-Benachrichtigungs-Details für iOS.
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       );

//       // Plant die Benachrichtigung mit Berücksichtigung der Zeitzone.
//       //print('Scheduling notification...');
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         id, // Eindeutige ID für die Benachrichtigung.
//         title, // Titel der Benachrichtigung.
//         body, // Beschreibung der Benachrichtigung.
//         // Konvertiert in die lokale Zeitzone
//         tz.TZDateTime.from(scheduledDateTime, tz.local),
//         platformChannelSpecifics,
//         // Interpretiert das geplante Datum als absoluten Zeitpunkt.
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         // Berücksichtigt bei der Planung sowohl das Datum als auch die Uhrzeit.
//         matchDateTimeComponents: DateTimeComponents.dateAndTime,
//         //payload: body, // Sendet den Benachrichtigungstext als Payload
//       );

//       // Future<void> storePendingNotifications() async {
//       //   final List<PendingNotificationRequest> pendingNotifications =
//       //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();

//       //   if (pendingNotifications.isNotEmpty) {
//       //     for (var notification in pendingNotifications) {
//       //       NotificationModel notificationModel = NotificationModel(
//       //         id: notification.id,
//       //         title: notification.title ?? 'No Title',
//       //         body: notification.body,
//       //         notificationTime: notification.,
//       //       );
//       //       await dbHelper.add(notificationModel);
//       //     }
//       //   }
//       // }

//       // // Benachrichtigungen in die Datenbank schreiben.
//       // await insertNotificationToSqflite(id, title, body, scheduledDateTime);

//       //print('Sending email notification...');
//       // E-Mail-Benachrichtigung senden
//       // await NotificationService.sendEmailNotification(
//       //     title, body, recipientEmail);
//     } catch (e) {
//       //print('Error scheduling notification: $e');
//     }
//   }

//   // // Benachrichtigungen in die Datenbank schreiben.
//   // static Future<void> insertNotificationToSqflite(
//   //     id, title, scheduledDateTime) async {
//   //   print('Inserting notification into the database...');
//   //   final notification = NotificationModel(
//   //     eventId: id,
//   //     title: title,
//   //     body: body,
//   //     notificationTime: scheduledDateTime,
//   //   );
//   //   //await DatabaseService.instance.addNotification(notification);
//   //   print('Notification inserted into database.');
//   // }

//   // Stornierung aller Benachrichtigungen
//   Future<void> cancelAllNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }

//   // *** weitere Unterprogramme ***

//   // // E-Mail-Benachrichtigung senden
//   // static Future<void> sendEmailNotification(
//   //   String subject,
//   //   String body,
//   //   String recipientEmail,
//   // ) async {
//   //   // SMTP-Server für GMX (benötigt Zugriffsdaten)
//   //   final smtpServer = SmtpServer(
//   //     'mail.gmx.net',
//   //     port: 587,
//   //     ssl: false,
//   //     username: 'msdeveloper@gmx.net',
//   //     password: '@2018devUR',
//   //   );

//   //   // E-Mail Nachricht erstellen
//   //   final message = mail.Message()
//   //     ..from = const mail.Address('msdeveloper@gmx.net', 'Calendar App')
//   //     ..recipients.add(recipientEmail)
//   //     ..subject = subject
//   //     ..text = body;

//   //   try {
//   //     // Senden der Nachricht
//   //     await mail.send(message, smtpServer);
//   //     print('Email sent to $recipientEmail');
//   //   } on mail.MailerException catch (e) {
//   //     print('Error sending email: $e');
//   //     for (var p in e.problems) {
//   //       print('Problem: ${p.code}: ${p.msg}');
//   //     }
//   //   }
//   // }
// }
