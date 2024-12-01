import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:ukalender/utils/event_storage_firestore.dart';
import '../models/event_sqlite.dart';
//import '../utils/event_storage_firestore.dart';
import '../utils/database_helper.dart';

/// Alle Events als Kachel untereinander in zeitlich aufsteigender Reihenfolge
class EventListScreenSqlite extends StatefulWidget {
  const EventListScreenSqlite({super.key});

  @override
  State<EventListScreenSqlite> createState() => _EventListScreenSqliteState();
}

class _EventListScreenSqliteState extends State<EventListScreenSqlite> {
  // Zustand für das Ein-/Ausblenden von Kacheln
  bool _showTiles = false;

  //EventStorageFirestore? _eventStorageFirestore;

  @override
  Widget build(BuildContext context) {
    // Instanz von EventStorageFirestore
    //final eventStorage = EventStorageFirestore();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Terminübersicht',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          // Alte Events ein- und ausblenden
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              iconColor: Colors.black,
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'hideEvents',
                      child: Text(_showTiles
                          ? 'Vergangene Events ausblenden'
                          : 'Alle Events anzeigen'),
                    ),
                  ],
              onSelected: (value) async {
                if (value == 'hideEvents') {
                  setState(() {
                    _showTiles = !_showTiles;
                  });
                }
              }),
        ],
      ),

      // // StreamBuilder, um alle Daten aus Cloud Firestore zu laden.
      // body: StreamBuilder<QuerySnapshot>(
      //   // Abruf der Daten in 'event_storage.dart'
      //   stream: eventStorage.getEventStream(),

      // FutureBuilder, um alle Daten aus der lokalen DB zu laden.
      body: FutureBuilder<List<EventSqlite>>(
        // Abruf der Daten in 'database_helper.dart'
        future: DatabaseHelper.instance.queryAllEvents(),

        // Der builder wird aufgerufen, wenn die Daten geladen wurden.
        builder: (context, snapshot) {
          // Prüfen, ob Daten geladen werden oder ein Fehler aufgetreten ist.
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Ladeindikator
            return const Center(child: CircularProgressIndicator());
          }

          // Fehler aufgetreten
          if (snapshot.hasError) {
            return Center(
                child: Text('Fehler beim Laden der Daten: ${snapshot.error}'));
          }

          // Keine Einträge vorhanden
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Keine Events vorhanden."));
          }
          // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //   return const Center(child: Text("Keine Events vorhanden."));
          // }

          // // Daten sind geladen und zur Anzeige bereit
          // final eventDocs = snapshot.data!.docs;

          // // Sortiere die Dokumente basierend auf dem Feld 'eventTime'
          // eventDocs.sort((a, b) {
          //   final aTime = a['eventTime'] != null
          //       ? DateTime.parse(a['eventTime'])
          //       : DateTime.now();
          //   final bTime = b['eventTime'] != null
          //       ? DateTime.parse(b['eventTime'])
          //       : DateTime.now();
          //   return aTime.compareTo(bTime);
          // });

          // // Keine Events aus der Vergangenheit anzeigen, wenn _showTiles=false.
          // final now = DateTime.now();
          // final filteredDocs = _showTiles
          //     ? eventDocs
          //     : eventDocs.where((doc) {
          //         final eventTime = doc['eventTime'] != null
          //             ? DateTime.parse(doc['eventTime'])
          //             : null;
          //         return eventTime == null || eventTime.isAfter(now);
          //       }).toList();

          // Events sortieren und filtern
          final now = DateTime.now();
          final events = snapshot.data!
            ..sort((a, b) => DateTime.parse(a.eventTime)
                .compareTo(DateTime.parse(b.eventTime)));
          final filteredEvents = _showTiles
              ? events
              : events.where((event) {
                  final eventTime = DateTime.parse(event.eventTime);
                  return eventTime.isAfter(now);
                }).toList();

          // ListView, um die Events als Kacheln untereinander anzuzeigen.
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            // itemCount: filteredDocs.length,
            itemCount: filteredEvents.length,
            // Der itemBuilder wird aufgerufen, um jedes Item im ListView zu erstellen.
            itemBuilder: (context, index) {
              // Lade die Daten aus dem Dokument.
              //final doc = filteredDocs[index];
              final event = filteredEvents[index];

              // final eventData = doc.data() as Map<String, dynamic>;
              // final title = eventData['title'] ?? 'Kein Titel';
              // final body = eventData['body'] ?? 'Keine Beschreibung';
              // final eventDay = eventData['eventTime'] != null
              //     ? DateTime.parse(eventData['eventTime'])
              //     : null;

              //final eventTime = eventData['localTime']; // Uhrzeit
              final eventTime = event.localTime;

              // Dieser Ansatz konvertiert den String-Zeitstempel in ein DateTime-Objekt,
              // das dann mit der DateFormat-Klasse verwendet werden kann.
              // final String eventYMD = DateFormat('dd.MM.yy')
              //     .format(DateTime.parse(eventData['eventTime']));
              final eventYMD = DateFormat('dd.MM.yy')
                  .format(DateTime.parse(event.eventTime));

              // Wischgeste zum Löschen von Events
              return Dismissible(
                key: Key(event.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // Verwendet confirmDismiss, um eine Bestätigung einzuholen, bevor das
                // Element entfernt wird. Die Löschung erfolgt über 'event_storage.dart'.
                confirmDismiss: (direction) async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('ACHTUNG!!!'),
                        content: Text(
                            //'$eventYMD: $title\n\nDieser Termin wird aus der Datenbank gelöscht.',
                            '$eventYMD: ${event.title}\n\nDieser Termin wird aus der Datenbank gelöscht.',
                            style: const TextStyle(fontSize: 16)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Löschen'),
                          ),
                        ],
                      );
                    },
                  );

                  // Wenn die Löschung bestätigt wurde
                  if (shouldDelete == true) {
                    //await eventStorage.deleteEvent(doc.id);
                    await DatabaseHelper.instance.deleteEvent(event.id);
                    //EventStorageFirestore? eventStorageFirestore;
                    //await eventStorageFirestore?.deleteEvent(event.id);
                    // Prüfen, ob das Widget noch im Baum ist, bevor die Snackbar angezeigt wird
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        //SnackBar(content: Text('$title wurde gelöscht')),
                        SnackBar(
                            content: Text('${event.title} wurde gelöscht')),
                      );
                    }
                    setState(() {}); // Trigger UI refresh
                  }

                  // Rückgabe von true oder false, je nach Bestätigung
                  return shouldDelete;
                },

                // Formatierung der Cards
                child: SizedBox(
                  width: double.infinity, // Volle Breite
                  child: Card(
                    color: Colors.white70, // Hintergrundfarbe der Card
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            //title,
                            event.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // eventDay != null
                            //     ? 'Termin: ${eventDay.day}.${eventDay.month}.${eventDay.year} um $eventTime Uhr' //${eventTime.}.${eventTime.month}'
                            //     : "Terminbeginn unbekannt",
                            'Termin: $eventYMD um $eventTime Uhr',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            //body,
                            event.body,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
