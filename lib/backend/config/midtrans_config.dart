/// Konfigurasi Kredensial Midtrans Payment Gateway
/// Taruh Server Key dan Client Key Midtrans Sandbox Anda di sini:
class MidtransConfig {
  /// Server Key Sandbox dari Dashboard Midtrans -> Settings -> Access Keys
  static const String serverKey = 'SB-Mid-server-WVuebU93n~VYZmx~KMZM-jsL';

  /// Client Key Sandbox dari Dashboard Midtrans -> Settings -> Access Keys
  static const String clientKey = 'SB-Mid-client-R5JPxZ-KSCqJTPGs';

  /// Base URL Sandbox API Midtrans
  static const String sandboxBaseUrl = 'https://api.sandbox.midtrans.com/v2';

  /// Merchant ID (Opsional untuk referensi)
  static const String merchantId = 'YOUR_MERCHANT_ID';
}
