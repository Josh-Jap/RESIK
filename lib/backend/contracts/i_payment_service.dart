import '../models/payment_model.dart';

/// Contract for Payment & QRIS operations
abstract class IPaymentService {
  Future<List<PaymentModel>> getAllPayments();
  Future<List<PaymentModel>> getPaymentsByUserId(int userId);
  Future<PaymentModel> createPayment(PaymentModel payment);
  Future<Map<String, dynamic>> getPaymentStats({String month, int year});
}
