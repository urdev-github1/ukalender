// import 'package:flutter/material.dart';
// import 'package:ukalender/models/event.dart';
// import 'package:ukalender/utils/event_storage.dart';
// import 'package:ukalender/widgets/edit_event_dialog.dart';

// class DetailScreen extends StatefulWidget {
//   final DateTime selectedDay;
//   final Map<DateTime, List<Event>> events;

//   const DetailScreen({
//     super.key,
//     required this.selectedDay,
//     required this.events,
//   });

//   @override
//   State<DetailScreen> createState() => _DetailScreenState();
// }

// class _DetailScreenState extends State<DetailScreen> {
//   // Instanz der Klasse _eventStorage
//   late EventStorage _eventStorage;

//   @override
//   void initState() {
//     super.initState();
//     _eventStorage = EventStorage();
//   }

//   // Bearbeitet ein Ereignis und speichert es in Firestore
//   void _editEvent(Event oldEvent, String newTitle, String newTime) async {
//     // UI aktualisieren
//     setState(() {
//       // widget.events[widget.selectedDay] gibt die Liste der Events
//       // für den ausgewählten Tag zurück.
//       final eventsForDay = widget.events[widget.selectedDay];
//       // Finde das Event und ersetze es
//       if (eventsForDay != null) {
//         final eventIndex = eventsForDay.indexOf(oldEvent);
//         if (eventIndex != -1) {
//           // Ersetze das Event in der Liste mit dem neuen Titel und der neuen Zeit
//           eventsForDay[eventIndex] =
//               Event.withId(oldEvent.id, newTitle, newTime);
//         }
//       }
//     });
//     // // Event in Firestore speichern
//     await _eventStorage.saveEvent(
//         widget.selectedDay, Event.withId(oldEvent.id, newTitle, newTime));

//     // Alle Events nach dem Update neu laden, um sicherzustellen, dass die UI synchron ist
//     _reloadEvents();
//   }

//   // Lädt die Events neu und aktualisiert den UI-State
//   Future<void> _reloadEvents() async {
//     final events = await _eventStorage.loadAllEvents();
//     setState(() {
//       widget.events.clear();
//       widget.events.addAll(events);
//     });
//   }

//   // Dialog für die Event-Bearbeitung anzeigen
//   Future<void> _showEditEventDialog(Event event) async {
//     showDialog(
//       context: context,
//       builder: (context) => EditEventDialog(
//         event: event,
//         onEditEvent: (newTitle, newTime) {
//           _editEvent(event, newTitle, newTime);
//         },
//       ),
//     );
//   }

//   // Methode zum Löschen eines Events
//   void _deleteEvent(Event event) async {
//     // Event aus Firebase löschen
//     await _eventStorage.deleteEvent(event.id);

//     // Lokale Event-Liste aktualisieren
//     setState(() {
//       widget.events[widget.selectedDay]?.remove(event);
//     });

//     // Events neu laden
//     _reloadEvents();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final eventsForDay = widget.events[widget.selectedDay] ?? [];
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kalender-Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 16.0),
//         child: ListView.builder(
//           itemCount: eventsForDay.length,
//           itemBuilder: (context, index) {
//             final event = eventsForDay[index];
//             //
//             return ListTile(
//               title: Text('${event.time} Uhr:   ${event.title}'),
//               trailing: Row(
//                 // Breite der Zeile
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Event editieren
//                   IconButton(
//                     icon: const Icon(Icons.edit),
//                     onPressed: () => _showEditEventDialog(event),
//                   ),
//                   // Eventlöschen
//                   IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: () => _deleteEvent(event),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
