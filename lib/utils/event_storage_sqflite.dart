import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event_sqflite.dart';
import '../utils/database_helper.dart';

/// Verbindung nach Sqflite und Daten speichern
class EventStorageSqflite {
  //
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = Uuid();

  // *** SPEICHERN ***

  // Neu eingegebenes Event (über add_event_dialog.dart) in Sqflite speichern
  Future<void> saveEventToSqflite({
    String? id, // ID kann optional sein
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

      // ID generieren, da die Datenbank keinen Primärschlüssel besitzt.
      final eventId = id ?? _uuid.v4();

      // Speichern der Daten in Sqflite
      final event = EventSqflite(
        id: eventId,
        title: title,
        body: body,
        eventTime: eventTimeAtMidnight.toIso8601String(),
        localTime: localTime,
        dayBefore: dayBefore?.toIso8601String() ?? '',
        twoHoursBefore: twoHoursBefore?.toIso8601String() ?? '',
        thirtyMinutesBefore: thirtyMinutesBefore?.toIso8601String() ?? '',
        notificationIds:
            EventSqflite.notificationIdsToJson(notificationIds ?? []),
      );

      // Event in die Datenbank einfügen
      await _dbHelper.insertEvent(event);

      print("Event erfolgreich gespeichert!");
    } catch (e) {
      print("Fehler beim Speichern des Events: $e");
    }
  }

  // *** AUSLESEN ***

  Future<Map<DateTime, List<EventSqflite>>> loadEventsFromSqflite() async {
    final Map<DateTime, List<EventSqflite>> eventsFromSqflite = {};
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
