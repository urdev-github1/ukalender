import '../utils/event_storage_firestore.dart';
import '../utils/event_storage_sqflite.dart';

class EventStorage {
  final EventStorageFirestore _firestoreStorage = EventStorageFirestore();
  final EventStorageSqflite _sqfliteStorage = EventStorageSqflite();

  Future<void> saveEvent({
    required String title,
    required String body,
    required DateTime eventDateTime,
    DateTime? dayBefore,
    DateTime? twoHoursBefore,
    DateTime? thirtyMinutesBefore,
    List<int>? notificationIds,
  }) async {
    // Speichern in Firestore
    await _firestoreStorage.saveEventToFirestore(
      title: title,
      body: body,
      eventDateTime: eventDateTime,
      dayBefore: dayBefore,
      twoHoursBefore: twoHoursBefore,
      thirtyMinutesBefore: thirtyMinutesBefore,
      notificationIds: notificationIds,
    );
    // Speichern in Sqflite
    await _sqfliteStorage.saveEventToSqflite(
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
