import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import 'warga_buat_laporan_screen.dart';
import 'warga_join_dialog.dart';

class WargaDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const WargaDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Selamat pagi, Warga',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, // #252A27
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pantau kebersihan Griya Asri hari ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary, // #7FA68C
                        ),
                      ),
                    ],
                  ),
                  ResikAvatarBadge(
                    onTap: () => onNavigateTab?.call(4), // Tab Akun
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Green Summary Card (#245C4A)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen, // #245C4A
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Top row: status indicator & date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accentMint, // #83EBAB
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Lingkungan terkendali',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Jumat, 25 Sep',
                          style: TextStyle(
                            color: Color(0xFFC7EBD6),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3 Stat Columns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('12', 'Laporan warga'),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        _buildStatCol('8', 'Sudah selesai'),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        _buildStatCol('4', 'Perlu ditangani'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Section: Aksi cepat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aksi cepat',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, // #252A27
                    ),
                  ),
                  InkWell(
                    onTap: () => WargaJoinDialog.show(context),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.group_add_outlined,
                          size: 15,
                          color: AppColors.primaryGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+ Join Perumahan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3 Quick Action Cards
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.edit_note_rounded,
                      label: 'Buat laporan',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WargaBuatLaporanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Jadwal pengangkutan',
                      onTap: () => onNavigateTab?.call(2), // Tab Jadwal
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.credit_card_outlined,
                      label: 'Payment',
                      onTap: () => onNavigateTab?.call(5), // Tab Payment
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Section: Jadwal hari ini
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal hari ini',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => onNavigateTab?.call(2),
                    child: const Text(
                      'Lihat jadwal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Schedule Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg, // #FFFFFF
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border), // #D9DDD7
                ),
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    _buildShiftItem(
                      time: '08.00',
                      task: 'Angkut sampah - Blok A–C',
                      workers: 'Selesai',
                      isDone: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    _buildShiftItem(
                      time: '14.00',
                      task: 'Bersihkan taman utama',
                      workers: 'Diproses',
                      isDone: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Section: Laporan saya
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laporan saya',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => onNavigateTab?.call(1), // Tab Laporan
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Report Card 1
              _buildReportCard(
                icon: Icons.delete_outline_rounded,
                title: 'Sampah menumpuk',
                subtitle: 'Dekat gerbang Blok B · 10 mnt lalu',
                badgeText: 'Baru',
                badgeBg: AppColors.badgeBaruBg,
                badgeTextColor: AppColors.badgeBaruText,
                onTap: () => onNavigateTab?.call(1),
              ),
              const SizedBox(height: 8),
              // Report Card 2
              _buildReportCard(
                icon: Icons.delete_outline_rounded,
                title: 'Tong sampah penuh',
                subtitle: 'Taman Utama · 35 mnt lalu',
                badgeText: 'Diproses',
                badgeBg: AppColors.badgeDiprosesBg,
                badgeTextColor: AppColors.badgeDiprosesText,
                onTap: () => onNavigateTab?.call(1),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC7EBD6),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftItem({
    required String time,
    required String task,
    required String workers,
    required bool isDone,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.cardSubtle,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            task,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDone ? AppColors.badgeSelesaiBg : AppColors.badgeDiprosesBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            workers,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isDone ? AppColors.badgeSelesaiText : AppColors.badgeDiprosesText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg, // #FFFFFF
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border), // #D9DDD7
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cardSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
