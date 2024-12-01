import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ukalender/models/event_sqlite.dart';

/// Klasse, die eine Datenbank für Benachrichtigungen verwalten soll
class DatabaseHelper {
  // Private Konstruktor, um Singleton-Muster zu implementieren
  // (Verhindert die direkte Instanziierung der Klasse aus anderen Klassen.)
  DatabaseHelper._privateConstructor();

  // Statische Instanz der Klasse, um Singleton-Muster zu gewährleisten
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Statische Variable für die Datenbankinstanz
  // (Speichert die aktuelle Datenbankinstanz.)
  static Database? _database;

  // Getter für die Datenbankinstanz (Gibt die Datenbankinstanz zurück.)
  // Falls die Datenbank noch nicht geöffnet ist, wird sie initialisiert
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database =
        await _initDatabase(); // _initDatabase() öffnet oder erstellt die Datenbankdatei.
    return _database;
  }

  // Methode zur Initialisierung der Datenbank
  Future<Database> _initDatabase() async {
    // Zugriff auf das externe Speicherverzeichnis
    // (storage/emulated/0/Android/data/de.fludev.ukalender/files)
    Directory? directory = await getExternalStorageDirectory();
    print(directory?.path);

    if (directory == null) {
      throw Exception('Externer Speicher ist nicht verfügbar.');
    }

    // Sicherstellen, dass das Verzeichnis existiert
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Pfad zur Datenbankdatei
    String path = join(directory.path, 'events.db');

    // Öffnen oder Erstellen der Datenbank
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Methode zur Erstellung der Datenbanktabelle
  // (Wird aufgerufen, wenn die Datenbank zum ersten Mal erstellt wird.)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        title TEXT,
        body TEXT,
        eventTime TEXT,
        localTime TEXT,
        dayBefore TEXT,
        notificationIds TEXT,
        thirtyMinutesBefore TEXT,
        twoHoursBefore TEXT
      )
    ''');
  }

  /// CRUD-Operationen:

  // Methode zum Einfügen eines Events in die Datenbank
  Future<int> insertEvent(EventSqlite event) async {
    Database? db = await instance.database;
    return await db!.insert('events', event.toMap());
  }

  // Methode zum Abfragen aller Events aus der Datenbank
  Future<List<EventSqlite>> queryAllEvents() async {
    Database? db = await instance.database;
    // Alle Dokumente aus der 'events'-Tabelle abfragen
    List<Map<String, dynamic>> eventMaps = await db!.query('events');
    // Liste von EventSqflite-Objekten aus den Maps erstellen
    return List.generate(eventMaps.length, (index) {
      return EventSqlite.fromMap(eventMaps[index]);
    });
  }

  // Methode zum Aktualisieren eines Events in der Datenbank
  Future<int> updateEvent(EventSqlite event) async {
    Database? db = await instance.database;
    // Event in der 'events'-Tabelle aktualisieren und die Anzahl der
    // aktualisierten Zeilen zurückgeben
    return await db!.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // Methode zum Löschen eines Events aus der Datenbank
  Future<int> deleteEvent(String id) async {
    Database? db = await instance.database;
    // Event aus der 'events'-Tabelle löschen und die Anzahl der
    // gelöschten Zeilen zurückgeben
    return await db!.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
