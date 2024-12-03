import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/auth_service.dart';

/// Anmelde-/Registrierungsoberfläche für eine Flutter-Anwendung,
/// die Firebase Auth für die Authentifizierung verwendet.
class LoginScreen extends StatefulWidget {
  // Konstruktor
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Definition des Zustands der LoginScreen-Klasse
class _LoginScreenState extends State<LoginScreen> {
  // Instanz des AuthService, um Authentifizierungsfunktionen bereitzustellen
  final AuthService _authService = AuthService();
  // TextEditingControllers für die Eingabe der E-Mail und des Passworts
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Zustandsvariable, um den Ladezustand anzuzeigen oder zu verstecken
  bool _isLoading = false;

  // Methode zur Authentifizierung, die eine Authentifizierungsmethode als Callback akzeptiert
  Future<void> _authenticate(Future<User?> Function() authMethod) async {
    // Setzen des Ladezustands auf true, um den Ladeindikator anzuzeigen
    setState(() {
      _isLoading = true;
    });

    try {
      // Aufruf der übergebenen Authentifizierungsmethode und Warten auf das Ergebnis
      final user = await authMethod();
      // Überprüfen, ob der Widget immer noch eingehängt ist
      if (!mounted) return;
      // Wenn der Benutzer erfolgreich authentifiziert wurde, navigiere zur Home-Seite
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Fehlermeldung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        // Ladeindikator ausblenden
        _isLoading = false;
      });
    }
  }

  // Methode zur Abmeldung des Benutzers
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erfolgreich abgemeldet")),
      );
      // Nach der Abmeldung bleibt der Nutzer auf der Login-Seite
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Abmelden: $e")),
      );
    }
  }

  // Überschreiben der build-Methode, um die UI der LoginScreen-Klasse zu erstellen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login / Registrierung"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut, // Abmeldeaktion
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Passwort"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      // Schaltfläche zum Anmelden, die die _authenticate-Methode mit der
                      // Anmelde-Methode des AuthService aufruft
                      ElevatedButton(
                        onPressed: () => _authenticate(
                            () => _authService.signInWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                )),
                        child: const Text("Anmelden"),
                      ),
                      // Schaltfläche zum Registrieren, die die _authenticate-Methode mit der
                      // Registrierungsmethode des AuthService aufruft
                      ElevatedButton(
                        onPressed: () => _authenticate(
                            () => _authService.registerWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                )),
                        child: const Text("Registrieren"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
