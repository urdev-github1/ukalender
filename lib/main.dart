import 'package:flutter/material.dart';
// // Für initializeDateFormatting
// import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/start_screen.dart';
import '../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // // Gebietsschema: Initialisiere für Deutsch
  // await initializeDateFormatting('de', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalender App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),

      // Festlegung der Standardsprache und -region für die ganze App
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

      home: const StartScreen(),
    );
  }
}
