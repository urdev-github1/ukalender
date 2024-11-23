import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Methoden zur Verwaltung von lokalen Benachrichtigungen.
class NotificationService {
  // Instanz des lokalen Benachrichtigungsplugin
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Konstruktor zur Initialisierung des NotificationService
  NotificationService() {
    _initialize();
  }

  // Methode zur Initialisierung der Benachrichtigungsanpassungen
  void _initialize() {
    // Konfiguration für Android: Initialisierung der Icon-Datei
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Konfiguration für die Initialisierung der Benachrichtigungen
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialisiere die Benachrichtigungsanpassungen
    _localNotificationsPlugin.initialize(initializationSettings);

    // Initialisiere die Zeitzone
    tz.initializeTimeZones();
  }

  // Anzeige einer sofortigen Benachrichtigung (ID, Titel, Body)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Konfiguration für Android: Benachrichtigungskanal
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Instant', // ID des Benachrichtigungskanals
      'Instant_App', // Name des Benachrichtigungskanals
      channelDescription: 'Kanal für sofortige Benachrichtigungen',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: false, // Vibration aktivieren
    );

    // Konfiguration für die Benachrichtigung
    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Zeigt die Benachrichtigung sofort an.
    await _localNotificationsPlugin.show(
      id, // ID der Benachrichtigung
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Anzeige einer geplanten Benachrichtigung (ID, Titel, Body, Zeitpkt.)
  // (Aufruf aus der Datei 'add_event_dialog.dart')
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime, // Zeitpunkt der Benachrichtigung
  }) async {
    // Konfiguration für Android: Benachrichtigungskanal
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Calendar', // ID des Benachrichtigungskanals
      'Calendar_App', // Name des Benachrichtigungskanals
      channelDescription: 'Kanal für geplante Benachrichtigungen.',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: false, // Vibration deaktivieren
    );

    // Konfiguration für die Benachrichtigung
    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Anpassung der Zeitzone des Zeitpunkts
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    // Plant die Benachrichtigung mit Berücksichtigung der Zeitzone.
    await _localNotificationsPlugin.zonedSchedule(
      id, // ID der Benachrichtigung
      title,
      body,
      tzScheduledTime, // Zeitpunkt der Benachrichtigung
      // Konfiguration für die Benachrichtigung
      platformChannelSpecifics,
      // Modus für die Planung der Benachrichtigung
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Interpretiert das geplante Datum als absoluten Zeitpunkt.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Berücksichtigt bei der Planung sowohl den Tag als auch die Uhrzeit.
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  // Lösche eine bestimmte Benachrichtigung
  Future<void> removeNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }

  // Lösche mehrere Benachrichtigungen
  Future<void> removeNotifications(List<int> ids) async {
    for (var id in ids) {
      await _localNotificationsPlugin.cancel(id);
    }
  }

  // Lösche alle ausstehenden Benachrichtigungen
  Future<void> removeAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();
  }

  // Liste aller ausstehenden Benachrichtigungen ausgeben.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotificationsPlugin.pendingNotificationRequests();
  }
}
