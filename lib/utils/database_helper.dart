import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukalender/models/event_sqflite.dart';

/// Klasse zur Datenbankverwaltung

// Funktion zur Konvertierung eines Event-Objekts in eine Map
Map<String, dynamic> eventToMap(EventSqflite event) {
  return {
    'id': event.id,
    'title': event.title,
    'body': event.body,
    'eventTime': event.eventTime,
    'localTime': event.localTime,
    'notificationTime1': event.notificationTime1,
    'notificationTime2': event.notificationTime2,
    'notificationTime3': event.notificationTime3,
  };
}

// Funktion zur Konvertierung einer Map in ein Event-Objekt
EventSqflite eventFromMap(Map<String, dynamic> map) {
  return EventSqflite(
    id: map['id'],
    title: map['title'],
    body: map['body'],
    eventTime: map['eventTime'],
    localTime: map['localTime'],
    notificationTime1: (map['notificationTime1'] as Timestamp).toDate(),
    notificationTime2: (map['notificationTime2'] as Timestamp).toDate(),
    notificationTime3: (map['notificationTime3'] as Timestamp).toDate(),
  );
}








// *** alt ***


// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/notification_model.dart';

// /// Klasse, die eine Datenbank für Benachrichtigungen verwalten soll
// class DatabaseHelper {
//   // Singelton Pattern (nur eine Instanz der Klasse soll es geben)
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   // Private statische Variable in die, die Datenbank speichert wird.
//   static Database? _database; // (nullable)

//   // Getter, um von außerhalb der Klasse auf die Datenbank zugreifen zu können.
//   // Wenn bereits eine Datenbankinstanz existiert, wird diese zurückgegeben.
//   // Ansonsten wird die Datenbankinstanz über '_initDatabase' erstellt.
//   // Wenn _database null ist wird await _initDatabase() ausgeführt
//   // und das Ergebnis _database zugewiesen.
//   Future<Database> get database async => _database ??= await _initDatabase();

//   // Die App hat einen vordefinierten Ort wo die Nutzdaten gespeichert werden.
//   Future<Database> _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     // Speicherpfad + Datenbank verbinden
//     String path = join(documentsDirectory.path, 'notifications.db');
//     return await openDatabase(
//       path, // Speicherpfad
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   // Tabelle erstellen
//   Future _onCreate(Database db, int version) async {
//     // SQL-Code in einen mehrzeiligen String.
//     await db.execute('''
//       CREATE TABLE notifications (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         eventId INTEGER NOT NULL,
//         title TEXT NOT NULL,
//         body TEXT NOT NULL,
//         notificationTime TEXT NOT NULL
//       )
//     ''');
//   }

//   // Notifications aus der DB auslesen
//   Future<List<NotificationModel>> getNotifications() async {
//     final db = await instance.database;
//     // Datenbankeinträge zwischenspeichern (Tabellenname: 'notification_items')
//     var notificationItems =
//         await db.query('notification_items', orderBy: 'title');
//     // Liste der Notifications erstellen.
//     // 'notificationItems' ist eine Liste die aus Maps besteht.
//     // Aus diesen Maps sollen Notification-Items erstellt werden
//     // und letztendlich eine Liste aus Notification-Items.
//     List<NotificationModel> notificationItemsList = notificationItems.isNotEmpty
//         ? notificationItems
//             .map(
//               // Gehe durch alle Elemente hindurch, wenn 'notificationItems' nicht leer ist.
//               (e) => NotificationModel.fromMap(
//                   e), // Das aktuelle Objekt übergeben (e)
//             ) // Wenn alle Ojekte in NotificationModel umgewandelt wurden
//             .toList() // wird das Ganze in eine Liste umgewandelt.
//         : []; // Leere Liste übergeben, wenn keine Einträge vorhanden waren.
//     return notificationItemsList;
//   }

//   // *** In NotificationModel item stehen die ganzen Eigenschaften, die übergeben werden ***

//   // Notifications in die DB schreiben
//   Future<int> add(NotificationModel item) async {
//     Database db = await instance.database;
//     return await db.insert(
//       'notification_items',
//       item.toMap(),
//     );
//   }

//   // Notification aus der DB löschen
//   Future<int> remove(int id) async {
//     Database db = await instance.database;
//     return await db.delete(
//       'notification_items',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // Notification der DB aktualisieren
//   Future<int> update(NotificationModel item) async {
//     Database db = await instance.database;
//     return await db.update(
//       'notification_items',
//       item.toMap(),
//       where: 'id = ?',
//       whereArgs: [item.id],
//     );
//   }
// }
