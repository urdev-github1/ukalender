import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../utils/event_storage_firestore.dart';
import '../utils/event_storage_sqlite.dart';
import '../utils/notification_service.dart';

/// Events in Firestore + SQLite speichern
class EventStorage {
  // Instanz der Klasse EventStorageFirestore
  final EventStorageFirestore _firestoreStorage = EventStorageFirestore();
  // Instanz der Klasse EventStorageSQLite
  final EventStorageSQLite _sqliteStorage = EventStorageSQLite();
  // Instanz der Klasse NotificationService
  final NotificationService _notificationService = NotificationService();

  // Events speichern (Aufruf der Methode in 'add_event_dialog.dart')
  Future<void> saveEvent({
    required String title,
    required String body,
    required DateTime eventDateTime,
    DateTime? dayBefore,
    DateTime? twoHoursBefore,
    DateTime? thirtyMinutesBefore,
    List<int>? notificationIds,
  }) async {
    // Gemeinsame ID für Firestore + SQLite generieren
    final String eventId = const Uuid().v4();

    // Speichern in Firestore über die Klasse EventStorageFirestore
    await _firestoreStorage.saveEventToFirestore(
      id: eventId,
      title: title,
      body: body,
      eventDateTime: eventDateTime,
      dayBefore: dayBefore,
      twoHoursBefore: twoHoursBefore,
      thirtyMinutesBefore: thirtyMinutesBefore,
      notificationIds: notificationIds,
    );
    // Speichern in SQLite über die Klasse EventStorageSQLite
    await _sqliteStorage.saveEventToSQLite(
      id: eventId,
      title: title,
      body: body,
      eventDateTime: eventDateTime,
      dayBefore: dayBefore,
      twoHoursBefore: twoHoursBefore,
      thirtyMinutesBefore: thirtyMinutesBefore,
      notificationIds: notificationIds,
    );
  }

  /// Hilfsmethode zum Parsen von ISO-8601-Daten
  DateTime? _parseIso8601(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print("Ungültiges Datumsformat: $value");
      }
    }
    return null;
  }

  // Notification reaktivieren
  Future<void> restoreNotifications(String eventId) async {
    // Event-Daten abrufen
    final event = await _firestoreStorage.getEventById(eventId);

    if (event == null) {
      print("Event nicht gefunden.");
      return;
    }

    // Daten des Events extrahieren
    final String title = event['title'] ?? "Ohne Titel";
    final String body = event['body'] ?? "Ohne Beschreibung";
    final List<int> notificationIds =
        (event['notificationIds'] as List<dynamic>?)?.cast<int>() ?? [];
    final List<DateTime?> notificationTimes = [
      _parseIso8601(event['dayBefore']),
      _parseIso8601(event['twoHoursBefore']),
      _parseIso8601(event['thirtyMinutesBefore']),
    ];

    if (notificationIds.isEmpty ||
        notificationTimes.every((time) => time == null)) {
      print("Keine Benachrichtigungsdaten vorhanden.");
      return;
    }

    // Notifications reaktivieren
    for (int i = 0; i < notificationIds.length; i++) {
      if (i < notificationTimes.length) {
        final notificationId = notificationIds[i];
        final scheduledTime = notificationTimes[i];

        if (scheduledTime != null) {
          await _notificationService.reactivateNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledTime: scheduledTime,
          );
        } else {
          print("Keine gültige Zeit für Notification ID $notificationId.");
        }
      } else {
        print(
            "Keine zugeordnete Zeit für Notification ID ${notificationIds[i]}.");
      }
    }
  }
}
