// // Die Anweisung ignore_for_file wird verwendet, um bestimmte Code-Analyse-Regeln auszuschließen.
// // In diesem Fall werden die Regeln für public_member_api_docs und sort_constructors_first ausgeschlossen.
// // Dies kann nützlich sein, um bestimmte Warnungen zu ignorieren, die nicht relevant sind oder die Entwicklung behindern.
// // ignore_for_file: public_member_api_docs, sort_constructors_first

// // Importieren des json-Moduls, das zum Arbeiten mit JSON-Daten verwendet wird.
// import 'dart:convert';

// /// Struktur der Notification-Datenbank (Erinnerungen)
// class NotificationModel {
//   final int? id; // Notification-ID (Primärschlüssel)
//   //final int eventId; // Ereignis-ID, bei dem die Notifikation ausgelöst wird.
//   final String title; // Titel der Notification.
//   final String? body; // Bescheibung der Notification
//   final DateTime notificationTime; // Zeitpunkt der Notification

//   // Konstruktor, der die erforderlichen Eigenschaften initialisiert.
//   NotificationModel({
//     this.id, // Die id-Eigenschaft ist optional (nullable).
//     //required this.eventId,
//     required this.title,
//     required this.body,
//     required this.notificationTime,
//   });

//   // *** Generiert mit 'Dart Data Class Generator' ***

//   // Erstellt eine Kopie des aktuellen Notifikationsmodells.
//   NotificationModel copyWith({
//     int? id, // Die id-Eigenschaft ist optional (nullable).
//     //int? eventId,
//     String? title,
//     String? body,
//     DateTime? notificationTime,
//   }) {
//     // Die Eigenschaften werden kopiert, wobei die Optionaleigenschaften optional sind.
//     // '??' ist der "Nullprüfungs-Operator"
//     // Wenn der linke Ausdruck nicht null ist, wird dieser Wert verwendet.
//     // Wenn der linke Ausdruck null ist, wird der Wert der rechten Seite verwendet.
//     return NotificationModel(
//       id: id ?? this.id,
//       //eventId: eventId ?? this.eventId,
//       title: title ?? this.title,
//       body: body ?? this.body,
//       notificationTime: notificationTime ?? this.notificationTime,
//     );
//   }

//   // Wandelt die Eigenschaften in eine Map (key:value) um.
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       //'eventId': eventId,
//       'title': title,
//       'notificationTime': notificationTime.millisecondsSinceEpoch,
//     };
//   }

//   // Wandelt eine Map zurück in ein Notifikationsmodell.
//   factory NotificationModel.fromMap(Map<String, dynamic> map) {
//     return NotificationModel(
//       id: map['id'] != null ? map['id'] as int : null,
//       //eventId: map['eventId'] as int,
//       title: map['title'] as String,
//       body: map['body'] as String,
//       notificationTime:
//           DateTime.fromMillisecondsSinceEpoch(map['notificationTime'] as int),
//     );
//   }

//   // Wandelt das Notifikationsmodell in ein JSON-Objekt um.
//   String toJson() => json.encode(toMap());

//   // Erstellt ein Notifikationsmodell aus einem JSON-Objekt.
//   factory NotificationModel.fromJson(String source) =>
//       NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

//   // Gibt eine Zeichenkette zurück, die die Eigenschaften des Notifikationsmodells beschreibt.
//   @override
//   String toString() {
//     // Die Eigenschaften werden als Zeichenkette dargestellt.
//     return 'NotificationModel(id: $id, title: $title, notificationTime: $notificationTime)';
//   }

//   // Überprüft, ob das aktuelle Notifikationsmodell gleich einem anderen Notifikationsmodell ist.
//   @override
//   bool operator ==(covariant NotificationModel other) {
//     // Die Gleichheit wird basierend auf den Eigenschaften überprüft.
//     if (identical(this, other)) return true;
//     return other.id == id &&
//         //other.eventId == eventId &&
//         other.title == title &&
//         other.body == body &&
//         other.notificationTime == notificationTime;
//   }

//   // Gibt eine Hashcode-Wert zurück, der eindeutig für das Notifikationsmodell ist.
//   @override
//   int get hashCode {
//     // Der Hashcode-Wert wird basierend auf den Eigenschaften berechnet.
//     // Der ^-Operator führt eine bitweise XOR-Operation (exklusives ODER) durch.
//     return id.hashCode ^
//         //eventId.hashCode ^
//         title.hashCode ^
//         body.hashCode ^
//         notificationTime.hashCode;
//   }
// }
