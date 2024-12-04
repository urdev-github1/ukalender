import 'dart:convert';

/// Struktur der Event-Datenbank für die Termine
class EventSQLite {
  // Datesatz-ID
  final String id;
  // Titel des Events
  final String title;
  // Beschreibung des Events
  final String body;
  // Zeitpunkt des Events (in ISO-8601 String)
  final String eventTime;
  // Uhrzeit des Events
  final String localTime;
  // Erinnerungszeitpunkte (Notification-IDs als JSON-String)
  final String notificationIds; // (30 Min. / 2 Std. / 1 Tag)
  // Erinnerung 30 Minuten vor dem Event (in ISO-8601 String)
  final String thirtyMinutesBefore;
  // Erinnerung 2 Stunden vor dem Event (in ISO-8601 String)
  final String twoHoursBefore;
  // Erinnerung 1 Tag vor dem Event (in ISO-8601 String)
  final String dayBefore;

  // Der Konstruktor der 'Event-Klasse'
  EventSQLite({
    required this.id,
    required this.title,
    required this.body,
    required this.eventTime,
    required this.localTime,
    required this.notificationIds,
    required this.thirtyMinutesBefore,
    required this.twoHoursBefore,
    required this.dayBefore,
  });

  // Funktion zur Konvertierung eines Event-Objekts in eine Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'eventTime': eventTime,
      'localTime': localTime,
      'dayBefore': dayBefore,
      'notificationIds': notificationIds,
      'thirtyMinutesBefore': thirtyMinutesBefore,
      'twoHoursBefore': twoHoursBefore,
    };
  }

  // Funktion zur Konvertierung einer Map in ein Event-Objekt
  factory EventSQLite.fromMap(Map<String, dynamic> map) {
    return EventSQLite(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      eventTime: map['eventTime'],
      localTime: map['localTime'],
      dayBefore: map['dayBefore'],
      notificationIds: map['notificationIds'],
      thirtyMinutesBefore: map['thirtyMinutesBefore'],
      twoHoursBefore: map['twoHoursBefore'],
    );
  }

  // Funktion zur Konvertierung der notificationIds von List<int> zu JSON-String
  static String notificationIdsToJson(List<int> notificationIds) {
    return jsonEncode(notificationIds);
  }

  // Funktion zur Konvertierung des JSON-Strings zurück zu List<int>
  static List<int> notificationIdsFromJson(String notificationIds) {
    return (jsonDecode(notificationIds) as List<dynamic>)
        .map((e) => e as int)
        .toList();
  }
}
