import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_image_picker_dialog.dart';

class AdminBuatLaporanScreen extends StatefulWidget {
  const AdminBuatLaporanScreen({super.key});

  @override
  State<AdminBuatLaporanScreen> createState() => _AdminBuatLaporanScreenState();
}

class _AdminBuatLaporanScreenState extends State<AdminBuatLaporanScreen> {
  String _selectedProblem = 'Sampah menumpuk';
  final _locationController = TextEditingController(text: 'Dekat gerbang Blok B');
  final _descController = TextEditingController(
    text: 'Tumpukan sampah sudah dua hari belum diangkut dan mulai mengganggu akses jalan.',
  );
  bool _hasPhoto = false;
  String? _photoName;
  String? _photoSource;
  String? _photoSize;

  final List<String> _problems = [
    'Sampah menumpuk',
    'Tong sampah rusak',
    'Daun berserakan',
    'Limbah liar di selokan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final location = _locationController.text.trim();
    final desc = _descController.text.trim();

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi tidak boleh kosong')),
      );
      return;
    }

    final currentUser = SupabaseService.instance.currentUser;
    final userId = currentUser?.idUsers ?? 1;

    final newReq = PickupReqModel(
      category: _selectedProblem,
      description: '$location - $desc',
      idUsers: userId,
      status: 'pending',
      photo: _hasPhoto ? _photoName : null,
      pickupDate: DateTime.now(),
    );

    try {
      await SupabaseService.instance.createPickupRequest(newReq);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim dan masuk ke daftar pengaduan!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e')),
      );
    }
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
                            'Buat Laporan',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sampaikan masalah kebersihan di sekitar Anda.',
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

              const SizedBox(height: 18),

              // Green Alert Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFE9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7E2D6)),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Detail yang jelas membantu petugas menangani laporan lebih cepat.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryGreen,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Field: Jenis masalah
              const Text(
                'Jenis masalah',
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
                    value: _selectedProblem,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                    items: _problems.map((problem) {
                      return DropdownMenuItem<String>(
                        value: problem,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              problem,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProblem = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Field: Lokasi
              const Text(
                'Lokasi',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Masukkan lokasi pengaduan',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        size: 18, color: AppColors.textMuted),
                    onPressed: () => _locationController.clear(),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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

              const SizedBox(height: 16),

              // Field: Deskripsi
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Tuliskan deskripsi lengkap masalah...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
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

              const SizedBox(height: 16),

              // Field: Unggah foto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Unggah foto',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Maks. 5 MB',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final result = await ResikImagePickerDialog.show(
                    context,
                    hasExistingPhoto: _hasPhoto,
                  );
                  if (result == null) return;
                  if (result.source == 'HAPUS') {
                    setState(() {
                      _hasPhoto = false;
                      _photoName = null;
                      _photoSource = null;
                      _photoSize = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto berhasil dihapus')),
                    );
                  } else {
                    setState(() {
                      _hasPhoto = true;
                      _photoName = result.fileName;
                      _photoSource = result.source;
                      _photoSize = result.fileSize;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryGreen,
                        content: Text(
                          'Foto berhasil diambil dari ${result.source}: ${result.fileName}',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasPhoto ? AppColors.primaryGreen : AppColors.border,
                      width: _hasPhoto ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _hasPhoto
                              ? AppColors.primaryGreen.withValues(alpha: 0.1)
                              : AppColors.cardSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _hasPhoto
                              ? (_photoSource == 'Kamera'
                                  ? Icons.camera_alt_rounded
                                  : Icons.photo_library_rounded)
                              : Icons.add_a_photo_outlined,
                          color: _hasPhoto
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasPhoto
                                  ? '[$_photoSource] $_photoName'
                                  : 'Ambil foto kamera atau pilih galeri',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _hasPhoto
                                    ? AppColors.primaryGreen
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasPhoto
                                  ? 'Ukuran: $_photoSize · Siap dilampirkan (Ketuk untuk ganti)'
                                  : 'JPG atau PNG (Maks. 5 MB)',
                              style: TextStyle(
                                fontSize: 11,
                                color: _hasPhoto
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_hasPhoto)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryGreen,
                          size: 22,
                        )
                      else
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kirim Laporan Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kirim Laporan',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
