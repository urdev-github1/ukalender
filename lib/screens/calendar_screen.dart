import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ukalender/models/event_sqlite.dart';
import 'package:ukalender/utils/database_helper.dart';
import '../screens/notification_screen.dart';
import '../widgets/show_events_for_day.dart';
import 'event_list_screen_sqlite.dart';
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
  late Map<DateTime, List<EventSQLite>> _events;

  // Speichert den aktuell ausgewählten Tag
  late DateTime _selectedDay;
  // Speichert den aktuell fokussierten Tag
  late DateTime _focusedDay;
  // Flag, um zu überprüfen, ob das Widget noch gemountet ist
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();

    // Fokusierter und heutiger Tag auf DateTime.now();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // Leere Map erzeugen. Die Variable muss initialisiert werden
    // bevor sie benutzt werden kann.
    _events = {};

    // Lade alle Events beim App-Neustart aus der SQLite-Datenbank
    _loadAllEvents();
  }

  // Sicherzustellen, dass setState() nicht aufgerufen wird, nachdem
  // das Widget aus dem Baum entfernt wurde.
  @override
  void dispose() {
    _isMounted = false; // Das Widget wird nicht mehr gemountet
    super.dispose();
  }

  // Lädt alle Events aus der SQLite-Datenbank und speichert sie in einer Map.
  Future<void> _loadAllEvents() async {
    // Zugriff auf die Datenbankinstanz, damit sie bei Bedarf erstellt wird
    final db = await DatabaseHelper.instance.database;

    //
    if (db == null) {
      print('Fehler: Die Datenbank konnte nicht initialisiert werden.');
      return;
    }

    // Abrufen aller Events aus der Datenbank
    final List<EventSQLite> events =
        await DatabaseHelper.instance.queryAllEvents();

    // Überprüfen, ob das Widget noch gemountet ist
    if (_isMounted) {
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
      print('Events erfolgreich geladen.');

      // Zeige eine Snackbar, wenn das Widget noch gemountet ist
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Alle Events wurden aus der lokalen DB in den Kalender übertragen.')),
        );
      }
    }
  }

  // Wenn ein Kalendertag dauerhaft angedrückt wurde.
  List<EventSQLite> _getEventsForDay(DateTime day) {
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
    List<EventSQLite> eventsForDay = _getEventsForDay(selectedDay);

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
      MaterialPageRoute(builder: (context) => const EventListScreenSqlite()),
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

  // Firestore Daten in die lokale DB schreiben
  Future<void> _exportFirestoreToSqflite() async {
    try {
      // Zuerst prüfen, ob die events.db existiert, und ggf. löschen
      String dbPath =
          '/storage/emulated/0/Android/data/de.fludev.ukalender/files/events.db';

      // Prüfen, ob die Datenbank existiert
      bool dbExists = await File(dbPath).exists();

      if (dbExists) {
        // Falls die Datenbank existiert, alle vorhandenen Daten löschen
        Database? db = await DatabaseHelper.instance.database;
        if (db != null) {
          await db.delete('events');
          print('Vorhandene Datenbank wurde geleert.');
        }
      } else {
        // Falls die Datenbank nicht existiert, sie wird automatisch erstellt
        // beim ersten Zugriff durch DatabaseHelper.instance.database
        print('Datenbank existiert noch nicht. Sie wird neu erstellt.');
      }

      // Initialisiere die Datenbank, falls noch nicht geschehen
      Database? db = await DatabaseHelper.instance.database;

      if (db == null) {
        print('Fehler: Datenbank konnte nicht initialisiert werden.');
        return;
      }

      // Referenz zur Firestore-Sammlung
      CollectionReference eventsCollection =
          FirebaseFirestore.instance.collection('events');

      // Abrufen der Dokumente aus Firestore
      QuerySnapshot querySnapshot = await eventsCollection.get();

      // Iteration durch die Dokumente
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Daten des Dokuments als Map<String, dynamic>
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Firestore-Daten in ein EventSqflite-Objekt transformieren
        EventSQLite event = EventSQLite(
          id: doc.id, // Dokument-ID = Event-ID
          title: data['title'],
          body: data['body'],
          eventTime: data['eventTime'],
          localTime: data['localTime'],
          dayBefore: data.containsKey('dayBefore') ? data['dayBefore'] : '',
          notificationIds: EventSQLite.notificationIdsToJson(
              List<int>.from(data['notificationIds'])),
          thirtyMinutesBefore: data.containsKey('thirtyMinutesBefore')
              ? data['thirtyMinutesBefore']
              : '',
          twoHoursBefore:
              data.containsKey('twoHoursBefore') ? data['twoHoursBefore'] : '',
        );

        // Event in die lokale SQLite-Datenbank einfügen
        await DatabaseHelper.instance.insertEvent(event);
      }

      print('Daten erfolgreich aus Firestore importiert.');

      // Zeige eine Snackbar, wenn das Widget noch gemountet ist
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Alle Events wurden aus der Cloud in die lokale DB gespeichert.')),
        );
      }
    } catch (e) {
      print('Fehler beim Importieren der Daten: $e');
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
          // PopupMenuButton hinzufügen
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportFirestoreToSqflite();
              } else if (value == 'logout') {
                // Abmelden
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.sync, color: Colors.orange),
                      SizedBox(width: 8), // Abstand zwischen Icon und Text
                      Text('Datenbankabgleich'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Abmelden'),
                    ],
                  ),
                ),
              ];
            },
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
                      // UTC-Datum in lokales Datum konvertieren
                      final localDay = DateTime(day.year, day.month, day.day);

                      // Aktuelles Datum
                      final now = DateTime.now();

                      // Aktuelles Datum ohne die Uhrzeit
                      final startOfDay = DateTime(now.year, now.month, now.day);

                      // Überprüfen, ob der Tag in der Vergangenheit liegt
                      final isPastDay = localDay.isBefore(startOfDay);

                      // Überprüfen, ob der Tag der aktuelle Tag ist
                      final isToday = localDay.isAtSameMomentAs(startOfDay);

                      // Events für den gewälten Tag abfragen.
                      final dayEvents = _getEventsForDay(localDay);

                      if (dayEvents.isNotEmpty) {
                        // Farbe basierend darauf, ob der Tag in der Vergangenheit, heute oder in der Zukunft liegt
                        final markerColor = isToday
                            ? Colors.redAccent
                            : (isPastDay ? Colors.orange : Colors.green);

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
