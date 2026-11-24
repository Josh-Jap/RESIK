import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../../backend/backend.dart';

class WargaQrisScreen extends StatefulWidget {
  final String month;
  final String status;
  final bool isLate;
  final int grossAmount;
  final String? customOrderId;

  const WargaQrisScreen({
    super.key,
    this.month = 'November 2026',
    this.status = 'Menunggu pembayaran',
    this.isLate = false,
    this.grossAmount = 50000,
    this.customOrderId,
  });

  @override
  State<WargaQrisScreen> createState() => _WargaQrisScreenState();
}

class _WargaQrisScreenState extends State<WargaQrisScreen> {
  bool _isLoading = true;
  String? _qrString;
  String? _qrImageUrl;
  String? _orderId;
  String? _errorMessage;
  String _paymentStatus = 'Menunggu pembayaran';
  Timer? _pollingTimer;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _initMidtransTransaction();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initMidtransTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = SupabaseService.instance.currentUser;
    final userId = currentUser?.idUsers ?? 1;
    final userName = currentUser?.nameUsers ?? 'Warga RESIK';
    final userEmail = currentUser?.email ?? 'warga@resik.id';
    final userPhone = currentUser?.phoneNum?.toString();

    // Format Order ID: RSK-[Timestamp]-[UserId]
    _orderId = widget.customOrderId ??
        'RSK-${DateTime.now().millisecondsSinceEpoch}-$userId';

    final res = await MidtransService.instance.createQrisCharge(
      orderId: _orderId!,
      grossAmount: widget.grossAmount,
      customerName: userName,
      customerEmail: userEmail,
      customerPhone: userPhone,
      itemName: 'Iuran Sampah ${widget.month}',
    );

    if (mounted) {
      if (res.isSuccess) {
        setState(() {
          _qrString = res.qrString;
          _qrImageUrl = res.qrImageUrl;
          _isLoading = false;
        });
        // Mulai polling otomatis setiap 5 detik untuk memeriksa pembayaran sandbox
        _startStatusPolling();
      } else {
        setState(() {
          _errorMessage = res.errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  void _startStatusPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_orderId == null || _isCheckingStatus) return;
      await _checkStatus(silent: true);
    });
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_orderId == null) return;
    if (!silent) {
      setState(() => _isCheckingStatus = true);
    }

    final res = await MidtransService.instance.checkTransactionStatus(_orderId!);
    final transactionStatus = res['transaction_status']?.toString();

    if (mounted) {
      if (!silent) {
        setState(() => _isCheckingStatus = false);
      }

      if (transactionStatus == 'settlement' || transactionStatus == 'capture') {
        _pollingTimer?.cancel();
        setState(() {
          _paymentStatus = 'Lunas';
        });

        // Sukses bayar, kembalikan data pembayaran ke screen pemanggil
        _showSuccessDialog();
      } else if (transactionStatus == 'expire') {
        _pollingTimer?.cancel();
        setState(() {
          _paymentStatus = 'Kadaluarsa';
          _errorMessage = 'Waktu pembayaran QRIS telah habis.';
        });
      } else if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status: ${transactionStatus ?? "Menunggu pembayaran"}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 24),
            SizedBox(width: 8),
            Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'Terima kasih! Iuran sampah ${widget.month} telah berhasil diverifikasi oleh Midtrans Sandbox.',
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = 'Rp${widget.grossAmount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';

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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tagihan sampah · ${widget.month}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status Strip: Amber (normal) or Soft Red (telat)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isLate
                      ? const Color(0xFFFDE8E8)
                      : const Color(0xFFFFF4D8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isLate
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
                          widget.isLate
                              ? Icons.error_outline_rounded
                              : Icons.access_time_rounded,
                          size: 16,
                          color: widget.isLate
                              ? const Color(0xFFC75C5C)
                              : const Color(0xFF8A6208),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isLate ? 'Tagihan terlambat' : _paymentStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.isLate
                                ? const Color(0xFFC75C5C)
                                : const Color(0xFF8A6208),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Midtrans Sandbox',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                      'Manajemen Sampah Perumahan · RESIK',
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
                      amountFormatted,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // QR Code Display: Dari Midtrans QR String / Image URL
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _buildQrWidget(),
                    ),

                    const SizedBox(height: 14),

                    // Order Reference info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Order ID: ${_orderId ?? "-"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Pindai dengan GoPay / ShopeePay / BCA / Bank QRIS',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Button: Cek Status Pembayaran Sekarang
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCheckingStatus ? null : () => _checkStatus(silent: false),
                  icon: _isCheckingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Cek Status Pembayaran (Midtrans)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Button: Simulasi Bayar Berhasil (untuk kemudahan testing Sandbox tanpa scanner)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Selesaikan Pembayaran (Simulasi)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section: Petunjuk Pembayaran Sandbox
              const Text(
                'Cara Menggunakan Simulator Sandbox:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildStepItem('1', 'Salin Order ID di atas atau gunakan QRIS yang ditampilkan.'),
              const SizedBox(height: 6),
              _buildStepItem('2', 'Buka Simulator Midtrans: simulator.sandbox.midtrans.com/qris/index'),
              const SizedBox(height: 6),
              _buildStepItem('3', 'Pindai/masukkan QRIS di simulator lalu tekan "Pay". Sistem RESIK akan otomatis mendeteksi status settlement!'),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrWidget() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 28),
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Jika Midtrans mengembalikan QR string, render dengan QrImageView
    if (_qrString != null && _qrString!.isNotEmpty) {
      return QrImageView(
        data: _qrString!,
        version: QrVersions.auto,
        size: 180,
      );
    }

    // Atau jika ada QR Image URL
    if (_qrImageUrl != null && _qrImageUrl!.isNotEmpty) {
      return Image.network(
        _qrImageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.qr_code_2_rounded, size: 100),
      );
    }

    return const Center(
      child: Icon(Icons.qr_code_2_rounded, size: 120, color: AppColors.textPrimary),
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
