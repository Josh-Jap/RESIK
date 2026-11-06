import 'package:flutter/material.dart';
import 'warga_bottom_nav.dart';
import 'warga_dashboard_screen.dart';
import 'warga_laporan_screen.dart';
import 'warga_jadwal_screen.dart';
import 'warga_petugas_screen.dart';
import 'warga_profil_screen.dart';
import 'warga_pembayaran_screen.dart';

class WargaMainScreen extends StatefulWidget {
  final int initialIndex;

  const WargaMainScreen({super.key, this.initialIndex = 0});

  @override
  State<WargaMainScreen> createState() => _WargaMainScreenState();
}

class _WargaMainScreenState extends State<WargaMainScreen> {
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
      WargaDashboardScreen(onNavigateTab: _onTabSelected),
      WargaLaporanScreen(onNavigateTab: _onTabSelected),
      WargaJadwalScreen(onNavigateTab: _onTabSelected),
      WargaPetugasScreen(onNavigateTab: _onTabSelected),
      WargaProfilScreen(onNavigateTab: _onTabSelected),
      WargaPembayaranScreen(onNavigateTab: _onTabSelected),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: WargaBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
