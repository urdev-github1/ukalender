import 'package:intl/intl.dart';
import '../models/event_sqlite.dart';
import '../utils/database_helper.dart';

/// Verbindung nach Sqflite und Daten speichern
class EventStorageSQLite {
  // Instanz der Klasse DatabaseHelper + Methode 'instance'
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // *** SPEICHERN ***

  // Neu eingegebenes Event (über add_event_dialog.dart) in SQLite speichern
  Future<void> saveEventToSQLite({
    required String id,
    required String title,
    required String body,
    required DateTime eventDateTime,
    DateTime? dayBefore,
    DateTime? twoHoursBefore,
    DateTime? thirtyMinutesBefore,
    List<int>? notificationIds,
  }) async {
    try {
      // Setze die Uhrzeit des eventTime auf Mitternacht
      final DateTime eventTimeAtMidnight = DateTime(
        eventDateTime.year,
        eventDateTime.month,
        eventDateTime.day,
      );

      // Extrahiere nur die Uhrzeit aus eventTime
      String localTime = DateFormat('HH:mm').format(eventDateTime);

      // Speichern der Daten in SQLite
      final event = EventSQLite(
        id: id,
        title: title,
        body: body,
        eventTime: eventTimeAtMidnight.toIso8601String(),
        localTime: localTime,
        dayBefore: dayBefore?.toIso8601String() ?? '',
        twoHoursBefore: twoHoursBefore?.toIso8601String() ?? '',
        thirtyMinutesBefore: thirtyMinutesBefore?.toIso8601String() ?? '',
        notificationIds:
            EventSQLite.notificationIdsToJson(notificationIds ?? []),
      );

      // Event in die Datenbank einfügen
      await _dbHelper.insertEvent(event);

      print("Event erfolgreich gespeichert!");
    } catch (e) {
      print("Fehler beim Speichern des Events: $e");
    }
  }

  // *** AUSLESEN ***

  Future<Map<DateTime, List<EventSQLite>>> loadEventsFromSqflite() async {
    final Map<DateTime, List<EventSQLite>> eventsFromSqflite = {};
    final events = await DatabaseHelper.instance.queryAllEvents();

    eventsFromSqflite.clear();

    for (var event in events) {
      final DateTime eventDate = DateTime.parse(event.eventTime);

      if (eventsFromSqflite.containsKey(eventDate)) {
        eventsFromSqflite[eventDate]!.add(event);
      } else {
        eventsFromSqflite[eventDate] = [event];
      }
    }
    return eventsFromSqflite;
  }

  // *** LÖSCHEN ***

  Future<void> deleteEventFromSqflite(String eventId) async {
    await DatabaseHelper.instance.deleteEvent(eventId);
  }
}
