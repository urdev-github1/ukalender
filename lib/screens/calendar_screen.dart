import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ukalender/models/event_sqflite.dart';
import 'package:ukalender/utils/database_helper.dart';
import '../screens/notification_screen.dart';
import '../utils/event_storage_firestore.dart';
import '../widgets/show_events_for_day.dart';
import '../models/event_firestore.dart';
import '../screens/event_list_screen.dart';
import '../widgets/add_event_dialog.dart';

/// Klasse zum Aufbau der Bedienoberfläche
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  // Erstellt den Zustand für die Kalender-App
  State<CalendarScreen> createState() => _CalendarScreenState();
}

// Definiert den Zustand für die Kalender-App
class _CalendarScreenState extends State<CalendarScreen> {
  // Instanz für einen Monatskalender
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  // Speichert die Ereignisse, die an einem bestimmten Tag stattfinden
  //late Map<DateTime, List<EventFirestore>> _events;
  late Map<DateTime, List<EventSqflite>> _events;

  // Speichert den aktuell ausgewählten Tag
  late DateTime _selectedDay;
  // Speichert den aktuell fokussierten Tag
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();

    // Fokusierter und heutiger Tag auf DateTime.now();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // Leere Map erzeugen. Die variable muss initialisiert werden
    // bevor sie benutzt werden kann.
    _events = {};

    // Lade alle Events beim App-Neustart aus der Firestore-Datenbank
    _loadAllEvents();
  }

