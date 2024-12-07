import 'dart:math';
import 'package:intl/intl.dart';
import '../utils/event_storage_firestore.dart';
import '../utils/notification_service.dart';

/// Notification reaktivieren
class NotificationRestorationService {
  // Speichern und Abrufen von Event-Daten aus Firestore
  final EventStorageFirestore eventStorageFirestore;
  // Verwalten von Benachrichtigungen
  final NotificationService notificationService;

  // // Konstruktor
  NotificationRestorationService(
      this.eventStorageFirestore, this.notificationService);

  // Hilfsmethode zur Formatierung eines Datums
  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);
  // Hilfsmethode zur Formatierung einer Uhrzeit
  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  // Helfermethode zur Kombination von Datum und Uhrzeit
  DateTime _combineDateWithLocalTime(DateTime date, String localTime) {
    try {
      // Stunden:Minuten
      final parts = localTime.split(':').map(int.parse).toList();
      return DateTime(date.year, date.month, date.day, parts[0], parts[1]);
    } catch (e) {
      throw FormatException("Ungültiges Zeitformat: $localTime");
    }
  }

  // Version einzelne Notification reaktivieren
  Future<void> restoreNotificationsForEvent(String eventId) async {
    try {
      // Abrufen der Event-Daten aus Firestore
      final eventData = await eventStorageFirestore.getEventById(eventId);

      // Überprüfen, ob die Event-Daten vorhanden sind
      if (eventData == null) throw Exception("Event-Daten nicht verfügbar");

      // Extrahieren des Titels des Events aus den Event-Daten
      final String title = eventData['title'];

      // Datum aus den Event-Daten als Datums-Objekt
      final DateTime eventDate =
          DateTime.parse(eventData['eventTime'] as String);

      // Uhrzeit ("HH:mm") aus den Event-Daten
      final String localTime = eventData['localTime'] as String;

      // Datum + Uhrzeit
      final DateTime eventTime =
          _combineDateWithLocalTime(eventDate, localTime);

      // Einen Tag vor dem Termin
      final DateTime? dayBefore = eventData['dayBefore'] != null
          ? _combineDateWithLocalTime(
              DateTime.parse(eventData['dayBefore'] as String),
              localTime,
            )
          : null;

      // 2 Std. vor dem Termin
      final DateTime? twoHoursBefore = eventData['twoHoursBefore'] != null
          ? _combineDateWithLocalTime(
              DateTime.parse(eventData['twoHoursBefore'] as String),
              localTime,
            )
          : null;

      // 30 Min. vor dem Termin
      final DateTime? thirtyMinutesBefore =
          eventData['thirtyMinutesBefore'] != null
              ? _combineDateWithLocalTime(
                  DateTime.parse(eventData['thirtyMinutesBefore'] as String),
                  localTime,
                )
              : null;

      // Planen der Benachrichtigungen, falls die geplanten Zeiten in der Zukunft liegen
      if (dayBefore != null && dayBefore.isAfter(DateTime.now())) {
        await notificationService.reactivateNotification(
          id: Random().nextInt(1000000), // Generiere neue ID
          title: '$title (morgen)',
          body:
              'Am ${_formatDate(eventTime)} um ${_formatTime(eventTime)} Uhr.',
          scheduledTime: dayBefore, // Geplante Zeit der Benachrichtigung
        );
      }

      if (twoHoursBefore != null && twoHoursBefore.isAfter(DateTime.now())) {
        await notificationService.reactivateNotification(
          id: Random().nextInt(1000000),
          title: title,
          body: 'Heute in 2 Std. um ${_formatTime(eventTime)} Uhr.',
          scheduledTime: twoHoursBefore,
        );
      }

      if (thirtyMinutesBefore != null &&
          thirtyMinutesBefore.isAfter(DateTime.now())) {
        await notificationService.reactivateNotification(
          id: Random().nextInt(1000000),
          title: title,
          body: 'Heute in 30 Min. um ${_formatTime(eventTime)} Uhr.',
          scheduledTime: thirtyMinutesBefore,
        );
      }
      print(
          "Benachrichtigungen für Event $eventId erfolgreich wiederhergestellt.");
    } catch (e) {
      print("Fehler beim Wiederherstellen der Benachrichtigungen: $e");
      rethrow;
    }
  }
}
