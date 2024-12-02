import 'package:firebase_auth/firebase_auth.dart';

/// Klasse, die Methoden für die Authentifizierung mit Firebase bereitstellt.
class AuthService {
  // Instanz von FirebaseAuth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Methode zur Anmeldung eines Benutzers mit E-Mail und Passwort.
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Versucht, den Benutzer mit den angegebenen E-Mail-Adresse und Passwort anzumelden.
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Gibt das User-Objekt des angemeldeten Benutzers zurück, falls die Anmeldung erfolgreich war.
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Fehler bei der Anmeldung';
    }
  }

  // Methode zur Registrierung eines neuen Benutzers mit E-Mail und Passwort.
  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      // Versucht, einen neuen Benutzer mit den angegebenen E-Mail-Adresse und Passwort zu registrieren.
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Gibt das User-Objekt des neu registrierten Benutzers zurück, falls die Registrierung erfolgreich war.
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Fehler bei der Registrierung';
    }
  }
}
