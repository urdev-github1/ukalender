// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import '../models/event_firestore.dart';
// import '../models/event_sqflite.dart';
// import '../utils/database_helper.dart';

// /// Verbindung nach Cloud Firestore und Daten speichern
// class EventStorage {
//   // FirebaseFirestore-Instanz der 'events'-Sammlung
//   final CollectionReference _eventsCollection =
//       FirebaseFirestore.instance.collection('events');

//   // *** SPEICHERN ***

//   // Neu eingegebenes Event (über add_event_dialog.dart) in Firestore speichern
//   Future<void> saveEvent({
//     required String title,
//     required String body,
//     required DateTime eventDateTime,
//     DateTime? dayBefore,
//     DateTime? twoHoursBefore,
//     DateTime? thirtyMinutesBefore,
//     List<int>? notificationIds,
//   }) async {
//     try {
//       // Setze die Uhrzeit des eventTime auf Mitternacht
//       final DateTime eventTimeAtMidnight = DateTime(
//         eventDateTime.year,
//         eventDateTime.month,
//         eventDateTime.day,
//       );

//       // Extrahiere nur die Uhrzeit aus eventTime
//       String localTime = DateFormat('HH:mm').format(eventDateTime);

//       // Zum Dokument zugehörige Felder.
//       final eventData = {
//         'title': title,
//         'body': body,
//         'notificationIds': notificationIds,
//         'eventTime': eventTimeAtMidnight.toIso8601String(),
//         'localTime': localTime,
//         if (dayBefore != null)
//           'dayBefore': DateTime(dayBefore.year, dayBefore.month, dayBefore.day)
//               .toIso8601String(),
//         if (twoHoursBefore != null)
//           'twoHoursBefore': twoHoursBefore.toIso8601String(),
//         if (thirtyMinutesBefore != null)
//           'thirtyMinutesBefore': thirtyMinutesBefore.toIso8601String(),
//       };

//       // Speichern der Daten in Cloud Firestore
//       DocumentReference docRef = await _eventsCollection.add(eventData);
//       String eventId = docRef.id;

//       // Speichern der Daten in SQLite
//       EventSqflite eventSqflite = EventSqflite(
//         id: eventId,
//         title: title,
//         body: body,
//         eventTime: eventTimeAtMidnight.toIso8601String(),
//         localTime: localTime,
//         dayBefore: dayBefore?.toIso8601String() ?? '',
//         notificationIds:
//             EventSqflite.notificationIdsToJson(notificationIds ?? []),
//         thirtyMinutesBefore: thirtyMinutesBefore?.toIso8601String() ?? '',
//         twoHoursBefore: twoHoursBefore?.toIso8601String() ?? '',
//       );
//       await DatabaseHelper.instance.insertEvent(eventSqflite);

//       print("Event erfolgreich gespeichert!");
//     } catch (e) {
//       print("Fehler beim Speichern des Events: $e");
//     }
//   }

//   // *** AUSLESEN I für die Verarbeitung in einer Liste ***
//   // -> Wird in 'event_list_screen.dart' weiterverarbeitet.
//   // -> Wird hier in 'event_storage.dart' unter AUSLESEN II weiterverarbeitet.

//   // Stream um alle Events aus Cloud Firestore zu erhalten.
//   Stream<QuerySnapshot> getEventStream() {
//     return _eventsCollection.snapshots();
//   }

//   // *** AUSLESEN II für die Verarbeitung in einer Map ***
//   // -> Wird in 'calendar_screen.dart' weiterverarbeitet.

//   // Methode, um Events in die Map 'eventsFromFirestore' zu laden und an
//   // 'loadEventsFromFirestore' zurückzugeben.
//   Future<Map<DateTime, List<EventFirestore>>> loadEventsFromFirestore() async {
//     // Lokale Map für die Event-Daten aus Firestore definieren.
//     final Map<DateTime, List<EventFirestore>> eventsFromFirestore = {};
//     // Gibt alle Dokumente der Firestore Collection zurück.
//     final snapshot = await _eventsCollection.get();

//     // Leere _events-Map initialisieren
//     eventsFromFirestore.clear();

//     // Für jedes Dokument in der Collection
//     for (var doc in snapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;

//       // Datum ohne die Uhrzeit als Schlüssel verwenden.
//       final DateTime eventDate =
//           DateTime.parse(data['eventTime']); //.toLocal();

//       // Konstruktor
//       final event = EventFirestore(
//         id: doc.id,
//         title: data['title'],
//         body: data['body'],
//         eventTime: eventDate,
//         localTime: data['localTime'],
//       );

//       /*
//       Dieser Ansatz ermöglicht es, mehrere Events pro Datum zu speichern und effizient 
//       auf alle Events eines bestimmten Datums zuzugreifen. Dies ist besonders nützlich für 
//       Kalenderanwendungen, bei denen Events nach Datum gruppiert angezeigt werden müssen.
//     */
//       // Event zur Map hinzufügen, wenn es für das gegebene Datum schon Einträge gibt
//       if (eventsFromFirestore.containsKey(eventDate)) {
//         eventsFromFirestore[eventDate]!.add(event);
//       } else {
//         // Wenn nicht wird ein neuer Eintrag in der Map erstellt
//         eventsFromFirestore[eventDate] = [event];
//       }
//     }
//     // Das Ergebnis wird in 'loadEventsFromFirestore' geschieben.
//     return eventsFromFirestore;
//   }

//   // *** AUSLESEN III für die Verarbeitung in einer Map aus SQLite ***
//   // -> Wird in 'calendar_screen.dart' weiterverarbeitet.

//   // Methode, um Events in die Map 'eventsFromSqflite' zu laden und an
//   // 'loadEventsFromSqflite' zurückzugeben.
//   Future<Map<DateTime, List<EventSqflite>>> loadEventsFromSqflite() async {
//     // Lokale Map für die Event-Daten aus SQLite definieren.
//     final Map<DateTime, List<EventSqflite>> eventsFromSqflite = {};
//     // Gibt alle Dokumente der SQLite Datenbank zurück.
//     final events = await DatabaseHelper.instance.queryAllEvents();

//     // Leere _events-Map initialisieren
//     eventsFromSqflite.clear();

//     // Für jedes Dokument in der Collection
//     for (var event in events) {
//       // Datum ohne die Uhrzeit als Schlüssel verwenden.
//       final DateTime eventDate = DateTime.parse(event.eventTime);

//       // Event zur Map hinzufügen, wenn es für das gegebene Datum schon Einträge gibt
//       if (eventsFromSqflite.containsKey(eventDate)) {
//         eventsFromSqflite[eventDate]!.add(event);
//       } else {
//         // Wenn nicht wird ein neuer Eintrag in der Map erstellt
//         eventsFromSqflite[eventDate] = [event];
//       }
//     }
//     // Das Ergebnis wird in 'loadEventsFromSqflite' geschieben.
//     return eventsFromSqflite;
//   }

//   // *** LÖSCHEN ***

//   // Einzelnes Event wieder löschen.
//   Future<void> deleteEvent(String eventId) async {
//     // Löschen in Firestore
//     await _eventsCollection.doc(eventId).delete();

//     // Löschen in SQLite
//     await DatabaseHelper.instance.deleteEvent(eventId);
//   }
// }
