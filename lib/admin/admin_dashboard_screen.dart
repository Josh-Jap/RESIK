import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import 'admin_housing_regis_dialog.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

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
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Selamat pagi, Admin',
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
                  // Avatar Profile Badge
                  ResikAvatarBadge(
                    onTap: () => onNavigateTab?.call(5),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Summary Card (#245C4A)
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
                        _buildStatCol('12', 'Laporan masuk'),
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
                    onTap: () => AdminHousingRegisDialog.show(context),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.add_home_outlined,
                          size: 15,
                          color: AppColors.primaryGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+ Perumahan',
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

              // 4 Quick Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.assignment_outlined,
                    label: 'Kelola laporan',
                    onTap: () => onNavigateTab?.call(1),
                  ),
                  _buildQuickAction(
                    icon: Icons.calendar_month_outlined,
                    label: 'Atur jadwal',
                    onTap: () => onNavigateTab?.call(3),
                  ),
                  _buildQuickAction(
                    icon: Icons.group_outlined,
                    label: 'Data petugas',
                    onTap: () => onNavigateTab?.call(4),
                  ),
                  _buildQuickAction(
                    icon: Icons.campaign_outlined,
                    label: 'Iuran tahunan',
                    onTap: () => onNavigateTab?.call(6),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Section: Laporan terbaru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laporan terbaru',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => onNavigateTab?.call(1),
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

              // Laporan Cards
              _buildReportCard(
                icon: Icons.delete_outline_rounded,
                title: 'Sampah menumpuk',
                subtitle: 'Blok C2 · 10 mnt lalu',
                badgeText: 'Baru',
                badgeBg: AppColors.badgeBaruBg,
                badgeTextColor: AppColors.badgeBaruText, // #C75C5C
                onTap: () => onNavigateTab?.call(1),
              ),
              const SizedBox(height: 8),
              _buildReportCard(
                icon: Icons.delete_outline_rounded,
                title: 'Tong sampah penuh',
                subtitle: 'Taman Utama · 35 mnt lalu',
                badgeText: 'Diproses',
                badgeBg: AppColors.badgeDiprosesBg, // #FFF4D8
                badgeTextColor: AppColors.badgeDiprosesText, // #D69E2E
                onTap: () => onNavigateTab?.call(1),
              ),
              const SizedBox(height: 8),
              _buildReportCard(
                icon: Icons.eco_outlined,
                title: 'Daun berserakan',
                subtitle: 'Jalan Melati · 1 jam lalu',
                badgeText: 'Selesai',
                badgeBg: AppColors.badgeSelesaiBg,
                badgeTextColor: AppColors.badgeSelesaiText, // #245C4A
                onTap: () => onNavigateTab?.call(1),
              ),

              const SizedBox(height: 22),

              // Section: Petugas hari ini
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Petugas hari ini',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '4 aktif',
                      style: TextStyle(
                        fontSize: 11,
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
                      workers: '4 orang',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    _buildShiftItem(
                      time: '14.00',
                      task: 'Bersihkan taman utama',
                      workers: '2 orang',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.cardBg, // #FFFFFF
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border), // #D9DDD7
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen, // #245C4A
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary, // #252A27
              ),
            ),
          ],
        ),
      ),
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
                      color: AppColors.textPrimary, // #252A27
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary, // #7FA68C
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

  Widget _buildShiftItem({
    required String time,
    required String task,
    required String workers,
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
        Text(
          workers,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
