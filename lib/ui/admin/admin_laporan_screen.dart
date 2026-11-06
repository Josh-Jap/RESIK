import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import 'admin_buat_laporan_screen.dart';

class AdminLaporanScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminLaporanScreen({super.key, this.onNavigateTab});

  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  String _selectedFilter = 'Semua';

  // Default initial reports matching the design
  final List<Map<String, dynamic>> _reports = [
    {
      'id': 1,
      'title': 'Sampah menumpuk',
      'location': 'Blok C2',
      'time': '10 mnt lalu',
      'status': 'Baru',
      'icon': Icons.delete_outline_rounded,
      'desc': 'Tumpukan sampah plastik dan rumah tangga menumpuk di depan gang Blok C2.',
    },
    {
      'id': 2,
      'title': 'Tong sampah rusak',
      'location': 'Taman Utama',
      'time': '35 mnt lalu',
      'status': 'Diproses',
      'icon': Icons.delete_outline_rounded,
      'desc': 'Tutup tong sampah umum pecah dan dasar berlubang butuh penggantian.',
    },
    {
      'id': 3,
      'title': 'Daun berserakan',
      'location': 'Jalan Melati',
      'time': '1 jam lalu',
      'status': 'Selesai',
      'icon': Icons.eco_outlined,
      'desc': 'Ranting dan dedaunan pohon peneduh telah disapu dan diangkut petugas.',
    },
    {
      'id': 4,
      'title': 'Limbah liar di selokan',
      'location': 'Blok B4',
      'time': '2 jam lalu',
      'status': 'Baru',
      'icon': Icons.warning_amber_rounded,
      'desc': 'Ada pembuangan limbah sisa material semen di saluran air warga.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchSupabaseReports();
  }

  Future<void> _fetchSupabaseReports() async {
    try {
      final remoteList = await _supabaseService.getAllPickupRequests();
      if (mounted) {
        setState(() {
          _reports.clear();
          for (final item in remoteList) {
            final statusLabel = _mapDbStatusToLabel(item.status);
            final reporter = item.user?.nameUsers ?? 'Warga Griya Asri';
            _reports.add({
              'id': item.idPickup,
              'title': item.category ?? 'Pengaduan Sampah',
              'location': reporter,
              'time': 'Baru saja',
              'status': statusLabel,
              'icon': statusLabel == 'Selesai' ? Icons.eco_outlined : Icons.delete_outline_rounded,
              'desc': item.description,
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    }
  }

  String _mapDbStatusToLabel(String? status) {
    if (status == null) return 'Baru';
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'diproses':
        return 'Diproses';
      case 'completed':
      case 'selesai':
        return 'Selesai';
      default:
        return 'Baru';
    }
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedFilter == 'Semua') {
      return _reports;
    }
    return _reports.where((r) => r['status'] == _selectedFilter).toList();
  }

  void _showReportDetailModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusBadge(item['status']),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item['location']} · ${item['time']}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                item['desc'] ?? 'Tidak ada deskripsi tambahan.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ubah Status Pengaduan:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatusActionButton('Baru', item, ctx),
                const SizedBox(width: 8),
                _buildStatusActionButton('Diproses', item, ctx),
                const SizedBox(width: 8),
                _buildStatusActionButton('Selesai', item, ctx),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActionButton(
      String status, Map<String, dynamic> item, BuildContext modalCtx) {
    final isCurrent = item['status'] == status;
    return Expanded(
      child: OutlinedButton(
        onPressed: () async {
          setState(() {
            item['status'] = status;
          });
          final id = item['id'];
          if (id != null) {
            final dbStatus = status == 'Diproses'
                ? 'in_progress'
                : (status == 'Selesai' ? 'completed' : 'pending');
            await _supabaseService.updatePickupStatus(id, dbStatus);
          }
          if (mounted) {
            Navigator.of(modalCtx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status diubah ke "$status"'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isCurrent ? AppColors.primaryGreen : Colors.white,
          foregroundColor:
              isCurrent ? Colors.white : AppColors.textPrimary,
          side: BorderSide(
            color: isCurrent ? AppColors.primaryGreen : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReports;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_laporan_admin',
        onPressed: () async {
          final res = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const AdminBuatLaporanScreen(),
            ),
          );
          if (res == true) {
            _fetchSupabaseReports();
          }
        },
        backgroundColor: AppColors.primaryGreen,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Laporan Warga',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pantau dan atasi pengaduan kebersihan hari ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Avatar Profile Badge
                  ResikAvatarBadge(
                    onTap: () => widget.onNavigateTab?.call(5),
                  ),
                ],
              ),
            ),

            // Filter Tabs (Semua, Baru, Diproses, Selesai)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterTab('Semua'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Baru'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Diproses'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Selesai'),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // List of Reports
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tidak ada laporan status "$_selectedFilter"',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return InkWell(
                          onTap: () => _showReportDetailModal(item),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: AppColors.primaryGreen,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item['location']} · ${item['time']}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(item['status']),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'Baru':
        bg = AppColors.badgeBaruBg;
        text = AppColors.badgeBaruText;
        break;
      case 'Diproses':
        bg = AppColors.badgeDiprosesBg;
        text = AppColors.badgeDiprosesText;
        break;
      case 'Selesai':
        bg = AppColors.badgeSelesaiBg;
        text = AppColors.badgeSelesaiText;
        break;
      default:
        bg = AppColors.cardSubtle;
        text = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
