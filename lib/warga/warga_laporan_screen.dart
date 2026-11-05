import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import 'warga_buat_laporan_screen.dart';

class WargaLaporanScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const WargaLaporanScreen({super.key, this.onNavigateTab});

  @override
  State<WargaLaporanScreen> createState() => _WargaLaporanScreenState();
}

class _WargaLaporanScreenState extends State<WargaLaporanScreen> {
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _reports = [
    {
      'title': 'Sampah menumpuk',
      'location': 'Dekat gerbang Blok B',
      'time': '10 mnt lalu',
      'status': 'Baru',
      'icon': Icons.delete_outline_rounded,
    },
    {
      'title': 'Tong sampah penuh',
      'location': 'Taman Utama Griya Asri',
      'time': '35 mnt lalu',
      'status': 'Diproses',
      'icon': Icons.delete_outline_rounded,
    },
    {
      'title': 'Daun berserakan',
      'location': 'Jalan Melati, Blok C',
      'time': '1 jam lalu',
      'status': 'Selesai',
      'icon': Icons.eco_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'Semua') return _reports;
    return _reports.where((r) => r['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const WargaBuatLaporanScreen(),
            ),
          );
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Laporan Saya',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, // #252A27
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pantau tindak lanjut pengaduan yang Anda sampaikan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary, // #7FA68C
                          ),
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
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada laporan status "$_selectedFilter"',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg, // #FFFFFF
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border), // #D9DDD7
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary, // #252A27
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
        onTap: () => setState(() => _selectedFilter = label),
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
