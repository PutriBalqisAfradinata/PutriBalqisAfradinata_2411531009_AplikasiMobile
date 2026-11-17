import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: SwitchListTile(
        title: const Text('Mode gelap'),
        value: isDark,
        onChanged: (value) {
          context.read<ThemeProvider>().toggleTheme(value);
        },
      ),
    );
  }
}