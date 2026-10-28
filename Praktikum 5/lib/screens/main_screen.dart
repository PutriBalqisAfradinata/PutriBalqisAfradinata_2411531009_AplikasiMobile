
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/session_service.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _historyRefreshKey = 0;

  Future<void> _logout() async {
    await SessionService.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;

      // Buat ulang halaman Riwayat setiap kali tab dibuka.
      if (index == 1) {
        _historyRefreshKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(user: widget.user),
      HistoryScreen(
        key: ValueKey(_historyRefreshKey),
        userId: widget.user.id,
      ),
      ProfileScreen(
        user: widget.user,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

    bottomNavigationBar: NavigationBar(
      backgroundColor: const Color(0xFFF5F7FA),
      indicatorColor: const Color(0xFFFFE0A3),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onTabSelected,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: Colors.grey.shade600),
          selectedIcon: const Icon(
            Icons.home,
            color: Color(0xFFFFA000),
          ),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined, color: Colors.grey.shade600),
          selectedIcon: const Icon(
            Icons.receipt_long,
            color: Color(0xFFFFA000),
          ),
          label: 'Riwayat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: Colors.grey.shade600),
          selectedIcon: const Icon(
            Icons.person,
            color: Color(0xFFFFA000),
          ),
          label: 'Profil',
        ),
      ],
    ),

    );
  }
}
