import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_detail_laporan_screen.dart';

class PetugasDashboardScreen extends StatefulWidget {
  final Function(int, {String? filter})? onNavigateTab;

  const PetugasDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<PetugasDashboardScreen> createState() => _PetugasDashboardScreenState();
}

class _PetugasDashboardScreenState extends State<PetugasDashboardScreen> {
  List<PickupReqModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      var user = SupabaseService.instance.currentUser;
      if (user != null) {
        final id = user.idUsers;
        if (id != null) {
          final fresh = await SupabaseService.instance.getUserById(id);
          if (fresh != null) user = fresh;
        }
        if (user.housing == null && user.idHouse != null) {
          final h = await SupabaseService.instance.getHousingById(
            user.idHouse!,
          );
          if (h != null) user = user.copyWith(housing: h);
        }
        SupabaseService.instance.setCurrentUser(user);
      }

      final list = await SupabaseService.instance.getAllPickupRequests();
      if (mounted) {
        setState(() {
          _reports = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.instance.currentUser;
    final petugasName = user?.nameUsers.isNotEmpty == true
        ? user!.nameUsers
        : 'Petugas';
    final housingName = user?.housing?.nameHouse ?? 'Perumahan';

    final pendingCount = _reports.where((r) => r.status == 'pending').length;
    final progressCount = _reports
        .where((r) => r.status == 'in_progress')
        .length;
    final completedCount = _reports
        .where((r) => r.status == 'completed')
        .length;

    final latestReport = _reports.isNotEmpty ? _reports.first : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
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
                            'Halo, $petugasName',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Petugas kebersihan aktif di $housingName.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ResikAvatarBadge(
                      onTap: () => widget.onNavigateTab?.call(3),
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
                            mainAxisSize: MainAxisSize.min,
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
                                'Status Tugas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              housingName,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFC7EBD6),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCol(
                            '$pendingCount',
                            'Perlu Diambil',
                            onTap: () => widget.onNavigateTab?.call(1, filter: 'Baru'),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _buildStatCol(
                            '$progressCount',
                            'Sedang Proses',
                            onTap: () => widget.onNavigateTab?.call(1, filter: 'Diproses'),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _buildStatCol(
                            '$completedCount',
                            'Selesai',
                            onTap: () => widget.onNavigateTab?.call(1, filter: 'Selesai'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Section: Akses cepat
                const Text(
                  'Akses cepat',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // 2 Quick Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.assignment_outlined,
                        label: 'Laporan Masuk',
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.calendar_month_outlined,
                        label: 'Jadwal & Tugas',
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Section: Laporan terbaru masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Laporan Masuk Terkini',
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

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                else if (latestReport == null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada laporan pengaduan sampah.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => ResikDetailLaporanScreen(
                                reportData: {
                                  'id': latestReport.idPickup,
                                  'title':
                                      latestReport.category ?? 'Laporan Sampah',
                                  'location':
                                      latestReport.description.contains(' - ')
                                      ? latestReport.description
                                            .split(' - ')
                                            .first
                                      : (latestReport.user?.nameUsers ??
                                            'Area Perumahan'),
                                  'time': 'Baru saja',
                                  'desc': latestReport.description,
                                  'status': latestReport.status,
                                  'photo': latestReport.photo,
                                },
                                role: 'petugas',
                              ),
                            ),
                          )
                          .then((_) => _loadData());
                    },
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cardSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.primaryGreen,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latestReport.category ?? 'Pengaduan Sampah',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  latestReport.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Buka',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String count, String label, {VoidCallback? onTap}) {
    final col = Column(
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

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: col,
        ),
      );
    }
    return col;
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
}
