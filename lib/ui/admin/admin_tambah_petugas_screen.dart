import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';

class AdminTambahPetugasScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPetugasAdded;

  const AdminTambahPetugasScreen({super.key, this.onPetugasAdded});

  @override
  State<AdminTambahPetugasScreen> createState() =>
      _AdminTambahPetugasScreenState();
}

class _AdminTambahPetugasScreenState extends State<AdminTambahPetugasScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedWilayah = 'Blok A–C';
  bool _isActive = true;

  final List<String> _wilayahList = [
    'Blok A–C',
    'Blok D–F',
    'Taman Utama',
    'TPS Induk Griya Asri',
    'Seluruh Wilayah Perumahan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePetugas() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap petugas tidak boleh kosong')),
      );
      return;
    }

    try {
      final createdUser = await SupabaseService.instance.addPetugas(
        name: name,
        phone: phone.isEmpty ? '081200000000' : phone,
        email: email.isEmpty ? null : email,
        password: password.isEmpty ? 'petugas123' : password,
      );

      final words = name.split(' ');
      String initials = '';
      if (words.isNotEmpty && words[0].isNotEmpty) {
        initials += words[0][0].toUpperCase();
      }
      if (words.length > 1 && words[1].isNotEmpty) {
        initials += words[1][0].toUpperCase();
      }
      if (initials.isEmpty) initials = 'P';

      final newPetugas = {
        'initials': initials,
        'name': name,
        'phone': phone.isEmpty ? '0812-0000-0000' : phone,
        'area': 'Wilayah: $_selectedWilayah',
        'isActive': _isActive,
      };

      widget.onPetugasAdded?.call(newPetugas);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Petugas "$name" berhasil dibuat! Email: ${createdUser.email} (Sandi: ${password.isEmpty ? "petugas123" : password})'),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pop(newPetugas);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan petugas: $e')),
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
                            'Tambah Petugas',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Masukkan data dan wilayah tugas petugas baru.',
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

              // Field: Nama lengkap
              const Text(
                'Nama lengkap',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Masukkan nama lengkap petugas',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
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

              // Field: Nomor telepon
              const Text(
                'Nomor telepon',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Contoh: 0812-3456-7890',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
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
              const SizedBox(height: 4),
              const Text(
                'Gunakan nomor aktif yang dapat dihubungi',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 16),

              // Field: Email Petugas
              const Text(
                'Email Petugas (untuk Login)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Misal: budi.petugas@resik.id (opsional/otomatis)',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
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
              const SizedBox(height: 4),
              const Text(
                'Kosongkan jika ingin dibuatkan email otomatis oleh sistem',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 16),

              // Field: Kata Sandi Petugas
              const Text(
                'Kata Sandi Akun Petugas',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Default: petugas123',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
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
              const SizedBox(height: 4),
              const Text(
                'Petugas akan menggunakan email & sandi ini untuk masuk',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 16),

              // Field: Wilayah tugas
              const Text(
                'Wilayah tugas',
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
                    value: _selectedWilayah,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                    items: _wilayahList.map((w) {
                      return DropdownMenuItem<String>(
                        value: w,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Text(
                              w,
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
                      if (val != null) setState(() => _selectedWilayah = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status petugas
              const Text(
                'Status petugas',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Aktif',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Petugas dapat menerima penugasan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Field: Catatan (opsional)
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
                  hintText: 'Tambahkan informasi penugasan petugas...',
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
                        onPressed: _savePetugas,
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
}
