import 'package:flutter/material.dart';
import '../models/app_user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user, required this.onLogout});
  final AppUser user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna'), backgroundColor: const Color(0xFFFFA000),
  foregroundColor: Colors.white,),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFFFA000),
              child: const Icon(Icons.person, size: 54, color:Color.fromARGB(255, 247, 246, 244)),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.email, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('Nama'), subtitle: Text(user.name)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Email'), subtitle: Text(user.email)),
          ])),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Yakin ingin keluar dari akun ini?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
                    FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Logout')),
                  ],
                ),
              );
              if (confirmed == true) await onLogout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFFA000), minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
