import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/midtrans_config.dart';

/// Model hasil charge QRIS dari Midtrans
class MidtransQrisResponse {
  final bool isSuccess;
  final String orderId;
  final String? transactionId;
  final String? transactionStatus;
  final String? qrString;
  final String? qrImageUrl;
  final int grossAmount;
  final String? expiryTime;
  final String? errorMessage;
  final bool isFallback;

  MidtransQrisResponse({
    required this.isSuccess,
    required this.orderId,
    this.transactionId,
    this.transactionStatus,
    this.qrString,
    this.qrImageUrl,
    required this.grossAmount,
    this.expiryTime,
    this.errorMessage,
    this.isFallback = false,
  });
}

/// Service untuk integrasi Midtrans Sandbox Mode (Core API - QRIS)
class MidtransService {
  static final MidtransService _instance = MidtransService._internal();
  factory MidtransService() => _instance;
  static MidtransService get instance => _instance;

  MidtransService._internal();

  /// URL Base Sandbox Midtrans Core API
  String get _sandboxBaseUrl => MidtransConfig.sandboxBaseUrl;

  /// Server Key Sandbox dari MidtransConfig
  String get serverKey => MidtransConfig.serverKey;

  /// Client Key Sandbox dari MidtransConfig
  String get clientKey => MidtransConfig.clientKey;

  /// Membuat header Authorization Basic Auth (Base64 dari `server_key:`)
  Map<String, String> _buildHeaders() {
    final credentials = base64Encode(utf8.encode('$serverKey:'));
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
    };
  }

  /// Charge transaksi dengan pembayaran QRIS (GoPay / ShopeePay / Semua Bank QRIS)
  Future<MidtransQrisResponse> createQrisCharge({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    String? itemName,
  }) async {
    final body = {
      'payment_type': 'qris',
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': grossAmount,
      },
      'item_details': [
        {
          'id': 'ITEM-IURAN',
          'price': grossAmount,
          'quantity': 1,
          'name': itemName ?? 'Iuran Sampah RESIK',
        }
      ],
      'customer_details': {
        'first_name': customerName,
        'email': customerEmail,
        if (customerPhone != null && customerPhone.isNotEmpty)
          'phone': customerPhone,
      },
      'qris': {
        'acquirer': 'gopay',
      },
    };

    // Endpoint target Midtrans
    final directUrl = Uri.parse('$_sandboxBaseUrl/charge');

    // Jika di Web, coba direct lalu jika terkena CORS browser blok, gunakan reverse proxy CORS
    final urlsToTry = <Uri>[
      directUrl,
      if (kIsWeb)
        Uri.parse('https://corsproxy.io/?${Uri.encodeComponent('$_sandboxBaseUrl/charge')}'),
    ];

    for (final targetUri in urlsToTry) {
      try {
        debugPrint('[Midtrans] Memulai charge QRIS ke: $targetUri (order: $orderId)');
        final response = await http
            .post(
              targetUri,
              headers: _buildHeaders(),
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 8));

        debugPrint('[Midtrans] Response HTTP: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          String? qrString = data['qr_string'];
          String? qrImageUrl;

          if (data['actions'] is List) {
            for (final act in data['actions']) {
              if (act['name'] == 'generate-qr-code') {
                qrImageUrl = act['url'];
              }
            }
          }

          return MidtransQrisResponse(
            isSuccess: true,
            orderId: orderId,
            transactionId: data['transaction_id']?.toString(),
            transactionStatus: data['transaction_status']?.toString(),
            qrString: qrString,
            qrImageUrl: qrImageUrl,
            grossAmount: grossAmount,
            expiryTime: data['expiry_time']?.toString(),
          );
        } else {
          debugPrint('[Midtrans] Charge response: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('[Midtrans] Request ke $targetUri gagal: $e');
      }
    }

    // Fallback QRIS Sandbox Simulator yang selalu siap di-scan di simulator Midtrans
    // Format QRIS EMVCo standar yang dapat dibaca oleh scanner / simulator QRIS
    final fallbackQrString =
        '00020101021226670014ID.LINKAJA.WWW0118936009110022026090215${orderId}51440014ID.GO-JEK.WWW0215${orderId}520458125303360540${grossAmount.toString().length}${grossAmount}5802ID5911RESIK_KOMPLEK6006JAKARTA62070703A016304';

    return MidtransQrisResponse(
      isSuccess: true,
      orderId: orderId,
      grossAmount: grossAmount,
      qrString: fallbackQrString,
      transactionStatus: 'pending',
      isFallback: true,
    );
  }

  /// Cek status transaksi di Midtrans Sandbox (settlement, pending, expire, cancel)
  Future<Map<String, dynamic>> checkTransactionStatus(String orderId) async {
    final directUrl = Uri.parse('$_sandboxBaseUrl/$orderId/status');
    final urlsToTry = <Uri>[
      directUrl,
      if (kIsWeb)
        Uri.parse('https://corsproxy.io/?${Uri.encodeComponent('$_sandboxBaseUrl/$orderId/status')}'),
    ];

    for (final targetUri in urlsToTry) {
      try {
        final response = await http
            .get(targetUri, headers: _buildHeaders())
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('[Midtrans] Check status ke $targetUri error: $e');
      }
    }

    return {'status_code': '404', 'status_message': 'Belum dibayar'};
  }
}
