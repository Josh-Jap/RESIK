import 'package:flutter/material.dart';
import 'petugas_bottom_nav.dart';
import 'petugas_dashboard_screen.dart';
import 'petugas_laporan_screen.dart';
import 'petugas_jadwal_screen.dart';
import 'petugas_profil_screen.dart';

class PetugasMainScreen extends StatefulWidget {
  final int initialIndex;

  const PetugasMainScreen({super.key, this.initialIndex = 0});

  @override
  State<PetugasMainScreen> createState() => _PetugasMainScreenState();
}

class _PetugasMainScreenState extends State<PetugasMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      PetugasDashboardScreen(onNavigateTab: _onTabSelected),
      PetugasLaporanScreen(onNavigateTab: _onTabSelected),
      PetugasJadwalScreen(onNavigateTab: _onTabSelected),
      PetugasProfilScreen(onNavigateTab: _onTabSelected),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
