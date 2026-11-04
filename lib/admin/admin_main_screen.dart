import 'package:flutter/material.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_dashboard_screen.dart';
import 'admin_laporan_screen.dart';
import 'admin_sampah_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_petugas_screen.dart';
import 'admin_akun_screen.dart';
import 'admin_payment_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialIndex;

  const AdminMainScreen({super.key, this.initialIndex = 0});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
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
      AdminDashboardScreen(onNavigateTab: _onTabSelected),
      AdminLaporanScreen(onNavigateTab: _onTabSelected),
      const AdminSampahScreen(),
      const AdminJadwalScreen(),
      const AdminPetugasScreen(),
      const AdminAkunScreen(),
      const AdminPaymentScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
