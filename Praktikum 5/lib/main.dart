import 'package:flutter/material.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/transaction_detail_screen.dart';
import 'models/transaction_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  static const Color primaryColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGate(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const AuthGate(),
        '/add': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as int?;
          if (userId == null) return const AuthGate();
          return AddTransactionScreen(userId: userId);
        },
        '/detail': (context) {
          final transaction = ModalRoute.of(context)?.settings.arguments;
          if (transaction is! TransactionModel) return const AuthGate();
          return TransactionDetailScreen(transaction: transaction);
        },
      },
    );
  }
}
