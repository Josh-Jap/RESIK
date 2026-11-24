import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import '../../backend/backend.dart';

class AdminSampahScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminSampahScreen({super.key, this.onNavigateTab});

  @override
  State<AdminSampahScreen> createState() => _AdminSampahScreenState();
}

class _AdminSampahScreenState extends State<AdminSampahScreen> {
  // 0: Hari, 1: Minggu, 2: Bulan
  int _selectedPeriod = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _wasteLogs = [];

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    setState(() => _isLoading = true);
    try {
      final logs = await SupabaseService.instance.getAllWasteLogs();
      if (mounted) {
        setState(() {
          _wasteLogs = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFormattedDateInfo(int periodIndex) {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    if (periodIndex == 0) {
      // 1. Hari: "Selasa, 24 November 2026"
      final dayName = days[now.weekday - 1];
      return '$dayName, ${now.day} ${months[now.month - 1]} ${now.year}';
    } else if (periodIndex == 1) {
      // 2. Minggu: "Minggu ke-4 November (23 Nov - 29 Nov 2026)"
      final weekOfMonth = ((now.day - 1) / 7).floor() + 1;
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final startMonthStr = months[startOfWeek.month - 1].substring(0, 3);
      final endMonthStr = months[endOfWeek.month - 1].substring(0, 3);

      return 'Minggu ke-$weekOfMonth ${months[now.month - 1]} (${startOfWeek.day} $startMonthStr - ${endOfWeek.day} $endMonthStr ${now.year})';
    } else {
      // 3. Bulan: "November 2026 (01 Nov - 30 Nov 2026)"
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      final mShort = months[now.month - 1].substring(0, 3);
      return '${months[now.month - 1]} ${now.year} (01 $mShort - $lastDay $mShort ${now.year})';
    }
  }

  Map<String, dynamic> _calculatePeriodData(int periodIndex) {
    final now = DateTime.now();

    List<Map<String, dynamic>> filtered = _wasteLogs.where((log) {
      final dateStr = log['created_at']?.toString();
      if (dateStr == null) return false;
      final logDate = DateTime.tryParse(dateStr);
      if (logDate == null) return false;

      if (periodIndex == 0) {
        // Hari ini
        return logDate.year == now.year &&
            logDate.month == now.month &&
            logDate.day == now.day;
      } else if (periodIndex == 1) {
        // Minggu ini
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return logDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            logDate.isBefore(endOfWeek);
      } else {
        // Bulan ini
        return logDate.year == now.year && logDate.month == now.month;
      }
    }).toList();

    double totalOrg = 0.0;
    double totalNon = 0.0;
    final List<Map<String, String>> rincian = [];

    for (final item in filtered) {
      final org = double.tryParse(item['organik_kg']?.toString() ?? '0') ?? 0.0;
      final non = double.tryParse(item['non_organik_kg']?.toString() ?? '0') ?? 0.0;
      totalOrg += org;
      totalNon += non;

      rincian.add({
        'area': item['area']?.toString() ?? 'Area Komplek',
        'org': '${org.toStringAsFixed(1)} kg',
        'non': '${non.toStringAsFixed(1)} kg',
        'tot': '${(org + non).toStringAsFixed(1)} kg',
      });
    }

    final double totalAll = totalOrg + totalNon;
    final double orgPct = totalAll > 0 ? (totalOrg / totalAll) : 0.5;

    return {
      'date': _getFormattedDateInfo(periodIndex),
      'total': '${totalAll.toStringAsFixed(1)} kg',
      'organik': '${totalOrg.toStringAsFixed(1)} kg',
      'nonOrganik': '${totalNon.toStringAsFixed(1)} kg',
      'ratio': totalAll > 0
          ? 'Rasio: ${(orgPct * 100).toInt()}% Organik · ${((1 - orgPct) * 100).toInt()}% Anorganik'
          : 'Belum ada data penimbangan pada periode ini',
      'organikPct': orgPct,
      'rincian': rincian,
    };
  }

  @override
  Widget build(BuildContext context) {
    final current = _calculatePeriodData(_selectedPeriod);
    final user = SupabaseService.instance.currentUser;
    final housingName = user?.housing?.nameHouse.isNotEmpty == true
        ? user!.housing!.nameHouse
        : 'Griya Asri';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg, // #F5F3EA
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWasteData,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Laporan Sampah',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, // #252A27
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rekap berat sampah - $housingName',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary, // #7FA68C
                          ),
                        ),
                      ],
                    ),
                    ResikAvatarBadge(onTap: () => widget.onNavigateTab?.call(5)),
                  ],
                ),

                const SizedBox(height: 18),

                // Filter Tabs (Hari, Minggu, Bulan)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border), // #D9DDD7
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildTabItem(0, 'Hari'),
                      _buildTabItem(1, 'Minggu'),
                      _buildTabItem(2, 'Bulan'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Date Info Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          current['date'],
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Summary Card (#245C4A)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen, // #245C4A
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top row: Label & scale icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total sampah terkumpul',
                            style: TextStyle(
                              color: Color(0xFFC7EBD6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.scale_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Big weight text
                      Text(
                        current['total'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Organik & Non-Organik breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.eco_rounded,
                                color: AppColors.accentMint, // #83EBAB
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Organik',
                                style: TextStyle(
                                  color: Color(0xFFC7EBD6),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.recycling_rounded,
                                color: Color(0xFFB0D5CE),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Anorganik',
                                style: TextStyle(
                                  color: Color(0xFFC7EBD6),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            current['organik'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            current['nonOrganik'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Ratio Bar with #83EBAB
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 8,
                          child: Row(
                            children: [
                              Expanded(
                                flex: ((current['organikPct'] as double) * 100).toInt().clamp(1, 99),
                                child: Container(
                                  color: AppColors.accentMint,
                                ), // #83EBAB
                              ),
                              Expanded(
                                flex: (100 - ((current['organikPct'] as double) * 100)).toInt().clamp(1, 99),
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        current['ratio'],
                        style: const TextStyle(
                          color: Color(0xFFC7EBD6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Section: Rincian pengumpulan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rincian pengumpulan',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, // #252A27
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Rincian Table Container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg, // #FFFFFF
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border), // #D9DDD7
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Row(
                        children: const [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Area Rute',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'Org / Anorg / Total (kg)',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                      // Table Rows
                      if ((current['rincian'] as List).isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Belum ada hasil penimbangan pada periode ini.\nPetugas dapat menginput hasil timbang dari tab Jadwal.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate((current['rincian'] as List).length, (
                          idx,
                        ) {
                          final row = current['rincian'][idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    row['area']!,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary, // #252A27
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 54,
                                        child: Text(
                                          row['org']!,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 58,
                                        child: Text(
                                          row['non']!,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          row['tot']!,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom note
                const Text(
                  'Rekap ini murni bersumber dari hasil penimbangan rutin armada pengangkut per rute jadwal komplek.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent, // #245C4A
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary, // #7FA68C
            ),
          ),
        ),
      ),
    );
  }
}
