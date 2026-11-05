import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class WargaQrisScreen extends StatelessWidget {
  final String month;
  final String status;
  final bool isLate;
  final String amount;

  const WargaQrisScreen({
    super.key,
    this.month = 'September 2026',
    this.status = 'Menunggu pembayaran',
    this.isLate = false,
    this.amount = 'Rp50.000',
  });

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
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pembayaran QRIS',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, // #252A27
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tagihan sampah · $month',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary, // #7FA68C
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status Strip: Amber (normal) or Soft Red (telat)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isLate
                      ? const Color(0xFFFDE8E8) // #FDE8E8 soft red
                      : const Color(0xFFFFF4D8), // #FFF4D8 soft amber
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isLate
                        ? const Color(0xFFF5B7B7)
                        : const Color(0xFFF2DCA5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLate
                              ? Icons.error_outline_rounded
                              : Icons.access_time_rounded,
                          size: 16,
                          color: isLate
                              ? const Color(0xFFC75C5C)
                              : const Color(0xFF8A6208),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLate ? 'Tagihan terlambat' : status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLate
                                ? const Color(0xFFC75C5C)
                                : const Color(0xFF8A6208),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Simulasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLate
                            ? const Color(0xFFC75C5C)
                            : const Color(0xFF8A6208),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // QRIS White Card Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  children: [
                    // Top Card Header: RESIK & QRIS Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'RESIK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          'QRIS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Manajemen Sampah Perumahan · Griya Asri',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Total pembayaran',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // QR Code with CONTOH in middle
                    Container(
                      width: 180,
                      height: 180,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: _QrisContohPainter(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Light beige disclaimer box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'QRIS contoh — bukan untuk transaksi',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kode hanya untuk tampilan desain.',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'No. tagihan · RSK-202609-A12',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section: Cara membayar dengan QRIS
              const Text(
                'Cara membayar dengan QRIS',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              _buildStepItem('1', 'Buka aplikasi bank atau dompet digital.'),
              const SizedBox(height: 6),
              _buildStepItem(
                  '2', 'Pindai QRIS resmi dari RESIK, bukan kode contoh ini.'),
              const SizedBox(height: 6),
              _buildStepItem('3',
                  'Pastikan merchant RESIK dan nominal $amount, lalu konfirmasi.'),

              const SizedBox(height: 20),

              // Button: Selesaikan / Kembali ke tagihan (returns true to simulate successful payment)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kembali ke tagihan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Bottom note
              const Center(
                child: Text(
                  'Simulasi · Tidak ada transaksi yang diproses.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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

  Widget _buildStepItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 2, right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE4ECE6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrisContohPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    // Corner Finder Patterns
    _drawFinderPattern(canvas, 0, 0, 34, paint);
    _drawFinderPattern(canvas, size.width - 34, 0, 34, paint);
    _drawFinderPattern(canvas, 0, size.height - 34, 34, paint);

    // Decorative QR data modules in top half and bottom half
    final modSize = size.width / 16;
    for (int r = 0; r < 16; r++) {
      for (int c = 0; c < 16; c++) {
        // Skip corner regions
        if ((r < 4 && c < 4) ||
            (r < 4 && c > 11) ||
            (r > 11 && c < 4)) {
          continue;
        }

        // Leave middle strip free for "CONTOH" banner
        if (r >= 7 && r <= 8) {
          continue;
        }

        if ((r * 7 + c * 11 + r * c) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * modSize, r * modSize, modSize - 1.2, modSize - 1.2),
            paint,
          );
        }
      }
    }

    // Draw "CONTOH" in middle strip
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'C O N T O H',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textX = (size.width - textPainter.width) / 2;
    final textY = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  void _drawFinderPattern(
      Canvas canvas, double x, double y, double s, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(x, y, s, s), paint);
    canvas.drawRect(
      Rect.fromLTWH(x + 5, y + 5, s - 10, s - 10),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 10, y + 10, s - 20, s - 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
