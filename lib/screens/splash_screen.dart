import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Splashescreen, der beim Start der App angezeigt wird. Er überprüft, ob ein Benutzer
/// angemeldet ist, und leitet dann entweder zur Hauptseite oder zur Login-Seite weiter.
class SplashScreen extends StatefulWidget {
  // Konstrktor
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Der State der SplashScreen-Klasse
class _SplashScreenState extends State<SplashScreen> {
  // Überschreibt die initState-Methode, die aufgerufen wird, wenn der State initialisiert wird
  @override
  void initState() {
    super.initState();
    // Fügt einen Callback hinzu, der ausgeführt wird, nachdem das Widget eingebaut wurde
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ruft die _checkAuthStatus-Methode auf, um den Authentifizierungsstatus zu überprüfen
      _checkAuthStatus();
    });
  }

  // Methode, die den Authentifizierungsstatus überprüft und die Navigation anpasst
  Future<void> _checkAuthStatus() async {
    // Holt den aktuellen Benutzer von FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Benutzer ist eingeloggt, leite zur Hauptseite weiter
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Benutzer ist nicht eingeloggt, leite zur Login-Seite weiter
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Überschreibt die build-Methode, um das UI des Splashescreens zu erstellen
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
