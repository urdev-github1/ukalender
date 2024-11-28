import 'package:flutter/material.dart';
import 'package:ukalender/models/event_firestore.dart';
import 'package:ukalender/models/event_sqflite.dart';
import 'package:intl/intl.dart'; // Zum Formatieren des Datums

/// Events vom aktuellen Tag (Aufruf über _onDayLongPressed)
class ShowEventsForDay extends StatefulWidget {
  final DateTime selectedDay;
  //final List<EventFirestore> eventsForDay;
  final List<EventSqflite>
      eventsForDay; // Ändern von EventFirestore zu EventSqflite

  const ShowEventsForDay({
    super.key,
    required this.eventsForDay,
    required this.selectedDay,
  });

  @override
  State<ShowEventsForDay> createState() => _ShowEventsForDayState();
}

class _ShowEventsForDayState extends State<ShowEventsForDay> {
  @override
  Widget build(BuildContext context) {
    // Formatieren des Datums als z.B. 'dd.MM.yyyy'
    String formattedDate = DateFormat('dd. MMM.').format(widget.selectedDay);

    // //
    // List<String> smiley = [
    //   '😊', // Glücklich
    //   '😔', // Traurig
    //   '😠', // Wütend
    //   '😮', // Überrascht
    //   '😁', // Lächeln
    //   '😘', // Küssen
    //   '😂', // Lachen
    //   '😞', // Enttäuscht
    //   '😱', // Erschrocken
    //   '😄', // Fröhlich
    //   '😟', // Sorgen
    // ];

    //
    String getSmiley(String title) {
      // Titel in Kleinbuchstaben umwandeln
      String lowerTitle = title.toLowerCase();
      //
      if (lowerTitle.contains('geburtstag')) {
        return '😊'; // Glücklich
      } else if (title.contains('gitarre')) {
        return '😄'; // Überrascht
      } else if (title.contains('arzt')) {
        return '😟'; // Überrascht
      } else {
        return '🙂'; // Standard-Smiley, falls keine Bedingung erfüllt ist
      }
    }
    //String smiley = '😮';

    return AlertDialog(
      title: Text(
        // getSmiley: Funktion die den Titel durchsucht und das entsprechende Emoji zurückgibt.
        'Denke dran! ${getSmiley(widget.eventsForDay.isNotEmpty ? widget.eventsForDay.first.title : '')} $formattedDate',
        style: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 226, 185, 49),
          fontWeight: FontWeight.bold, // Fontfarbe
        ),
      ),
      content: Column(
        // Das Popup-Fenster ist nur so hoch wie nötig.
        mainAxisSize: MainAxisSize.min,
        // Richtet die Hauptspalte links aus
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.eventsForDay.map(
            (event) => Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              // Für den Titel und die Uhrzeit.
              child: Row(
                children: [
                  // // Aufzählungszeichen vor dem Titeltext
                  // const Text(
                  //   '•',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     color: Colors.black54,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // Expanded sorgt dafür, dass der Titel den verfügbaren Raum nutzt.
                  Expanded(
                    child: Text(event.title,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  // Uhrzeit
                  Text(
                    event.localTime,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Hintergrundfarbe
      backgroundColor: const Color.fromARGB(212, 118, 148, 163),
    );
  }
}
