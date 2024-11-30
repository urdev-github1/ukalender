import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/event_storage.dart';
import '../utils/notification_service.dart';

/// Eingabemaske für die Eventerstellung
class AddEventDialog extends StatefulWidget {
  // Selektierter Tag (siehe Methode _onDaySelected in calendar_screen.dart)
  final DateTime selectedDay;

  // Konstruktor
  const AddEventDialog({super.key, required this.selectedDay});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  // Textfeld-Controller für den Titel und die Beschreibung
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Tag/Uhrzeit des einzugebenen Events
  DateTime _selectedDate = DateTime.now();

  // Checkbox-Status für die Erinnerungen (Notification)
  bool _notify1Day = false;
  bool _notify2Hours = false;
  bool _notify30Minutes = false;

  // Instanzen erstellen
  final EventStorage eventStorage = EventStorage();
  final NotificationService _notificationService = NotificationService();

  //
  @override
  void initState() {
    super.initState();
    // Setzt das Datum auf den ausgewählten Tag
    _selectedDate = widget.selectedDay;
  }

  //
  Future<void> _saveToDatabase() async {
    final String title = _titleController.text;
    final String body = _bodyController.text;
    final DateTime notificationDateTime = _selectedDate;
    List<int> notificationIds = [];

    final String notificationDate =
        DateFormat('dd.MM.yyyy').format(notificationDateTime);
    final String notificationTime =
        DateFormat('HH:mm').format(notificationDateTime);

    // Berechnung der Benachrichtigungszeiten
    final dayBefore = _notify1Day
        ? notificationDateTime.subtract(const Duration(days: 1))
        : null;
    final twoHoursBefore = _notify2Hours
        ? notificationDateTime.subtract(const Duration(hours: 2))
        : null;
    final thirtyMinutesBefore = _notify30Minutes
        ? notificationDateTime.subtract(const Duration(minutes: 30))
        : null;

    // Lokale Benachrichtigungen planen (1 Tag vorher).
    if (_notify1Day && dayBefore != null) {
      // Generiert eine zufällige ID
      int randomId = Random().nextInt(1000000);
      notificationIds.add(randomId);
      _notificationService.scheduleNotification(
        id: randomId,
        title: '$title (morgen)',
        body: 'Am $notificationDate um $notificationTime Uhr.',
        scheduledTime: dayBefore,
      );
    }

    // Lokale Benachrichtigungen planen (2 Stunden vorher).
    if (_notify2Hours && twoHoursBefore != null) {
      int randomId = Random().nextInt(1000000);
      notificationIds.add(randomId);
      _notificationService.scheduleNotification(
        id: randomId,
        title: title,
        body: 'Heute in 2 Std. um $notificationTime Uhr.',
        scheduledTime: twoHoursBefore,
      );
    }

    // Lokale Benachrichtigungen planen (30 Minuten vorher).
    if (_notify30Minutes && thirtyMinutesBefore != null) {
      int randomId = Random().nextInt(1000000);
      notificationIds.add(randomId);
      _notificationService.scheduleNotification(
        id: randomId,
        title: title,
        body: 'Heute in 30 Min. um $notificationTime Uhr.',
        scheduledTime: thirtyMinutesBefore,
      );
    }

    // Speichern des Events mit Benachrichtigungs-IDs in Database.
    // Ausgeführt über event_Storage.dart.
    await eventStorage.saveEvent(
      title: title,
      body: body,
      eventDateTime: notificationDateTime,
      dayBefore: dayBefore,
      twoHoursBefore: twoHoursBefore,
      thirtyMinutesBefore: thirtyMinutesBefore,
      // Übergebe die IDs der Benachrichtigungen
      notificationIds: notificationIds,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // Widget-Tree des Dialogs (Eindabelayout)
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Eingabefeld für den Titel
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Ereignis Titel"),
              ),

              const SizedBox(height: 10),

              // Eingabefeld für die Beschreibung
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: "Beschreibung"),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Text für die Uhrzeitauswahl
              const Text("Uhrzeit auswählen:"),
              const SizedBox(height: 10),

              // Button, der den Time Picker Dialog öffnet
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );

                  // Die Zeit, die ausgewählt wurde
                  if (pickedTime != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                },
                child: const Text("Zeit auswählen"),
              ),

              const SizedBox(height: 20),

              // Notification 1 Tag vorher
              CheckboxListTile(
                title: const Text("Alarm: 1 Tag vorher"),
                value: _notify1Day,
                onChanged: (bool? value) {
                  setState(() {
                    _notify1Day = value ?? false;
                  });
                },
              ),

              // Notification 2 Stunden vorher
              CheckboxListTile(
                title: const Text("Alarm: 2 Std. vorher"),
                value: _notify2Hours,
                onChanged: (bool? value) {
                  setState(() {
                    _notify2Hours = value ?? false;
                  });
                },
              ),

              // Notification 30 Minuten vorher
              CheckboxListTile(
                title: const Text("Alarm: 30 Min. vorher"),
                value: _notify30Minutes,
                onChanged: (bool? value) {
                  setState(() {
                    _notify30Minutes = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Schaltflächen
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Abbrechen
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Abbrechen"),
                  ),

                  // Event in Database abspeichern
                  TextButton(
                    onPressed: () {
                      if (_titleController.text.isNotEmpty) {
                        //
                        _saveToDatabase();
                        Navigator.pop(context); // Dialog schließen
                      }
                    },
                    child: const Text("Hinzufügen"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
