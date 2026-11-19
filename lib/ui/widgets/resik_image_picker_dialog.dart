import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';

class ResikImageResult {
  final String source; // 'Kamera', 'Galeri', atau 'Dokumen'
  final String fileName;
  final String timestamp;
  final String fileSize;
  final String? filePath; // Path lokal file asli di HP
  final Uint8List? fileBytes; // Bytes untuk web/lintas platform

  ResikImageResult({
    required this.source,
    required this.fileName,
    required this.timestamp,
    this.fileSize = '1.8 MB',
    this.filePath,
    this.fileBytes,
  });

  bool get isDeleted => source == 'HAPUS';
}

class ResikImagePickerDialog {
  static final ImagePicker _picker = ImagePicker();

  static Future<ResikImageResult?> show(
    BuildContext context, {
    bool hasExistingPhoto = false,
    bool allowDocuments = true,
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
                    'Lampirkan Foto / Dokumen',
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
                'Gunakan kamera langsung, galeri foto, atau file dokumen dari memori HP Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // Option 1: Kamera HP Fisik
              _buildOptionTile(
                ctx: ctx,
                icon: Icons.camera_alt_rounded,
                iconBg: AppColors.primaryGreen.withValues(alpha: 0.1),
                iconColor: AppColors.primaryGreen,
                title: 'Buka Kamera HP',
                subtitle: 'Potret langsung menggunakan lensa kamera perangkat',
                onTap: () async {
                  try {
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                      maxWidth: 1600,
                    );
                    if (photo != null) {
                      final now = DateTime.now();
                      int bytesLength = 0;
                      try {
                        bytesLength = await photo.length();
                      } catch (_) {}

                      final sizeStr = bytesLength > 0
                          ? '${(bytesLength / (1024 * 1024)).toStringAsFixed(1)} MB'
                          : '1.5 MB';

                      final timeStr =
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop(
                          ResikImageResult(
                            source: 'Kamera',
                            fileName: photo.name.isNotEmpty
                                ? photo.name
                                : 'CAM_${now.millisecondsSinceEpoch}.jpg',
                            timestamp: timeStr,
                            fileSize: sizeStr,
                            filePath: photo.path,
                          ),
                        );
                      }
                      return;
                    }
                  } catch (e) {
                    debugPrint('Error pickImage camera: $e');
                  }
                },
              ),

              const SizedBox(height: 12),

              // Option 2: Galeri Foto HP
              _buildOptionTile(
                ctx: ctx,
                icon: Icons.photo_library_rounded,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
                title: 'Pilih dari Galeri Foto',
                subtitle: 'Pilih foto yang tersimpan di album perangkat',
                onTap: () async {
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                      maxWidth: 1600,
                    );
                    if (image != null) {
                      final now = DateTime.now();
                      int bytesLength = 0;
                      try {
                        bytesLength = await image.length();
                      } catch (_) {}

                      final sizeStr = bytesLength > 0
                          ? '${(bytesLength / (1024 * 1024)).toStringAsFixed(1)} MB'
                          : '1.2 MB';

                      final timeStr =
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop(
                          ResikImageResult(
                            source: 'Galeri',
                            fileName: image.name.isNotEmpty
                                ? image.name
                                : 'IMG_${now.millisecondsSinceEpoch}.jpg',
                            timestamp: timeStr,
                            fileSize: sizeStr,
                            filePath: image.path,
                          ),
                        );
                      }
                      return;
                    }
                  } catch (e) {
                    debugPrint('Error pickImage gallery: $e');
                  }
                },
              ),

              // Option 3: File Dokumen (PDF, Gambar, dll)
              if (allowDocuments) ...[
                const SizedBox(height: 12),
                _buildOptionTile(
                  ctx: ctx,
                  icon: Icons.folder_open_rounded,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1976D2),
                  title: 'Pilih Berkas / Dokumen',
                  subtitle: 'Ambil berkas (PDF, DOCX, JPG, PNG) dari memori HP',
                  onTap: () async {
                    try {
                      final file = await FilePicker.pickFile(
                        type: FileType.custom,
                        allowedExtensions: [
                          'jpg',
                          'jpeg',
                          'png',
                          'pdf',
                          'doc',
                          'docx',
                        ],
                      );
                      if (file != null) {
                        final now = DateTime.now();
                        int bytesLen = file.lengthSync() ?? 0;
                        if (bytesLen == 0) {
                          bytesLen = (await file.length()) ?? 0;
                        }
                        final sizeStr = bytesLen > 0
                            ? '${(bytesLen / (1024 * 1024)).toStringAsFixed(1)} MB'
                            : '1.2 MB';
                        final timeStr =
                            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                        if (ctx.mounted) {
                          Navigator.of(ctx).pop(
                            ResikImageResult(
                              source: 'Dokumen',
                              fileName: file.name,
                              timestamp: timeStr,
                              fileSize: sizeStr,
                              filePath: file.path,
                            ),
                          );
                        }
                        return;
                      }
                    } catch (e) {
                      debugPrint('Error pickFile: $e');
                    }
                  },
                ),
              ],

              if (hasExistingPhoto) ...[
                const SizedBox(height: 12),
                _buildOptionTile(
                  ctx: ctx,
                  icon: Icons.delete_outline_rounded,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFD32F2F),
                  title: 'Hapus Lampiran Terpilih',
                  subtitle: 'Batalkan lampiran foto/dokumen pada formulir ini',
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
              child: Icon(icon, color: iconColor, size: 22),
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
