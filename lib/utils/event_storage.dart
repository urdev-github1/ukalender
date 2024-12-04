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

  Future<void> restoreNotifications(String eventId) async {
    // Event-Daten abrufen (z. B. aus Firestore oder SQLite)
    final event = await _firestoreStorage.getEventById(eventId);

    if (event == null) {
      print("Event nicht gefunden.");
      return;
    }

    // Daten des Events extrahieren
    final String title = event['title'];
    final String body = event['body'];
    final List<int> notificationIds = event['notificationIds'] ?? [];
    final List<DateTime?> notificationTimes = [
      event['dayBefore'],
      event['twoHoursBefore'],
      event['thirtyMinutesBefore']
    ];

    // Notifications reaktivieren
    for (int i = 0; i < notificationIds.length; i++) {
      final notificationId = notificationIds[i];
      final scheduledTime = notificationTimes[i];
      if (scheduledTime != null) {
        await _notificationService.reactivateNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
        );
      }
    }
  }
}
