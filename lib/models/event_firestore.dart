/// Struktur der Event-Datenbank für die Termine
class EventFirestore {
  // Firestore-Dokument-ID
  final String id;
  // Titel des Events
  final String title;
  // Beschreibung des Events
  final String body;
  // Tag und Uhrzeit des Events
  final DateTime eventTime;
  // Uhrzeit des Events
  final String localTime;

  // Der Konstruktor der 'Event-Klasse'
  EventFirestore({
    required this.id,
    required this.title,
    required this.body,
    required this.eventTime,
    required this.localTime,
  });
}
