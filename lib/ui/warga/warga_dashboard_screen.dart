import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import '../../backend/backend.dart';
import 'warga_buat_laporan_screen.dart';
import 'warga_join_dialog.dart';

class WargaDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const WargaDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<WargaDashboardScreen> createState() => _WargaDashboardScreenState();
}

class _WargaDashboardScreenState extends State<WargaDashboardScreen> {
  String _userName = 'Warga';
  String _housingName = 'lingkungan Anda';
  int _totalLaporan = 0;
  int _selesai = 0;
  int _diproses = 0;
  List<PickupReqModel> _recentRequests = [];
  static bool _hasPromptedJoinOnLogin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptJoinHousingIfFirstTime();
    });
  }

  void _promptJoinHousingIfFirstTime() async {
    final user = SupabaseService.instance.currentUser;
    // Pop-up hanya muncul jika Warga belum bergabung ke perumahan manapun.
    // Jika sudah bergabung, TIDAK BISA pop-up lagi kecuali lewat menu Profil Warga!
    if (user?.housing == null && user?.idHouse == null) {
      final res = await WargaJoinDialog.show(
        context,
        isMandatory: true, // Wajib diisi! Tidak bisa ditutup tanpa join
      );
      if (res != null && mounted) {
        await _loadData();
        setState(() {});
      }
    }
  }

  Future<void> _loadData() async {
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      final name = user.nameUsers.isNotEmpty
          ? user.nameUsers
          : (user.email?.split('@').first ?? 'Warga');
      final houseName = user.housing?.nameHouse.isNotEmpty == true
          ? user.housing!.nameHouse
          : 'lingkungan Anda';
      final userId = user.idUsers ?? 5;
      final requests =
          await SupabaseService.instance.getPickupRequestsByUserId(userId);
      if (mounted) {
        setState(() {
          _userName = name;
          _housingName = houseName;
          _totalLaporan = requests.length;
          _recentRequests = requests.take(3).toList();
          _selesai = requests
              .where((r) =>
                  r.status == 'completed' || r.status == 'selesai')
              .length;
          _diproses = requests
              .where((r) =>
                  r.status == 'in_progress' || r.status == 'diproses')
              .length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final int hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Selamat pagi';
    } else if (hour < 15) {
      greeting = 'Selamat siang';
    } else if (hour < 19) {
      greeting = 'Selamat sore';
    } else {
      greeting = 'Selamat malam';
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, $_userName',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Pantau kebersihan $_housingName hari ini.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ResikAvatarBadge(
                      onTap: () => widget.onNavigateTab?.call(4),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Green Summary Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentMint,
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
                          Text(
                            '${now.day} ${_monthName(now.month)}',
                            style: const TextStyle(
                              color: Color(0xFFC7EBD6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCol('$_totalLaporan', 'Laporan warga'),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _buildStatCol('$_selesai', 'Sudah selesai'),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _buildStatCol('$_diproses', 'Diproses'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Action Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.assignment_add,
                        label: 'Buat\nLaporan',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const WargaBuatLaporanScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.calendar_month_rounded,
                        label: 'Jadwal\nPengambilan',
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.payment_rounded,
                        label: 'Bayar\nIuran',
                        onTap: () => widget.onNavigateTab?.call(5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.home_rounded,
                        label: 'Join\nPerumahan',
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const WargaJoinDialog(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Laporan terbaru header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Laporan Terbaru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNavigateTab?.call(1),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_recentRequests.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada laporan pengaduan.\nTekan tombol "Buat Laporan" untuk menyampaikan masalah kebersihan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                else
                  ..._recentRequests.map((req) {
                    final isSelesai = req.statusLabel == 'Selesai';
                    final isDiproses = req.statusLabel == 'Diproses';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildReportCard(
                        icon: isSelesai
                            ? Icons.eco_outlined
                            : Icons.delete_outline_rounded,
                        title: req.category ?? 'Laporan Sampah',
                        subtitle: '${req.description} · ${req.statusLabel}',
                        badgeText: req.statusLabel,
                        badgeBg: isSelesai
                            ? AppColors.badgeSelesaiBg
                            : (isDiproses
                                ? AppColors.badgeDiprosesBg
                                : AppColors.badgeBaruBg),
                        badgeTextColor: isSelesai
                            ? AppColors.badgeSelesaiText
                            : (isDiproses
                                ? AppColors.badgeDiprosesText
                                : AppColors.badgeBaruText),
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  Widget _buildStatCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFFC7EBD6),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
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
            Icon(icon, color: AppColors.primaryGreen, size: 24),
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
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
