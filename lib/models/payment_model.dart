import 'user_model.dart';

class PaymentModel {
  final int? idPayments;
  final int idUsers;
  final String? qrisReference;
  final DateTime? paidAt;
  final String? month;
  final int? year;
  final int? amount;
  final UserModel? user;

  PaymentModel({
    this.idPayments,
    required this.idUsers,
    this.qrisReference,
    this.paidAt,
    this.month,
    this.year,
    this.amount,
    this.user,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      idPayments: map['id_payments'] != null ? int.tryParse(map['id_payments'].toString()) : null,
      idUsers: int.tryParse(map['id_users']?.toString() ?? '0') ?? 0,
      qrisReference: map['qris_reference'] as String?,
      paidAt: map['paid_at'] != null ? DateTime.tryParse(map['paid_at'].toString()) : null,
      month: map['month'] as String?,
      year: map['year'] != null ? int.tryParse(map['year'].toString()) : null,
      amount: map['amount'] != null ? int.tryParse(map['amount'].toString()) : null,
      user: map['User'] != null && map['User'] is Map<String, dynamic>
          ? UserModel.fromMap(map['User'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idPayments != null) 'id_payments': idPayments,
      'id_users': idUsers,
      'qris_reference': qrisReference,
      'paid_at': paidAt?.toIso8601String(),
      'month': month,
      'year': year,
      'amount': amount,
    };
  }

  /// Format nominal dalam Rupiah (misal: 50000 -> "Rp50.000")
  String get formattedAmount {
    if (amount == null) return 'Rp0';
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join()}';
  }

  /// Format tanggal bayar (misal: "15 Oktober 2026")
  String get formattedPaidDate {
    if (paidAt == null) return 'Belum ada pembayaran';
    final dt = paidAt!;
    const monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final mName = (dt.month >= 1 && dt.month <= 12) ? monthNames[dt.month] : '${dt.month}';
    return '${dt.day} $mName ${dt.year}';
  }

  PaymentModel copyWith({
    int? idPayments,
    int? idUsers,
    String? qrisReference,
    DateTime? paidAt,
    String? month,
    int? year,
    int? amount,
    UserModel? user,
  }) {
    return PaymentModel(
      idPayments: idPayments ?? this.idPayments,
      idUsers: idUsers ?? this.idUsers,
      qrisReference: qrisReference ?? this.qrisReference,
      paidAt: paidAt ?? this.paidAt,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      user: user ?? this.user,
    );
  }
}
