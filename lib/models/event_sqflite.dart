/// Struktur der Event-Datenbank für die Termine
class EventSqflite {
  // Firestore-Dokument-ID
  final String id;
  // Titel des Events
  final String title;
  // Beschreibung des Events
  final String body;
  // Zeitpunkt des Events (in ISO-8601 String oder direkt DateTime)
  final String eventTime;
  // Uhrzeit des Events
  final String localTime;
  // Notification-Zeitpunkte (Erinnerungen)
  final DateTime notificationTime1;
  final DateTime notificationTime2;
  final DateTime notificationTime3;

  // Der Konstruktor der 'Event-Klasse'
  EventSqflite({
    required this.id,
    required this.title,
    required this.body,
    required this.eventTime,
    required this.localTime,
    required this.notificationTime1,
    required this.notificationTime2,
    required this.notificationTime3,
  });
}
