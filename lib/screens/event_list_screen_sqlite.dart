import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/event_storage_firestore.dart';
import '../models/event_sqlite.dart';
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

  @override
  Widget build(BuildContext context) {
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

      // FutureBuilder, um alle Daten aus der lokalen DB zu laden.
      body: FutureBuilder<List<EventSQLite>>(
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

          // Events sortieren und filtern
          final now = DateTime.now(); // Aktuelles Datum
          // Aktuelles Datum ohne Uhrzeit
          final startOfDay = DateTime(now.year, now.month, now.day);

          // Sortiere die Events nach ihrem Event-Time-Attribut in aufsteigender Reihenfolge.
          // Die Methode `DateTime.parse` konvertiert den String `eventTime` in ein DateTime-Objekt.
          // Die `compareTo`-Methode vergleicht die DateTime-Objekte, um die Sortierung durchzuführen.
          final events = snapshot.data!
            ..sort((a, b) => DateTime.parse(a.eventTime)
                .compareTo(DateTime.parse(b.eventTime)));

          // Filtere die Events basierend auf dem Zustand von `_showTiles`.
          // - Wenn `_showTiles` `true` ist, werden alle Events angezeigt.
          // - Wenn `_showTiles` `false` ist, werden nur Events angezeigt, die später oder am gleichen Tag wie das aktuelle Datum liegen.
          // Die Methode `isAfter` überprüft, ob das Event nach dem aktuellen Datum liegt.
          // Die Methode `isAtSameMomentAs` überprüft, ob das Event am gleichen Tag wie das aktuelle Datum liegt.
          final filteredEvents = _showTiles
              ? events
              : events.where((event) {
                  final eventTime = DateTime.parse(event.eventTime);
                  return eventTime.isAfter(startOfDay) ||
                      eventTime.isAtSameMomentAs(startOfDay);
                }).toList();

          // ListView, um die Events als Kacheln untereinander anzuzeigen.
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filteredEvents.length,
            // Der itemBuilder wird aufgerufen, um jedes Item im ListView zu erstellen.
            itemBuilder: (context, index) {
              // Lade die Daten aus dem Dokument.
              final event = filteredEvents[index];
              final eventTime = event.localTime;

              // Dieser Ansatz konvertiert den String-Zeitstempel in ein DateTime-Objekt,
              // das dann mit der DateFormat-Klasse verwendet werden kann.
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
                    try {
                      // Schritt 1: In SQLite löschen
                      await DatabaseHelper.instance.deleteEvent(event.id);
                      debugPrint("SQLite: Event mit ID ${event.id} gelöscht.");

                      // Schritt 2: In Firestore löschen
                      final eventStorage = EventStorageFirestore();
                      await eventStorage.deleteEvent(event.id);
                      debugPrint(
                          "Firestore: Event mit ID ${event.id} gelöscht.");

                      // Warten, um sicherzustellen, dass alles abgeschlossen ist
                      await Future.delayed(const Duration(milliseconds: 100));

                      // Schritt 3: UI-Update sicherstellen
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${event.title} wurde gelöscht')),
                        );
                      }

                      // // Schritt 4: UI neu rendern
                      setState(() {});
                    } catch (error) {
                      debugPrint("Fehler beim Löschen: $error");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Fehler beim Löschen: $error')),
                        );
                      }
                    }
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
                            event.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
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
