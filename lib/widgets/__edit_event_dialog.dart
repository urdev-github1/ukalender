// import 'package:flutter/material.dart';
// import '../models/event.dart';

// /// Ereignis bearbeiten
// class EditEventDialog extends StatefulWidget {
//   final Event event;
//   final Function(String, String) onEditEvent;

//   const EditEventDialog({
//     super.key,
//     required this.event,
//     required this.onEditEvent,
//   });

//   @override
//   State<EditEventDialog> createState() => _EditEventDialogState();
// }

// class _EditEventDialogState extends State<EditEventDialog> {
//   late TextEditingController _eventController;
//   late DateTime _selectedTime;

//   @override
//   void initState() {
//     super.initState();
//     _eventController = TextEditingController(text: widget.event.title);
//     final timeParts = widget.event.time.split(":");
//     _selectedTime = DateTime(
//       DateTime.now().year,
//       DateTime.now().month,
//       DateTime.now().day,
//       int.parse(timeParts[0]),
//       int.parse(timeParts[1]),
//     );
//   }

//   @override
//   void dispose() {
//     _eventController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Ereignis bearbeiten"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Textfeld zum Bearbeiten des Titels
//           TextField(
//             controller: _eventController,
//             decoration: const InputDecoration(labelText: "Ereignis Titel"),
//           ),
//           const SizedBox(height: 10),

//           // Text zur Auswahl der Uhrzeit
//           const Text("Uhrzeit auswählen:"),
//           const SizedBox(height: 10),

//           // Button zum Öffnen des Time Pickers
//           ElevatedButton(
//             onPressed: () async {
//               final pickedTime = await showTimePicker(
//                 context: context,
//                 initialTime: TimeOfDay.fromDateTime(_selectedTime),
//               );
//               if (pickedTime != null) {
//                 setState(() {
//                   _selectedTime = DateTime(
//                     DateTime.now().year,
//                     DateTime.now().month,
//                     DateTime.now().day,
//                     pickedTime.hour,
//                     pickedTime.minute,
//                   );
//                 });
//               }
//             },
//             child: const Text("Zeit auswählen"),
//           ),
//         ],
//       ),

//       // Dialog schießen bzw. die Eingaben speichern
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Abbrechen"),
//         ),
//         TextButton(
//           onPressed: () {
//             // Überprüfe, ob der Titel nicht leer ist
//             if (_eventController.text.isNotEmpty) {
//               // Erstelle eine neue Uhrzeit-String-Instanz
//               final formattedTime =
//                   "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";
//               // Funktion zum Bearbeiten des Events
//               widget.onEditEvent(_eventController.text, formattedTime);
//               // Schließe den Dialog
//               Navigator.pop(context);
//             }
//           },
//           child: const Text("Speichern"),
//         ),
//       ],
//     );
//   }
// }
