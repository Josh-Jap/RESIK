import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';

class PetugasDetailPengambilanScreen extends StatelessWidget {
  const PetugasDetailPengambilanScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            'Lapor kendala mesin, truk, hingga pengalihan sampah.',
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

              // Amber Warning Box (Pengambilan tertunda)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.badgeDiprosesBg, // #FFF4D8
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF2DCA5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.badgeDiprosesText, // #D69E2E
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pengambilan tertunda',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.badgeDiprosesText, // #D69E2E
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Laporan ini didaftarkan armada 2, tetapi sampah belum diambil dan pengambilan terlambat armada karena kendala. Segera ambil / selesaikan.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8A6208),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

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
                            color: AppColors.badgeSelesaiBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Sudah klaim',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.badgeSelesaiText, // #245C4A
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
                            children: const [
                              Text(
                                'Sampah menumpuk',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Dekat gerbang Blok B',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                '08.15 · 2 menit lalu',
                                style: TextStyle(
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
                    _buildDetailItem('Lokasi', 'Dekat gerbang Blok B'),
                    const Divider(color: AppColors.border, height: 16),
                    _buildDetailItem('Waktu aduan', '08.15'),
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
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
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
                        height: 140,
                        width: double.infinity,
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
                                Icons.photo_camera_back_outlined,
                                size: 36,
                                color: Colors.white70,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Foto Pengaduan di Lokasi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tindak Lanjut Pengambilan
              const Text(
                'Tindak lanjut pengambilan',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tim Pengangkut 2 bertanggung jawab mengambil sampah di lokasi laporan. Siasati ketersediaan armada atau laporkan kendala pengangkutan.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 18),

              // BUTTON 1: Lanjutkan Pengambilan (Solid Green #245C4A)
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Armada siap bergerak menuju lokasi aduan!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text(
                    'Lanjutkan Pengambilan',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen, // #245C4A
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // BUTTON 2: Laporkan Kendala (Outlined Green)
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form pelaporan kendala armada dikirim ke mandur.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Laporkan Kendala',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
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
            color: AppColors.textPrimary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
