import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/event_storage_firestore.dart';
import '../utils/notification_service.dart';

/// Alle Notification
class NotificationRestorationService {
  final EventStorageFirestore eventStorageFirestore;
  final NotificationService notificationService;

  // Konstruktor
  NotificationRestorationService(
      this.eventStorageFirestore, this.notificationService);

  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  // Future<void> restoreDeletedNotifications() async {
  //   // Events aus der Datenbank abrufen
  //   final List<Event> events = await eventStorage.getAllEvents();

  //   for (final event in events) {
  //     // Notification-IDs und geplante Benachrichtigungszeiten überprüfen
  //     for (final notificationId in event.notificationIds) {
  //       // Prüfen, ob die Notification aktiv ist
  //       bool isNotificationActive =
  //           await notificationService.isNotificationScheduled(notificationId);

  //       if (!isNotificationActive) {
  //         // Benachrichtigung neu planen
  //         final DateTime? dayBefore = event.dayBefore;
  //         final DateTime? twoHoursBefore = event.twoHoursBefore;
  //         final DateTime? thirtyMinutesBefore = event.thirtyMinutesBefore;

  //         if (dayBefore != null) {
  //           notificationService.scheduleNotification(
  //             id: notificationId,
  //             title: '${event.title} (morgen)',
  //             body:
  //                 'Am ${_formatDate(event.eventDateTime)} um ${_formatTime(event.eventDateTime)} Uhr.',
  //             scheduledTime: dayBefore,
  //           );
  //         }

  //         if (twoHoursBefore != null) {
  //           notificationService.scheduleNotification(
  //             id: notificationId,
  //             title: event.title,
  //             body:
  //                 'Heute in 2 Std. um ${_formatTime(event.eventDateTime)} Uhr.',
  //             scheduledTime: twoHoursBefore,
  //           );
  //         }

  //         if (thirtyMinutesBefore != null) {
  //           notificationService.scheduleNotification(
  //             id: notificationId,
  //             title: event.title,
  //             body:
  //                 'Heute in 30 Min. um ${_formatTime(event.eventDateTime)} Uhr.',
  //             scheduledTime: thirtyMinutesBefore,
  //           );
  //         }
  //       }
  //     }
  //   }
  // }

// // Einzelne Notification
//   Future<void> restoreNotificationsForEvent(String eventId) async {
//     final EventFirestore? event = await eventStorageFirestore.getEventById(eventId);

//     if (event == null) {
//       throw Exception("Event mit ID $eventId nicht gefunden.");
//     }

//     for (final notificationId in event.notificationIds) {
//       bool isNotificationActive =
//           await notificationService.isNotificationScheduled(notificationId);

//       if (!isNotificationActive) {
//         if (event.dayBefore != null) {
//           notificationService.scheduleNotification(
//             id: notificationId,
//             title: '${event.title} (morgen)',
//             body:
//                 'Am ${_formatDate(event.eventDateTime)} um ${_formatTime(event.eventDateTime)} Uhr.',
//             scheduledTime: event.dayBefore!,
//           );
//         }
//         if (event.twoHoursBefore != null) {
//           notificationService.scheduleNotification(
//             id: notificationId,
//             title: event.title,
//             body: 'Heute in 2 Std. um ${_formatTime(event.eventDateTime)} Uhr.',
//             scheduledTime: event.twoHoursBefore!,
//           );
//         }
//         if (event.thirtyMinutesBefore != null) {
//           notificationService.scheduleNotification(
//             id: notificationId,
//             title: event.title,
//             body:
//                 'Heute in 30 Min. um ${_formatTime(event.eventDateTime)} Uhr.',
//             scheduledTime: event.thirtyMinutesBefore!,
//           );
//         }
//       }
//     }
//   }

