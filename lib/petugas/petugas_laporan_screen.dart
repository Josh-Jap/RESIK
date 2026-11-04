import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import 'petugas_detail_laporan_screen.dart';

class PetugasLaporanScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const PetugasLaporanScreen({super.key, this.onNavigateTab});

  @override
  State<PetugasLaporanScreen> createState() => _PetugasLaporanScreenState();
}

class _PetugasLaporanScreenState extends State<PetugasLaporanScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _reports = [
    {
      'title': 'Sampah menumpuk',
      'location': 'Dekat gerbang Blok B',
      'time': '08.15 · 2 menit lalu',
      'route': 'Rute 1: Wilayah Blok A–C',
      'icon': Icons.delete_outline_rounded,
      'isAccepted': false,
    },
    {
      'title': 'Sampah daur ulang',
      'location': 'Jalan Melati, Blok No. 12',
      'time': '08.40 · 4 menit lalu',
      'route': 'Rute 2: Wilayah Blok D–F',
      'icon': Icons.eco_outlined,
      'isAccepted': false,
    },
    {
      'title': 'Tumpukan sampah',
      'location': 'Taman Utama Griya Asri',
      'time': '09.00 · 12 menit lalu',
      'route': 'Rute 3: Wilayah Taman Utama',
      'icon': Icons.delete_outline_rounded,
      'isAccepted': false,
    },
    {
      'title': 'Sampah organik',
      'location': 'Blok A, No. 12',
      'time': '09.15 · 27 menit lalu',
      'route': 'Rute 1: Wilayah Blok A–C',
      'icon': Icons.delete_outline_rounded,
      'isAccepted': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredReports {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _reports;
    return _reports.where((r) {
      return (r['title'] as String).toLowerCase().contains(query) ||
          (r['location'] as String).toLowerCase().contains(query) ||
          (r['route'] as String).toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredReports;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      children: const [
                        Text(
                          'Laporan Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, // #252A27
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Periksa aduan warga sebelum di lokasi dan ditangani oleh tim pengangkut.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary, // #7FA68C
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

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBg,
                  hintText: 'Cari laporan...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Section: Daftar laporan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar laporan',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.badgeDiprosesBg, // #FFF4D8
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Diproses',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.badgeDiprosesText, // #D69E2E
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // List of reports
              ...List.generate(list.length, (idx) {
                final item = list[idx];
                final isAccepted = item['isAccepted'] as bool;

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PetugasDetailLaporanScreen(
                          reportData: item,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg, // #FFFFFF
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border), // #D9DDD7
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
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
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary, // #252A27
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['location'],
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${item['time']}\n${item['route']}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PetugasDetailLaporanScreen(
                                    reportData: item,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAccepted
                                  ? AppColors.cardSubtle
                                  : AppColors.primaryGreen, // #245C4A
                              foregroundColor: isAccepted
                                  ? AppColors.textPrimary
                                  : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isAccepted ? 'Ditinjau' : 'Terima',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
