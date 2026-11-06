import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResikImageResult {
  final String source; // 'Kamera' atau 'Galeri'
  final String fileName;
  final String timestamp;
  final String fileSize;

  ResikImageResult({
    required this.source,
    required this.fileName,
    required this.timestamp,
    this.fileSize = '1.8 MB',
  });
}

class ResikImagePickerDialog {
  static Future<ResikImageResult?> show(
    BuildContext context, {
    bool hasExistingPhoto = false,
  }) async {
    return showModalBottomSheet<ResikImageResult?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Sumber Foto',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Lampirkan foto tumpukan sampah atau kondisi lingkungan agar petugas mudah menemukan lokasi.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // Option 1: Kamera
              _buildOptionTile(
                ctx: ctx,
                icon: Icons.camera_alt_rounded,
                iconBg: AppColors.primaryGreen.withValues(alpha: 0.1),
                iconColor: AppColors.primaryGreen,
                title: 'Ambil Foto dari Kamera',
                subtitle: 'Buka kamera HP dan potret kondisi langsung di tempat',
                onTap: () {
                  final now = DateTime.now();
                  final stamp =
                      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
                  Navigator.of(ctx).pop(
                    ResikImageResult(
                      source: 'Kamera',
                      fileName: 'KAMERA_$stamp.jpg',
                      timestamp:
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      fileSize: '2.4 MB',
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Option 2: Galeri
              _buildOptionTile(
                ctx: ctx,
                icon: Icons.photo_library_rounded,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
                title: 'Pilih dari Galeri Foto',
                subtitle: 'Gunakan gambar yang sudah tersimpan di album perangkat',
                onTap: () {
                  final now = DateTime.now();
                  final stamp =
                      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}';
                  Navigator.of(ctx).pop(
                    ResikImageResult(
                      source: 'Galeri',
                      fileName: 'GALERI_sampah_$stamp.jpg',
                      timestamp:
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      fileSize: '1.6 MB',
                    ),
                  );
                },
              ),

              if (hasExistingPhoto) ...[
                const SizedBox(height: 12),
                _buildOptionTile(
                  ctx: ctx,
                  icon: Icons.delete_outline_rounded,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFD32F2F),
                  title: 'Hapus Foto Terpilih',
                  subtitle: 'Batalkan lampiran foto pada laporan ini',
                  onTap: () {
                    Navigator.of(ctx).pop(
                      ResikImageResult(
                        source: 'HAPUS',
                        fileName: '',
                        timestamp: '',
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required BuildContext ctx,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
