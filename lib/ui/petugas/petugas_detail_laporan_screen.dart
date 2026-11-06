import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import 'petugas_detail_pengambilan_screen.dart';

class PetugasDetailLaporanScreen extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const PetugasDetailLaporanScreen({super.key, this.reportData});

  @override
  State<PetugasDetailLaporanScreen> createState() =>
      _PetugasDetailLaporanScreenState();
}

class _PetugasDetailLaporanScreenState extends State<PetugasDetailLaporanScreen> {
  @override
  Widget build(BuildContext context) {
    final title = widget.reportData?['title'] ?? 'Sampah menumpuk';
    final location = widget.reportData?['location'] ?? 'Dekat gerbang Blok B';
    final time = widget.reportData?['time'] ?? '08.15 · 2 menit lalu';
    final route = widget.reportData?['route'] ?? 'Rute 1: Wilayah Blok A–C';

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
                            'Detail Laporan',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary, // #252A27
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tinjau pengaduan sebelum di lokasi dan ditangani.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary, // #7FA68C
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

              // CARD 1: Ringkasan laporan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg, // #FFFFFF
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border), // #D9DDD7
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ringkasan laporan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3EDF0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Menunggu konfirmasi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF35697B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '$time · $route',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // CARD 2: Detail laporan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg, // #FFFFFF
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border), // #D9DDD7
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail laporan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailItem('Deskripsi',
                        'Tumpukan sampah sudah dua hari belum diangkut dan mulai mengganggu akses jalan.'),
                    const Divider(color: AppColors.border, height: 16),
                    _buildDetailItem('Lokasi', location),
                    const Divider(color: AppColors.border, height: 16),
                    _buildDetailItem('Waktu aduan', time),
                    const Divider(color: AppColors.border, height: 16),
                    _buildDetailItem('Wilayah tanggung jawab', 'Blok A–C · Taman Utama'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // CARD 3: Foto laporan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg, // #FFFFFF
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border), // #D9DDD7
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto laporan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardSubtle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Placeholder scenic / street trash representation
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF8D99AE), Color(0xFF2B2D42)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 38,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Dokumentasi Pengaduan Warga',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Blok C2 / Dekat Gerbang',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
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

              const SizedBox(height: 14),

              // CARD 4: Setelah diterima (Soft Green Box)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3EC), // Soft green
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7EBD6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Setelah diterima',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen, // #245C4A
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Laporan akan masuk ke daftar tugas aktif dan status diubah otomatis menjadi \'Tim Pengangkut 2\'.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primaryGreen,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Button: Terima Laporan
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final reportId = widget.reportData?['id'];
                    if (reportId != null) {
                      await SupabaseService.instance.updatePickupStatus(reportId, 'in_progress');
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan diterima! Masuk ke jadwal tugas aktif.'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PetugasDetailPengambilanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Terima Laporan',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen, // #245C4A
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary, // #252A27
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
