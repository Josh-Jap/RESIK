import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import 'admin_housing_regis_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  List<PickupReqModel> _recentReports = [];
  int _activePetugasCount = 0;
  int _completedCount = 0;
  int _pendingCount = 0;
  bool _isLoading = false;
  static bool _hasPromptedHousingOnLogin = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptHousingIfFirstTime();
    });
  }

  void _promptHousingIfFirstTime() async {
    final user = _supabaseService.currentUser;
    // Pop-up hanya muncul jika Admin belum mengatur perumahan.
    // Jika sudah diisi, TIDAK BISA pop-up lagi kecuali lewat menu Profil Admin!
    if (user?.housing == null && user?.idHouse == null) {
      final res = await AdminHousingRegisDialog.show(
        context,
        isMandatory: true, // Wajib diisi! Tidak bisa ditutup tanpa isi data
      );
      if (res != null && mounted) {
        await _loadDashboardData();
        setState(() {});
      }
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _supabaseService.getAllPickupRequests();
      final petugasList = await _supabaseService.getUsersByRole('petugas');

      final completed = reports.where((r) => r.status?.toLowerCase() == 'completed' || r.status?.toLowerCase() == 'selesai').length;
      final pending = reports.length - completed;

      if (mounted) {
        setState(() {
          _recentReports = reports.take(3).toList();
          _completedCount = completed;
          _pendingCount = pending;
          _activePetugasCount = petugasList.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminUser = _supabaseService.currentUser;
    final adminName = adminUser?.nameUsers ?? 'Admin';
    final housingName = adminUser?.housing?.nameHouse.isNotEmpty == true
        ? adminUser!.housing!.nameHouse
        : 'perumahan Anda';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat pagi, $adminName',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary, // #252A27
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Pantau kebersihan $housingName hari ini.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary, // #7FA68C
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Avatar Profile Badge
                    ResikAvatarBadge(
                      onTap: () => widget.onNavigateTab?.call(5),
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
                            'Status Terkini',
                            style: TextStyle(
                              color: Color(0xFFC7EBD6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 3 Stats Columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCol('${_recentReports.length}', 'Laporan aktif'),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _buildStatCol('$_completedCount', 'Sudah selesai'),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _buildStatCol('$_pendingCount', 'Perlu ditangani'),
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
                      onTap: () async {
                        await AdminHousingRegisDialog.show(context);
                        _loadDashboardData();
                      },
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
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                    _buildQuickAction(
                      icon: Icons.calendar_month_outlined,
                      label: 'Atur jadwal',
                      onTap: () => widget.onNavigateTab?.call(3),
                    ),
                    _buildQuickAction(
                      icon: Icons.group_outlined,
                      label: 'Data petugas',
                      onTap: () => widget.onNavigateTab?.call(4),
                    ),
                    _buildQuickAction(
                      icon: Icons.campaign_outlined,
                      label: 'Iuran tahunan',
                      onTap: () => widget.onNavigateTab?.call(6),
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
                      onTap: () => widget.onNavigateTab?.call(1),
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

                // Laporan Cards from Supabase / Seed
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (_recentReports.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada laporan pengaduan masuk.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                    ),
                  )
                else
                  ..._recentReports.map((report) {
                    final isSelesai = report.statusLabel == 'Selesai';
                    final isDiproses = report.statusLabel == 'Diproses';

                    final badgeBg = isSelesai
                        ? AppColors.badgeSelesaiBg
                        : (isDiproses ? AppColors.badgeDiprosesBg : AppColors.badgeBaruBg);
                    final badgeTextColor = isSelesai
                        ? AppColors.badgeSelesaiText
                        : (isDiproses ? AppColors.badgeDiprosesText : AppColors.badgeBaruText);

                    final reporterName = report.user?.nameUsers ?? 'Warga';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildReportCard(
                        icon: isSelesai ? Icons.eco_outlined : Icons.delete_outline_rounded,
                        title: report.category ?? 'Pengaduan Sampah',
                        subtitle: '$reporterName · ${report.description}',
                        badgeText: report.statusLabel,
                        badgeBg: badgeBg,
                        badgeTextColor: badgeTextColor,
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                    );
                  }),

                const SizedBox(height: 22),

                // Section: Petugas hari ini
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Petugas aktif',
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
                      child: Text(
                        '$_activePetugasCount terdaftar',
                        style: const TextStyle(
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
                        workers: '$_activePetugasCount petugas',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                      _buildShiftItem(
                        time: '14.00',
                        task: 'Pembersihan TPS Induk',
                        workers: 'Standby shift',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary, // #7FA68C
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
