import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_detail_laporan_screen.dart';

class PetugasLaporanScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  final String? initialFilter;

  const PetugasLaporanScreen({
    super.key,
    this.onNavigateTab,
    this.initialFilter,
  });

  @override
  State<PetugasLaporanScreen> createState() => PetugasLaporanScreenState();
}

class PetugasLaporanScreenState extends State<PetugasLaporanScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;
  String _selectedFilter = 'Semua';

  void setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _fetchReports();
  }

  @override
  void didUpdateWidget(covariant PetugasLaporanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != null && widget.initialFilter != oldWidget.initialFilter) {
      setState(() {
        _selectedFilter = widget.initialFilter!;
      });
    }
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      final list = await SupabaseService.instance.getAllPickupRequests();
      if (mounted) {
        setState(() {
          _reports.clear();
          for (final item in list) {
            final isSelesai = item.statusLabel == 'Selesai';
            final isDiproses = item.statusLabel == 'Diproses';
            _reports.add({
              'id': item.idPickup,
              'title': item.category ?? 'Pengaduan Sampah',
              'location': item.description.contains(' - ')
                  ? item.description.split(' - ').first
                  : (item.user?.nameUsers ?? 'Area Perumahan'),
              'time': 'Baru saja',
              'status': item.status ?? 'pending',
              'statusLabel': item.statusLabel,
              'icon': isSelesai
                  ? Icons.eco_outlined
                  : Icons.delete_outline_rounded,
              'isAccepted': isDiproses || isSelesai,
              'photo': item.photo,
              'desc': item.description,
            });
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredReports {
    final query = _searchController.text.trim().toLowerCase();
    return _reports.where((r) {
      final matchesQuery = query.isEmpty ||
          (r['title'] as String).toLowerCase().contains(query) ||
          (r['location'] as String).toLowerCase().contains(query);
      final matchesFilter =
          _selectedFilter == 'Semua' || r['statusLabel'] == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredReports;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchReports,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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

                const SizedBox(height: 12),

                // Filter Tabs (Semua, Baru, Diproses, Selesai)
                Row(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedFilter == 'Selesai'
                            ? AppColors.badgeSelesaiBg
                            : (_selectedFilter == 'Baru'
                                ? AppColors.badgeBaruBg
                                : AppColors.badgeDiprosesBg),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedFilter == 'Semua'
                            ? '${list.length} Laporan'
                            : _selectedFilter,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedFilter == 'Selesai'
                              ? AppColors.badgeSelesaiText
                              : (_selectedFilter == 'Baru'
                                  ? AppColors.badgeBaruText
                                  : AppColors.badgeDiprosesText),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                else if (list.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada laporan pengaduan masuk.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  // List of reports
                  ...List.generate(list.length, (idx) {
                    final item = list[idx];
                    final isAccepted = item['isAccepted'] as bool;

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ResikDetailLaporanScreen(reportData: item, role: 'petugas'),
                          ),
                        ).then((_) => _fetchReports());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg, // #FFFFFF
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                          ), // #D9DDD7
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
                                    item['time'],
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
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
                                      builder: (context) =>
                                          ResikDetailLaporanScreen(
                                            reportData: item,
                                            role: 'petugas',
                                          ),
                                    ),
                                  ).then((_) => _fetchReports());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAccepted
                                      ? AppColors.cardSubtle
                                      : AppColors.primaryGreen, // #245C4A
                                  foregroundColor: isAccepted
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
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
}
