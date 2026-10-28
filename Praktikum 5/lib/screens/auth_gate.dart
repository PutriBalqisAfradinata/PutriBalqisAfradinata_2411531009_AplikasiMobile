import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _resolveScreen() async {
    final userId = await SessionService.getUserId();
    if (userId == null) return const LoginScreen();
    final user = await AppDatabase.instance.getUserById(userId);
    if (user == null) {
      await SessionService.clear();
      return const LoginScreen();
    }
    return MainScreen(user: user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Aplikasi gagal membuka data lokal. Coba tutup dan buka kembali.\n${snapshot.error}', textAlign: TextAlign.center),
          )));
        }
        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}
