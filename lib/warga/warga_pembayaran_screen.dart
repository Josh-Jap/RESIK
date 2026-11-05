import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/resik_avatar_badge.dart';
import 'warga_qris_screen.dart';

class WargaPembayaranScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const WargaPembayaranScreen({super.key, this.onNavigateTab});

  @override
  State<WargaPembayaranScreen> createState() => _WargaPembayaranScreenState();
}

class _WargaPembayaranScreenState extends State<WargaPembayaranScreen> {
  // Statuses: 'lunas' (hijau), 'belum_bayar' (kuning), 'telat' (merah), 'mendatang' (abu)
  late List<Map<String, dynamic>> _months;

  @override
  void initState() {
    super.initState();
    _months = [
      {'month': 'Januari', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'Februari', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'Maret', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'April', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'Mei', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'Juni', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'Juli', 'subtitle': 'Terlambat bayar', 'status': 'telat'},
      {'month': 'Agustus', 'subtitle': 'Lunas', 'status': 'lunas'},
      {'month': 'September', 'subtitle': 'Belum bayar', 'status': 'belum_bayar'},
      {'month': 'Oktober', 'subtitle': 'Belum bayar', 'status': 'belum_bayar'},
      {'month': 'November', 'subtitle': 'Mendatang', 'status': 'mendatang'},
      {'month': 'Desember', 'subtitle': 'Mendatang', 'status': 'mendatang'},
    ];
  }

  void _onMonthTap(int index) async {
    final item = _months[index];
    final String status = item['status'];
    final String monthName = item['month'];

    if (status == 'lunas') {
      _showLunasBottomSheet(monthName);
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => WargaQrisScreen(
          month: '$monthName 2026',
          status: status == 'telat' ? 'Telat bayar' : 'Menunggu pembayaran',
          isLate: status == 'telat',
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _months[index]['status'] = 'lunas';
        _months[index]['subtitle'] = 'Lunas';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryGreen,
            content: Text('Iuran $monthName 2026 berhasil dibayar!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showLunasBottomSheet(String monthName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE4F7EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bukti Iuran $monthName 2026',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Status: Lunas Terverifikasi',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),
                _buildReceiptRow('Nominal', 'Rp50.000'),
                const SizedBox(height: 8),
                _buildReceiptRow('Biaya Admin', 'Rp0'),
                const SizedBox(height: 8),
                _buildReceiptRow('Metode', 'QRIS RESIK'),
                const SizedBox(height: 8),
                _buildReceiptRow('Alamat', 'Griya Asri Blok A12'),
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pembayaran Tahunan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, // #252A27
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '12 bulan · Griya Asri · Blok A12',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary, // #7FA68C
                        ),
                      ),
                    ],
                  ),
                  ResikAvatarBadge(
                    onTap: () => widget.onNavigateTab?.call(4), // Tab Akun
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Green Summary Card (#245C4A)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen, // #245C4A
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D8), // #FFF4D8
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Data contoh',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Iuran bulanan',
                      style: TextStyle(
                        color: Color(0xFFC7EBD6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Rp50.000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Biaya admin · Rp0',
                      style: TextStyle(
                        color: Color(0xFFC7EBD6),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Info Note below Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAE0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Iuran layanan bulanan untuk pengangkutan dan kebersihan, bukan tarif per kilogram sampah.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section: 12 bulan
              const Text(
                '12 bulan',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              // List of 12 Month Cards
              Column(
                children: List.generate(_months.length, (idx) {
                  final item = _months[idx];
                  final String month = item['month'];
                  final String? subtitle = item['subtitle'];
                  final String status = item['status'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              month,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: status == 'telat'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: status == 'telat'
                                      ? const Color(0xFFC75C5C)
                                      : status == 'lunas'
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        _buildStatusButton(status, () => _onMonthTap(idx)),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 14),

              // Bottom note
              Column(
                children: const [
                  Text(
                    'Tagihan contoh · Simulasi pembayaran',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Agustus lunas · Dibayar 5 Sep 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'September belum dibayar · Jatuh tempo 10 Oktober 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Juli telat · Harap segera diselesaikan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC75C5C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status, VoidCallback onTap) {
    Color bg;
    Color borderColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'lunas':
        // Hijau Lunas
        bg = const Color(0xFFE4F7EC);
        borderColor = const Color(0xFF83EBAB);
        textColor = AppColors.primaryGreen; // #245C4A
        label = 'Lunas';
        icon = Icons.check_circle_rounded;
        break;
      case 'belum_bayar':
        // Kuning Belum Bayar
        bg = const Color(0xFFFFF4D8);
        borderColor = const Color(0xFFF2DCA5);
        textColor = const Color(0xFF8A6208);
        label = 'Belum Bayar';
        icon = Icons.access_time_rounded;
        break;
      case 'telat':
        // Merah Telat
        bg = const Color(0xFFFDE8E8);
        borderColor = const Color(0xFFF5B7B7);
        textColor = const Color(0xFFC75C5C);
        label = 'Telat';
        icon = Icons.error_outline_rounded;
        break;
      default:
        // Mendatang / Netral
        bg = Colors.white;
        borderColor = AppColors.border;
        textColor = AppColors.textSecondary;
        label = 'Pembayaran';
        icon = Icons.calendar_today_rounded;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
