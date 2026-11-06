import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';

class AdminTambahJadwalScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onScheduleAdded;

  const AdminTambahJadwalScreen({super.key, this.onScheduleAdded});

  @override
  State<AdminTambahJadwalScreen> createState() => _AdminTambahJadwalScreenState();
}

class _AdminTambahJadwalScreenState extends State<AdminTambahJadwalScreen> {
  String _selectedDate = 'Pilih tanggal';
  String _selectedTime = '08:00';
  String _selectedArea = 'Blok A–C';
  String _selectedWasteType = 'Organik';
  String _selectedOfficer = 'Pilih petugas pengangkutan';
  String _selectedStatus = 'Baru';
  final _notesController = TextEditingController();

  final List<String> _areas = ['Blok A–C', 'Blok D–F', 'Taman Utama', 'Area Komersil / Pos'];
  final List<String> _officers = [
    'Pilih petugas pengangkutan',
    'Budi Santoso',
    'Siti Aminah',
    'Joko Widodo',
    'Tim Regu Pagi (4 Orang)',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveSchedule() {
    final newSchedule = {
      'time': _selectedTime,
      'area': _selectedArea,
      'type': 'Jenis: $_selectedWasteType',
      'status': _selectedStatus,
    };

    widget.onScheduleAdded?.call(newSchedule);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal pengangkutan berhasil ditambahkan!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
    Navigator.of(context).pop(newSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
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
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tambah Jadwal',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Atur jadwal pengangkutan sampah komplek.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const ResikAvatarBadge(size: 36),
                ],
              ),

              const SizedBox(height: 22),

              // Row: Tanggal & Waktu
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate =
                                    '${picked.day}/${picked.month}/${picked.year}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedDate,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _selectedDate == 'Pilih tanggal'
                                          ? AppColors.textMuted
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waktu (WIB)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 8, minute: 0),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Wilayah pengangkutan
              const Text(
                'Wilayah pengangkutan',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedArea,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                    items: _areas.map((a) {
                      return DropdownMenuItem<String>(
                        value: a,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Text(
                              a,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedArea = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Jenis sampah
              const Text(
                'Jenis sampah',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildWasteChip('Organik'),
                  const SizedBox(width: 8),
                  _buildWasteChip('Anorganik'),
                  const SizedBox(width: 8),
                  _buildWasteChip('Campuran'),
                ],
              ),

              const SizedBox(height: 16),

              // Petugas
              const Text(
                'Petugas',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOfficer,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                    items: _officers.map((o) {
                      return DropdownMenuItem<String>(
                        value: o,
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Text(
                              o,
                              style: TextStyle(
                                fontSize: 13,
                                color: o.startsWith('Pilih')
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedOfficer = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status jadwal
              const Text(
                'Status jadwal',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildStatusChip('Baru'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Diproses'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Selesai'),
                ],
              ),

              const SizedBox(height: 16),

              // Catatan (opsional)
              const Text(
                'Catatan (opsional)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Tambahkan arahan atau titik pengangkutan...',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons: Batal & Simpan
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _saveSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWasteChip(String label) {
    final isSelected = _selectedWasteType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedWasteType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildStatusChip(String label) {
    final isSelected = _selectedStatus == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(12),
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
