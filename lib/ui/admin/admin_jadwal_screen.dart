import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_week_date_selector.dart';
import '../../backend/backend.dart';
import 'admin_tambah_jadwal_screen.dart';

class AdminJadwalScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminJadwalScreen({super.key, this.onNavigateTab});

  @override
  State<AdminJadwalScreen> createState() => _AdminJadwalScreenState();
}

class _AdminJadwalScreenState extends State<AdminJadwalScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<ScheduleModel> _allSchedules = [];

  static const List<String> _dayNamesFull = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final List<ScheduleModel> list =
          await SupabaseService.instance.getAllSchedules();
      if (mounted) {
        setState(() {
          _allSchedules = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ScheduleModel> get _filteredSchedules {
    final selectedDayName = _dayNamesFull[_selectedDate.weekday % 7].toLowerCase();
    final d2 = _selectedDate.day.toString().padLeft(2, '0');
    final m2 = _selectedDate.month.toString().padLeft(2, '0');
    final y4 = _selectedDate.year.toString();

    // Support ISO format (YYYY-MM-DD), D/M/YYYY, and DD/MM/YYYY
    final dateIso = '$y4-$m2-$d2';
    final dateSlash1 = '${_selectedDate.day}/${_selectedDate.month}/$y4';
    final dateSlash2 = '$d2/$m2/$y4';

    final matched = _allSchedules.where((s) {
      if (s.date != null && s.date!.trim().isNotEmpty) {
        final d = s.date!.trim();
        if (d == dateIso || d == dateSlash1 || d == dateSlash2 || d.contains(dateIso)) {
          return true;
        }
      }
      if (s.day != null && s.day!.trim().isNotEmpty) {
        final day = s.day!.trim().toLowerCase();
        if (day == selectedDayName || day.contains(selectedDayName) || selectedDayName.contains(day)) {
          return true;
        }
      }
      // If schedule doesn't specify a date or day, it represents a daily recurring schedule
      if ((s.date == null || s.date!.trim().isEmpty || s.date == 'Pilih tanggal') &&
          (s.day == null || s.day!.trim().isEmpty)) {
        return true;
      }
      return false;
    }).toList();

    return matched;
  }

  void _confirmDeleteSchedule(ScheduleModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 24),
            SizedBox(width: 8),
            Text(
              'Hapus Jadwal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal pengangkutan di "${item.area}" (${item.time})?',
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SupabaseService.instance.deleteSchedule(item.idSchedule);
              await _loadSchedules();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Jadwal "${item.area}" berhasil dihapus.'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = _dayNamesFull[_selectedDate.weekday % 7];
    final displaySchedules = _filteredSchedules;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_jadwal',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminTambahJadwalScreen(
                onScheduleAdded: (_) {
                  _loadSchedules();
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
        child: RefreshIndicator(
          onRefresh: _loadSchedules,
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
                    ),
                    const SizedBox(width: 8),
                    ResikAvatarBadge(onTap: () => widget.onNavigateTab?.call(5)),
                  ],
                ),

                const SizedBox(height: 18),

                // Week & Settable Date Selector
                ResikWeekDateSelector(
                  selectedDate: _selectedDate,
                  onDateSelected: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),

                const SizedBox(height: 22),

                // Section: Pengangkutan Hari Ini / Terpilih
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jadwal $dayLabel (${_selectedDate.day}/${_selectedDate.month})',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${displaySchedules.length} Jadwal',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                else if (displaySchedules.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 36,
                            color: AppColors.textMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada jadwal untuk hari $dayLabel.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...displaySchedules.map((item) {
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
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.time,
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
                                  item.area,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.type}${item.officer != null ? ' • ${item.officer}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(item.status),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _confirmDeleteSchedule(item),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppColors.danger.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 70),
              ],
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
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