// Lädt alle Events aus der Sqflite-Datenbank und speichert sie in einer Map.
  Future<void> _loadAllEvents() async {
    // Abrufen aller Events aus der Datenbank
    final List<EventSqflite> events =
        await DatabaseHelper.instance.queryAllEvents();

    setState(() {
      // Konvertieren der Event-Liste in eine Map mit Datum als Schlüssel
      _events = {};
      for (var event in events) {
        final eventDate =
            DateTime.parse(event.eventTime); // ISO-8601 String zu DateTime
        final localDate =
            DateTime(eventDate.year, eventDate.month, eventDate.day);

        // Liste der Events für den Tag initialisieren, falls nicht vorhanden
        if (_events[localDate] == null) {
          _events[localDate] = [];
        }

        // Event zur Liste hinzufügen
        _events[localDate]!.add(event);
      }
    });
  }

  // // Lädt alle Events aus der Firestore-Datenbank und speichert sie in einer Map.
  // Future<void> _loadAllEvents() async {
  //   // events enthält alle Termine, die aus Firestore geladen wurden.
  //   final events = await EventStorageFirestore().loadEventsFromFirestore();
  //   setState(() {
  //     // Die Map aus 'loadEventsFromFirestore' einlesen.
  //     _events = events;
  //   });
  // }

  // // Gibt die Events des angewählten Tages zurück.
  // List<EventFirestore> _getEventsForDay(DateTime day) {
  //   //print("Liste aller Events für $day - Ergebnis: ${_events[day]}");
  //   // Konvertieren des UTC-Datums in das lokales Datum
  //   final localDay = DateTime(day.year, day.month, day.day);
  //   // Die Daten in _events werden über die Methode _loadAllEvents eingelesen.
  //   return _events[localDay] ?? [];
  // }

  List<EventSqflite> _getEventsForDay(DateTime day) {
    // Datum normalisieren (nur Jahr, Monat und Tag)
    final localDay = DateTime(day.year, day.month, day.day);
    return _events[localDay] ?? [];
  }

  // Aufruf, wenn ein Kalendertag angetippt wurde
  // Dabei wird das angetippte Datum nach selectedDay und focusedDay geschrieben.
  // isSameDay wird in Flutter verwendet, um zu prüfen, ob zwei DateTime-Objekte
  // dasselbe Datum darstellen.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        // Wenn _selectedDay /= selectedDay
        _selectedDay = selectedDay; // Aktualisiert den ausgewählten Tag
        _focusedDay = focusedDay;
      });
    }
  }

  // Ein Kalendertag wurde dauerhaft angedrückt
  void _onDayLongPressed(DateTime selectedDay, DateTime focusedDay) {
    //List<EventFirestore> eventsForDay = _getEventsForDay(selectedDay);
    List<EventSqflite> eventsForDay = _getEventsForDay(selectedDay);

    // Zeige alle Termine für den angeklickten Kalendertag
    showDialog(
      context: context,
      builder: (context) => ShowEventsForDay(
        eventsForDay: eventsForDay,
        selectedDay: selectedDay, // Übergebe das Datum an den Dialog
      ),
    );
  }

  // Aufruf der Eventliste
  void _showEventListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventListScreen()),
    );
  }

  // Eingabedialog: Events (-> widgets/add_event_dialog.dart)
  void _openAddEventDialog() {
    showDialog(
      context: context, // Kontext, in dem der Dialog geöffnet wird
      // Übergibt den ausgewählten Tag an AddEventDialog.
      // _selectedDay wird in der Methode _onDaySelecte gefüllt.
      builder: (context) => AddEventDialog(selectedDay: _selectedDay),
    );
  }

  // Abrufen ausstehender Benachrichtigungen
  void _getNotification() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()));
  }

  // VORBEREITET: Sqflite -> JSON
  // Future<void> _exportDataAsJson() async {
  //   const dbPath = '/data/data/de.fludev.ukalender/databases/events.db';
  //   final db = await openDatabase(dbPath);

  //   final data = await db.rawQuery('SELECT * FROM events'); // Tabelle anpassen
  //   final exportDir = await getExternalStorageDirectory();
  //   final file = File('${exportDir!.path}/events.json');

  //   await file.writeAsString(data.toString());
  //   print('Data exported to: ${file.path}');
  // }

  // Kopieren der events.db in das Downloadverzeichnis.
  Future<void> _copyDatabaseToDownloads() async {
    try {
      // Berechtigung anfordern
      if (await Permission.storage.request().isGranted) {
        // Zugriff auf das interne Verzeichnis der App
        //final appDir = await getApplicationDocumentsDirectory();
        // final dbPath = File('${appDir.path}/events.db');
        final dbPath =
            File('/data/data/de.fludev.ukalender/databases/events.db');

        // Prüfen, ob die Datenbank existiert
        if (!await dbPath.exists()) {
          throw Exception("Datenbankdatei events.db nicht gefunden.");
        }

        // Zugriff auf das Download-Verzeichnis
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          throw Exception("Download-Verzeichnis nicht gefunden.");
        }

        // Datei kopieren
        final destinationPath = '${downloadDir.path}/events.db';
        await dbPath.copy(destinationPath);

        debugPrint('Datenbank erfolgreich nach $destinationPath kopiert.');
      } else {
        throw Exception("Speicherzugriff verweigert.");
      }
    } catch (e) {
      debugPrint('Fehler beim Kopieren der Datenbank: $e');
    }
  }

  // Firestore Datenbank export
  Future<void> _exportFirestoreToSqflite() async {
    // Referenz zur Firestore-Sammlung
    CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    try {
      // Abrufen der Dokumente aus Firestore
      QuerySnapshot querySnapshot = await eventsCollection.get();

      // Iteration durch die Dokumente
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Firestore-Daten in ein EventSqflite-Objekt transformieren
        EventSqflite event = EventSqflite(
          id: doc.id, // Dokument-ID als Event-ID verwenden
          title: doc['title'],
          body: doc['body'],
          eventTime: doc['eventTime'],
          localTime: doc['localTime'],
          dayBefore: doc['dayBefore'],
          notificationIds: EventSqflite.notificationIdsToJson(
              List<int>.from(doc['notificationIds'])),
          thirtyMinutesBefore: doc['thirtyMinutesBefore'],
          twoHoursBefore: doc['twoHoursBefore'],
        );

        // Event in die lokale SQLite-Datenbank einfügen
        await DatabaseHelper.instance.insertEvent(event);
      }

      print('Daten erfolgreich aus Firestore exportiert.');
    } catch (e) {
      print('Fehler beim Exportieren der Daten: $e');
    }
  }

  // Widget erstellen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          // Firestore Datenbank export
          IconButton(
            icon: const Icon(Icons.get_app, color: Colors.white),
            onPressed: _exportFirestoreToSqflite,
          ),
          // Datenbank in den Smartphone-Ordner Download kopieren
          IconButton(
            icon: const Icon(Icons.file_copy, color: Colors.white),
            onPressed: _copyDatabaseToDownloads,
          ),
          // Notification auslesen
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined,
                color: Colors.white),
            onPressed: _getNotification,
          ),
          // Eventscreen anzeigen
          IconButton(
            icon: const Icon(Icons.event_available, color: Colors.white),
            onPressed: _showEventListScreen,
          ),
          // Hinzufügen eines neuen Events
          IconButton(
            icon: const Icon(Icons.event, color: Colors.white),
            onPressed: _openAddEventDialog,
          ),
        ],
      ),
      // Kalenderlayout erstellen
      body: Padding(
        // Kalendereigenschaften festlegen
        padding: const EdgeInsets.only(top: 16, left: 10, right: 10),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // TableCalendar-Widget
                child: TableCalendar(
                  headerVisible: true,
                  rowHeight: 98, // Kalenderausdehnung
                  locale: 'de_DE', // Sprach- und Regionen-Argumente
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  focusedDay: _focusedDay, // Aktueller Tag im Kalender
                  weekNumbersVisible: false,
                  calendarFormat: _calendarFormat, // Monatskalender
                  // Funktion, die bestimmt, welcher Tag ausgewählt ist
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  // Funktion, die aufgerufen wird, wenn ein Tag ausgewählt wurde.
                  onDaySelected: _onDaySelected,

                  // showDialog -> Alle Events des selektierten Tages
                  onDayLongPressed: _onDayLongPressed,

                  // Funktion, die Events für einen bestimmten Tag liefert
                  // (Wird in event_storage.dart weiterverarbeitet.)
                  eventLoader: (day) => _getEventsForDay(day),

                  // Stil des Kalenders
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),

                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),

                    // Wenn Kalenderwochen eingblendet werden
                    weekNumberTextStyle: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 10,
                    ),

                    // Wochenendtage
                    weekendTextStyle: TextStyle(
                      color: Colors.orangeAccent,
                    ),

                    // Tage des vorangegangenen und folgenden Monats nicht anzeigen
                    outsideDaysVisible: false,
                  ),

                  // Stil des Kalenderkopfes
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 23),
                  ),

                  // Stil der Wochentage (Montag - Sonntag)
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white, // Farbe für Montag bis Freitag
                      //fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    weekendStyle: TextStyle(
                      color:
                          Colors.orangeAccent, // Farbe für Samstag und Sonntag
                      //fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  // verfügbare Gesten, die auf dem Kalender ausgeführt werden können
                  availableGestures: AvailableGestures.all,

                  // Eigenschaften
                  calendarBuilders: CalendarBuilders(
                    // Event-Markierungen (events -> siehe Methode '_loadAllEvents')
                    markerBuilder: (context, day, events) {
                      // UTC-Datum in lokales Datum
                      final localDay = DateTime(day.year, day.month, day.day);

                      // Überprüfen, ob der Tag in der Vergangenheit liegt
                      final isPastDay = localDay.isBefore(DateTime.now());

                      // Events für den gewälten Tag abfragen.
                      final dayEvents = _getEventsForDay(localDay);

                      if (dayEvents.isNotEmpty) {
                        // Farbe basierend darauf, ob der Tag in der Vergangenheit liegt
                        final markerColor =
                            isPastDay ? Colors.orange : Colors.green;

                        // Nimm das erste Event des Tages
                        final firstEvent = (dayEvents.first).title;
                        final shortenedFirst = firstEvent.length > 7
                            ? firstEvent.substring(0, 7)
                            : firstEvent;

                        // Widget für Event 1
                        Widget firstEventWidget = Flexible(
                          child: Container(
                            //padding: const EdgeInsets.all(1),
                            //margin: const EdgeInsets.symmetric(vertical: 1),
                            width: 45,
                            height: 18,
                            color: markerColor,
                            child: Center(
                              child: Text(
                                shortenedFirst,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );

                        // Wenn es mehr als ein Event gibt
                        if (dayEvents.length > 1) {
                          final lastEvent = dayEvents.last.title;
                          final shortenedLast = lastEvent.length > 6
                              ? lastEvent.substring(0, 6)
                              : lastEvent;

                          // Events in eine Spalte einfügen
                          return Column(
                            children: [
                              // Marker unter den Tag zu platzieren
                              const SizedBox(height: 60),
                              // Event 1 einblenden
                              firstEventWidget,
                              // Abstand zwischen den Markern
                              const SizedBox(height: 2),
                              // Event 2 einblenden
                              Center(
                                child: Text(
                                  shortenedLast,
                                  style: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: markerColor,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        // Falls nur ein Event vorhanden ist
                        return Column(
                          children: [
                            // Abstand unter dem Tag
                            const SizedBox(height: 60),
                            firstEventWidget,
                          ],
                        );
                      }
                      return const SizedBox
                          .shrink(); // Kein Event, also kein Marker
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
