import 'package:uuid/uuid.dart';
import '../utils/event_storage_firestore.dart';
import '../utils/event_storage_sqlite.dart';

/// Events in Firestore + SQLite speichern
class EventStorage {
  // Instanz der Klasse EventStorageFirestore
  final EventStorageFirestore _firestoreStorage = EventStorageFirestore();
  // Instanz der Klasse EventStorageSQLite
  final EventStorageSQLite _sqliteStorage = EventStorageSQLite();

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
}
