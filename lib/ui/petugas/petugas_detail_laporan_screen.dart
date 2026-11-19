import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';
import '../widgets/resik_avatar_badge.dart';
import '../widgets/resik_image_picker_dialog.dart';

class PetugasDetailLaporanScreen extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const PetugasDetailLaporanScreen({super.key, this.reportData});

  @override
  State<PetugasDetailLaporanScreen> createState() =>
      _PetugasDetailLaporanScreenState();
}

class _PetugasDetailLaporanScreenState extends State<PetugasDetailLaporanScreen> {
  bool _isProcessing = false;
  bool _hasProofPhoto = false;
  String? _proofPhotoName;
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
        content: Text('Laporan diterima! Silakan ambil sampah dan unggah bukti selesai.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Future<void> _handleComplete() async {
    final reportId = widget.reportData?['id'];
    setState(() => _isProcessing = true);
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

    final isCompleted = _status == 'completed' || _status == 'selesai';
    final isInProgress = _status == 'in_progress' || _status == 'diproses';

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
                            'Detail Laporan',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Alur penerimaan dan penyelesaian tugas.',
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

              // CARD 1: Ringkasan Laporan
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
                          'Status Laporan',
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
                            color: isCompleted
                                ? AppColors.badgeSelesaiBg
                                : (isInProgress
                                    ? AppColors.badgeDiprosesBg
                                    : const Color(0xFFE3EDF0)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCompleted
                                ? 'Selesai'
                                : (isInProgress ? 'Sedang Dikerjakan' : 'Menunggu Diterima'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? AppColors.badgeSelesaiText
                                  : (isInProgress
                                      ? AppColors.badgeDiprosesText
                                      : const Color(0xFF35697B)),
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

              // CARD 2: Deskripsi & Lokasi
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

              // CARD 3: BUKTI PENGAMBILAN (Placeholder Foto)
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
                          'Foto Bukti Sampah Selesai Diambil',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_hasProofPhoto)
                          const Icon(Icons.check_circle, size: 16, color: AppColors.primaryGreen),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: isCompleted
                          ? null
                          : () async {
                              final result = await ResikImagePickerDialog.show(
                                context,
                                hasExistingPhoto: _hasProofPhoto,
                              );
                              if (result != null) {
                                setState(() {
                                  _hasProofPhoto = true;
                                  _proofPhotoName = result.fileName;
                                });
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
                            style: _hasProofPhoto ? BorderStyle.solid : BorderStyle.solid,
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
                                  fontWeight: FontWeight.w600,
                                  color: _hasProofPhoto ? AppColors.primaryGreen : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _hasProofPhoto ? 'Siap diverifikasi selesai' : 'Gunakan kamera atau galeri untuk bukti fisik',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
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

              const SizedBox(height: 20),

              // ACTION BUTTONS SESUAI ALUR:
              // 1. Belum diterima -> Tombol "Terima Laporan"
              // 2. Sudah diterima (Proses) -> Tombol "Selesaikan Pengambilan"
              // 3. Sudah selesai -> Status Selesai
              if (!isInProgress && !isCompleted)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleAccept,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text(
                      'Terima Laporan',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E7E34), // Darker green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                Container(
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
