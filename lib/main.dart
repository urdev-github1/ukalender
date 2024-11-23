import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../firebase_options.dart';
import '../screens/calendar_screen.dart';
import '../screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  //await NotificationService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Erstellung einer MaterialApp-Instanz
    return MaterialApp(
      // Deaktivierung des Debug-Banners
      debugShowCheckedModeBanner: false,
      // Titel der App
      title: 'Kalender App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),

      // Festlegung der Standardsprache und -region
      locale: const Locale('de', 'DE'),
      // Liste der unterstützten Sprachen und Regionen
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],

      // Delegaten für die Lokalisierung
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Login-Screen.............. Startseite der App
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const CalendarScreen(); // Authentifizierter Nutzer
            } else {
              return const LoginScreen(); // Nicht authentifizierter Nutzer
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),

      //
      routes: {
        '/calendar': (context) => const CalendarScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
