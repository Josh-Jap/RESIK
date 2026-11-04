import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';

class AdminSampahScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminSampahScreen({super.key, this.onNavigateTab});

  @override
  State<AdminSampahScreen> createState() => _AdminSampahScreenState();
}

class _AdminSampahScreenState extends State<AdminSampahScreen> {
  // 0: Hari, 1: Minggu, 2: Bulan
  int _selectedPeriod = 0;

  final List<Map<String, dynamic>> _periodData = [
    {
      'date': 'Jumat, 25 September 2026',
      'total': '120 kg',
      'organik': '72 kg',
      'nonOrganik': '48 kg',
      'ratio': 'Organik 60% · Non-organik 40%',
      'organikPct': 0.60,
      'rincian': [
        {'area': 'Blok A - C', 'org': '27', 'non': '18', 'tot': '45'},
        {'area': 'Blok D - F', 'org': '24', 'non': '16', 'tot': '40'},
        {'area': 'Area umum', 'org': '21', 'non': '14', 'tot': '35'},
      ],
    },
    {
      'date': '21–27 September 2026',
      'total': '800 kg',
      'organik': '480 kg',
      'nonOrganik': '320 kg',
      'ratio': 'Organik 60% · Non-organik 40%',
      'organikPct': 0.60,
      'rincian': [
        {'area': 'Blok A - C', 'org': '180', 'non': '120', 'tot': '300'},
        {'area': 'Blok D - F', 'org': '168', 'non': '112', 'tot': '280'},
        {'area': 'Area umum', 'org': '132', 'non': '88', 'tot': '220'},
      ],
    },
    {
      'date': '1–30 September 2026',
      'total': '3.200 kg',
      'organik': '1.920 kg',
      'nonOrganik': '1.280 kg',
      'ratio': 'Organik 60% · Non-organik 40%',
      'organikPct': 0.60,
      'rincian': [
        {'area': 'Blok A - C', 'org': '720', 'non': '480', 'tot': '1.200'},
        {'area': 'Blok D - F', 'org': '672', 'non': '448', 'tot': '1.120'},
        {'area': 'Area umum', 'org': '528', 'non': '352', 'tot': '880'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = _periodData[_selectedPeriod];

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Laporan Sampah',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, // #252A27
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Rekap berat sampah - Griya Asri',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary, // #7FA68C
                        ),
                      ),
                    ],
                  ),
                  ResikAvatarBadge(
                    onTap: () => widget.onNavigateTab?.call(5),
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        current['date'],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Data contoh',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary, // #7FA68C
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

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
                              'Non-organik',
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
                              flex: ((current['organikPct'] as double) * 100).toInt(),
                              child: Container(color: AppColors.accentMint), // #83EBAB
                            ),
                            Expanded(
                              flex: (100 - ((current['organikPct'] as double) * 100)).toInt(),
                              child: Container(color: Colors.white.withValues(alpha: 0.3)),
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
              const Text(
                'Rincian pengumpulan',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, // #252A27
                ),
              ),

              const SizedBox(height: 10),

              // Rincian Table Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg, // #FFFFFF
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border), // #D9DDD7
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    // Table Header
                    Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Area',
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
                            'Organik / Non-organik / Total (kg)',
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
                    ...List.generate(
                      (current['rincian'] as List).length,
                      (idx) {
                        final row = current['rincian'][idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  row['area'],
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
                                      width: 40,
                                      child: Text(
                                        row['org'],
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 44,
                                      child: Text(
                                        row['non'],
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 48,
                                      child: Text(
                                        row['tot'],
                                        textAlign: TextAlign.right,
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
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bottom note
              const Text(
                'Data contoh hasil penimbangan petugas. Rekap ini terpisah dari pengaduan warga.',
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
            color: isSelected ? AppColors.primaryGreen : Colors.transparent, // #245C4A
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary, // #7FA68C
            ),
          ),
        ),
      ),
    );
  }
}
