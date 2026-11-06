import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import 'admin_tambah_jadwal_screen.dart';

class AdminJadwalScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminJadwalScreen({super.key, this.onNavigateTab});

  @override
  State<AdminJadwalScreen> createState() => _AdminJadwalScreenState();
}

class _AdminJadwalScreenState extends State<AdminJadwalScreen> {
  int _selectedDayIndex = 4; // Jum 25

  final List<Map<String, String>> _days = [
    {'day': 'Sen', 'date': '21'},
    {'day': 'Sel', 'date': '22'},
    {'day': 'Rab', 'date': '23'},
    {'day': 'Kam', 'date': '24'},
    {'day': 'Jum', 'date': '25'},
    {'day': 'Sab', 'date': '26'},
    {'day': 'Min', 'date': '27'},
  ];

  final List<Map<String, String>> _schedules = [
    {
      'time': '08:00',
      'area': 'Blok A–C',
      'type': 'Jenis: Organik',
      'status': 'Selesai',
    },
    {
      'time': '10:30',
      'area': 'Blok D–F',
      'type': 'Jenis: Anorganik',
      'status': 'Diproses',
    },
    {
      'time': '14:00',
      'area': 'Taman Utama',
      'type': 'Jenis: Campuran',
      'status': 'Baru',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_jadwal',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminTambahJadwalScreen(
                onScheduleAdded: (item) {
                  setState(() {
                    _schedules.add(Map<String, String>.from(item));
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
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
                        'Jadwal Pengangkutan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Arahkan dan pantau ritme kebersihan komplek.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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

              // Calendar Days Horizontal Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_days.length, (idx) {
                  final item = _days[idx];
                  final isSelected = idx == _selectedDayIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = idx;
                      });
                    },
                    child: Container(
                      width: 42,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            item['day']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['date']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 22),

              // Section: Pengangkutan Hari Ini
              const Text(
                'Pengangkutan Hari Ini',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Schedule Cards
              ...List.generate(_schedules.length, (idx) {
                final item = _schedules[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['time']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['area']!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['type']!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(item['status']!),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 70),
            ],
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
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
