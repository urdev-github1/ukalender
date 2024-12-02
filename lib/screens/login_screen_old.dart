// import 'package:flutter/material.dart';
// import '../utils/auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Eingabefelder vorbesetzen
//     // _emailController.text = 'x@y.z';
//     // _passwordController.text = 'xyz';
//   }

//   Future<void> _login() async {
//     final email = _emailController.text;
//     final password = _passwordController.text;
//     final user = await _authService.signInWithEmailAndPassword(email, password);
//     if (!mounted) return;
//     if (user != null) {
//       Navigator.pushReplacementNamed(context, '/calendar');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Fehler bei der Anmeldung")),
//       );
//     }
//   }

//   Future<void> _register() async {
//     final email = _emailController.text;
//     final password = _passwordController.text;
//     final user =
//         await _authService.registerWithEmailAndPassword(email, password);
//     if (!mounted) return;
//     if (user != null) {
//       Navigator.pushReplacementNamed(context, '/calendar');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Fehler bei der Registrierung")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login / Registrierung")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: "Passwort"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text("Anmelden"),
//             ),
//             ElevatedButton(
//               onPressed: _register,
//               child: const Text("Registrieren"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
