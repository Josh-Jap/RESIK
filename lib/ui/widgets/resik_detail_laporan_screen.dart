import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_image_picker_dialog.dart';

class ResikDetailLaporanScreen extends StatefulWidget {
  final Map<String, dynamic>? reportData;
  final String role; // 'warga', 'admin', atau 'petugas'

  const ResikDetailLaporanScreen({
    super.key,
    this.reportData,
    this.role = 'warga',
  });

  @override
  State<ResikDetailLaporanScreen> createState() => _ResikDetailLaporanScreenState();
}

class _ResikDetailLaporanScreenState extends State<ResikDetailLaporanScreen> {
  bool _isProcessing = false;
  bool _hasProofPhoto = false;
  String? _proofPhotoName;
  String? _proofPhotoPath;
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.reportData?['status'] ?? 'pending';
    if (widget.reportData?['isAccepted'] == true && _status == 'pending') {
      _status = 'in_progress';
    }
  }

  Future<void> _handleAccept() async {
    final reportId = widget.reportData?['id'];
    setState(() => _isProcessing = true);
    if (reportId != null) {
      await SupabaseService.instance.updatePickupStatus(reportId, 'in_progress');
    }
    if (!mounted) return;
    setState(() {
      _status = 'in_progress';
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan diterima! Silakan ambil sampah dan unggah bukti.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Future<void> _handleComplete() async {
    final reportId = widget.reportData?['id'];
    setState(() => _isProcessing = true);

    String? proofUrl;
    if (_hasProofPhoto && _proofPhotoName != null) {
      proofUrl = await SupabaseService.instance.uploadLaporanPhoto(
        filePath: _proofPhotoPath,
        fileName: _proofPhotoName!,
      );
    }

    if (reportId != null) {
      await SupabaseService.instance.updatePickupStatus(reportId, 'completed');
    }
    if (!mounted) return;
    setState(() {
      _status = 'completed';
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tugas selesai! Bukti penjemputan sampah berhasil disimpan.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.reportData?['title'] ?? 'Laporan Sampah';
    final location = widget.reportData?['location'] ?? 'Area Perumahan';
    final desc = widget.reportData?['desc'] ?? 'Laporan pengangkutan sampah warga.';
    final time = widget.reportData?['time'] ?? 'Baru saja';
    final photo = widget.reportData?['photo'] as String?;

    final isCompleted = _status == 'completed' || _status == 'selesai';
    final isInProgress = _status == 'in_progress' || _status == 'diproses';
    final isPetugas = widget.role.toLowerCase() == 'petugas';
    final isAdmin = widget.role.toLowerCase() == 'admin';

    String statusBadgeLabel;
    Color statusBadgeBg;
    Color statusBadgeText;

    if (isCompleted) {
      statusBadgeLabel = 'Selesai';
      statusBadgeBg = const Color(0xFFE4F7EC);
      statusBadgeText = AppColors.primaryGreen;
    } else if (isInProgress) {
      statusBadgeLabel = 'Sedang Diproses';
      statusBadgeBg = AppColors.badgeDiprosesBg;
      statusBadgeText = AppColors.badgeDiprosesText;
    } else {
      statusBadgeLabel = 'Baru Masuk';
      statusBadgeBg = const Color(0xFFE3EDF0);
      statusBadgeText = const Color(0xFF35697B);
    }

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
                        children: [
                          const Text(
                            'Detail Laporan',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAdmin
                                ? 'Pantau & tinjau laporan pengaduan.'
                                : isPetugas
                                    ? 'Alur penerimaan dan penugasan.'
                                    : 'Informasi tindak lanjut pengaduan Anda.',
                            style: const TextStyle(
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

              // CARD 1: Status Laporan
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Pengaduan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBadgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusBadgeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusBadgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 18),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle_outline_rounded : Icons.delete_outline_rounded,
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
                                time,
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

              // CARD 2: Informasi Detail Deskripsi & Lokasi
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
                      'Informasi Detail',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailItem('Deskripsi Pengaduan', desc),
                    const Divider(color: AppColors.border, height: 16),
                    _buildDetailItem('Tempat / Lokasi', location),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // CARD 3: FOTO PENGADUAN DARI PELAPOR (WARGA / ADMIN)
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
                    Row(
                      children: const [
                        Icon(Icons.photo_outlined, size: 18, color: AppColors.primaryGreen),
                        SizedBox(width: 6),
                        Text(
                          'Foto Pengaduan Sampah',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildPhotoDisplay(
                      photoUrlOrName: photo,
                      fallbackText: 'Pelapor tidak menyertakan foto lampiran.',
                      badgeLabel: 'Foto Sampah',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // CARD 4: BUKTI PENGAMBILAN (OLEH PETUGAS)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.verified_outlined, size: 18, color: AppColors.primaryGreen),
                            SizedBox(width: 6),
                            Text(
                              'Foto Bukti Sampah Selesai Diambil',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (_hasProofPhoto || isCompleted)
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Jika Petugas dan sedang dalam proses: bisa klik untuk ambil foto
                    if (isPetugas && isInProgress && !isCompleted)
                      InkWell(
                        onTap: () async {
                          final result = await ResikImagePickerDialog.show(
                            context,
                            hasExistingPhoto: _hasProofPhoto,
                          );
                          if (result != null) {
                            if (result.isDeleted) {
                              setState(() {
                                _hasProofPhoto = false;
                                _proofPhotoName = null;
                                _proofPhotoPath = null;
                              });
                            } else {
                              setState(() {
                                _hasProofPhoto = true;
                                _proofPhotoName = result.fileName;
                                _proofPhotoPath = result.filePath;
                              });
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _hasProofPhoto ? const Color(0xFFE8F5E9) : AppColors.cardSubtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hasProofPhoto ? AppColors.primaryGreen : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _hasProofPhoto ? Icons.photo_library_rounded : Icons.add_a_photo_outlined,
                                  size: 36,
                                  color: _hasProofPhoto ? AppColors.primaryGreen : AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _hasProofPhoto
                                      ? (_proofPhotoName ?? 'Bukti foto terpasang')
                                      : 'Klik untuk ambil/unggah foto bukti',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _hasProofPhoto ? FontWeight.w700 : FontWeight.w500,
                                    color: _hasProofPhoto ? AppColors.primaryGreen : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      // Tampilan view-only untuk Warga, Admin, atau Petugas yang sudah selesai
                      _buildPhotoDisplay(
                        photoUrlOrName: _hasProofPhoto ? _proofPhotoName : (isCompleted ? 'BUKTI_SELESAI_DIANGKUT.jpg' : null),
                        localPath: _proofPhotoPath,
                        fallbackText: isCompleted
                            ? 'Sampah telah selesai diangkut oleh Petugas.'
                            : 'Petugas belum mengunggah foto bukti penjemputan.',
                        badgeLabel: 'Bukti Pengangkutan',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // AKSI KHUSUS PETUGAS
              if (isPetugas) ...[
                if (!isInProgress && !isCompleted)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handleAccept,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: const Text(
                        'Terima Laporan',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                else if (isInProgress)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handleComplete,
                      icon: const Icon(Icons.task_alt_rounded, size: 20),
                      label: const Text(
                        'Selesaikan Pengambilan',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7E34),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                else
                  _buildCompletedBadge(),
              ] else if (isCompleted) ...[
                _buildCompletedBadge(),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F7EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF83EBAB)),
      ),
      child: const Center(
        child: Text(
          'Laporan ini telah selesai dikerjakan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoDisplay({
    String? photoUrlOrName,
    String? localPath,
    required String fallbackText,
    required String badgeLabel,
  }) {
    if (localPath != null && localPath.isNotEmpty && !kIsWeb && File(localPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(localPath),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (photoUrlOrName != null && photoUrlOrName.isNotEmpty) {
      if (photoUrlOrName.startsWith('http://') || photoUrlOrName.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            photoUrlOrName,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackPhotoCard(photoUrlOrName, badgeLabel),
          ),
        );
      }
      return _buildFallbackPhotoCard(photoUrlOrName, badgeLabel);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.image_not_supported_outlined, size: 28, color: AppColors.textMuted),
            const SizedBox(height: 6),
            Text(
              fallbackText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhotoCard(String name, String badge) {
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7E2D5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 36, color: AppColors.primaryGreen),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
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
