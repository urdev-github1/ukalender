import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukalender/models/event_firestore.dart';

/// Verbindung nach Cloud Firestore und Daten speichern
class EventStorage {
  // Lokale Map für die Event-Daten aus Firestore definieren.
  final Map<DateTime, List<EventFirestore>> _events = {};

  // *** SPEICHERN ***

  // Neu eingegebenes Event (über add_event_dialog.dart) in Firestore speichern
  Future<void> saveEvent({
    required String title,
    required String body,
    required DateTime eventTime,
    DateTime? dayBefore,
    DateTime? twoHoursBefore,
    DateTime? thirtyMinutesBefore,
    List<int>? notificationIds, // Neue Liste für Benachrichtigungs-IDs
  }) async {
    try {
      // Setze die Uhrzeit des eventTime auf Mitternacht
      final DateTime eventTimeAtMidnight = DateTime(
        eventTime.year,
        eventTime.month,
        eventTime.day,
      );

      // Extrahiere nur die Uhrzeit aus eventTime
      final String localTime = '${eventTime.hour}:${eventTime.minute}';

      // Zum Dokument zugehörige Felder.
      final eventData = {
        'title': title,
        'body': body,
        'notificationIds':
            notificationIds, // IDs der geplanten Benachrichtigungen speichern
        // Das eventTime-Feld auf Mitternacht (d. h. 00:00:00.000) Std./Min. auf 0 setzen.
        'eventTime': eventTimeAtMidnight.toIso8601String(),
        'localTime': localTime, // Die lokale Uhrzeit hinzufügen
        if (dayBefore != null)
          'dayBefore': DateTime(dayBefore.year, dayBefore.month, dayBefore.day)
              .toIso8601String(),
        if (twoHoursBefore != null)
          'twoHoursBefore': twoHoursBefore.toIso8601String(),
        if (thirtyMinutesBefore != null)
          'thirtyMinutesBefore': thirtyMinutesBefore.toIso8601String(),
      };

      // Speichern der Daten in Cloud Firestore
      await FirebaseFirestore.instance.collection('events').add(eventData);
      print("Event erfolgreich gespeichert!");
    } catch (e) {
      print("Fehler beim Speichern des Events: $e");
    }
  }

  // *** AUSLESEN ***

  // Stream um alle Events aus Cloud Firestore zu erhalten.
  // (Wird in event_list_screen.dart weiterverarbeitet.)
  Stream<QuerySnapshot> getEventStream() {
    return FirebaseFirestore.instance.collection('events').snapshots();
  }

  // Methode, um Events in die '_events' Map zu laden und zurückzugeben.
  // Wird in event_storage.dart weiterverarbeitet zur Anzeige von Markern.
  Future<Map<DateTime, List<EventFirestore>>> loadEventsFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();

    // Leere _events-Map initialisieren
    _events.clear();

    for (var doc in snapshot.docs) {
      //final data = doc.data() as Map<String, dynamic>;
      final data = doc.data();
      final DateTime eventTime = DateTime.parse(data['eventTime']);

      // Konsruktor
      final event = EventFirestore(
        id: doc.id, // Dokument-ID
        title: data['title'],
        body: data['body'],
        eventTime: eventTime,
        localTime: data['localTime'] ?? '00:00',
      );

      // Erstellen eines reinen Datumsschlüssels für die Gruppierung von Ereignissen
      final day = DateTime(eventTime.year, eventTime.month, eventTime.day);

      // Event hinzufügen, wenn noch nicht vorhanden
      _events.putIfAbsent(day, () => []).add(event);
    }
    return _events;
  }

  // *** LÖSCHEN ***

  Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      print("Event erfolgreich gelöscht!");
    } catch (e) {
      print("Fehler beim Löschen des Events: $e");
    }
  }
}