  // 2. Version Einzelne Notification
  Future<void> restoreNotificationsForEvent(String eventId) async {
    try {
      // Event-Daten aus Firestore abrufen
      final eventData = await eventStorageFirestore.getEventById(eventId);

      if (eventData == null) {
        print("Event mit ID $eventId konnte nicht gefunden werden.");
        throw Exception("Event-Daten nicht verfügbar.");
      }

      // Event-Daten extrahieren
      final String title = eventData['title'];

      final DateTime eventDate = eventData['eventTime'] is Timestamp
          ? (eventData['eventTime'] as Timestamp).toDate()
          : DateTime.parse(eventData['eventTime'] as String);

      // Uhrzeit aus 'localTime' extrahieren und kombinieren
      final String localTime =
          eventData['localTime'] as String; // Format: "HH:mm"
      final int hour = int.parse(localTime.split(':')[0]);
      final int minute = int.parse(localTime.split(':')[1]);
      final DateTime eventTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
      );

      // Extrahierung der geplanten Benachrichtigungszeiten
      final DateTime? dayBefore = eventData['dayBefore'] != null
          ? _combineDateWithLocalTime(
              eventData['dayBefore'] is Timestamp
                  ? (eventData['dayBefore'] as Timestamp).toDate()
                  : DateTime.parse(eventData['dayBefore'] as String),
              localTime,
            )
          : null;

      final DateTime? twoHoursBefore = eventData['twoHoursBefore'] != null
          ? _combineDateWithLocalTime(
              eventData['twoHoursBefore'] is Timestamp
                  ? (eventData['twoHoursBefore'] as Timestamp).toDate()
                  : DateTime.parse(eventData['twoHoursBefore'] as String),
              localTime,
            )
          : null;

      final DateTime? thirtyMinutesBefore = eventData['thirtyMinutesBefore'] !=
              null
          ? _combineDateWithLocalTime(
              eventData['thirtyMinutesBefore'] is Timestamp
                  ? (eventData['thirtyMinutesBefore'] as Timestamp).toDate()
                  : DateTime.parse(eventData['thirtyMinutesBefore'] as String),
              localTime,
            )
          : null;

      // Benachrichtigungen erneut planen
      if (dayBefore != null && dayBefore.isAfter(DateTime.now())) {
        await notificationService.reactivateNotification(
          id: Random().nextInt(1000000), // Generiere neue ID
          title: '$title (morgen)',
          body:
              'Am ${_formatDate(eventTime)} um ${_formatTime(eventTime)} Uhr.',
          scheduledTime: dayBefore,
        );
      }

      if (twoHoursBefore != null && twoHoursBefore.isAfter(DateTime.now())) {
        await notificationService.reactivateNotification(
          id: Random().nextInt(1000000),
          title: title,
          body: 'Heute in 2 Std. um ${_formatTime(eventTime)} Uhr.',
          scheduledTime: twoHoursBefore,
        );
      }

      if (thirtyMinutesBefore != null &&
          thirtyMinutesBefore.isAfter(DateTime.now())) {
        await notificationService.reactivateNotification(
          id: Random().nextInt(1000000),
          title: title,
          body: 'Heute in 30 Min. um ${_formatTime(eventTime)} Uhr.',
          scheduledTime: thirtyMinutesBefore,
        );
      }

      print(
          "Benachrichtigungen für Event $eventId erfolgreich wiederhergestellt.");
    } catch (e) {
      print("Fehler beim Wiederherstellen der Benachrichtigungen: $e");
      rethrow;
    }
  }

// Helfermethode zur Kombination von Datum und Uhrzeit
  DateTime _combineDateWithLocalTime(DateTime date, String localTime) {
    try {
      final int hour = int.parse(localTime.split(':')[0]);
      final int minute = int.parse(localTime.split(':')[1]);
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      print("Fehler bei der Zeitkombination: $e");
      throw Exception("Ungültiges Zeitformat: $localTime");
    }
  }
}

// Formatierer für Datum
//String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

// Formatierer für Uhrzeit
//String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);
