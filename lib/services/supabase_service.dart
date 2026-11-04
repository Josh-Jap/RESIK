import '../core/supabase_config.dart';
import '../models/housing_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/pickup_req_model.dart';

class SupabaseService {
  final _client = SupabaseConfig.client;

  // ==========================================
  // HOUSING CRUD
  // ==========================================

  /// Mengambil semua data perumahan
  Future<List<HousingModel>> getAllHousing() async {
    final response = await _client.from('Housing').select();
    return (response as List).map((item) => HousingModel.fromMap(item)).toList();
  }

  /// Menambahkan perumahan baru
  Future<void> addHousing(HousingModel housing) async {
    await _client.from('Housing').insert(housing.toMap());
  }

  // ==========================================
  // USER CRUD
  // ==========================================

  /// Mengambil data user berdasarkan ID beserta relasi perumahannya
  Future<UserModel?> getUserById(int idUsers) async {
    final response = await _client
        .from('User')
        .select('*, Housing(*)')
        .eq('id_users', idUsers)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  /// Mengambil user berdasarkan role (misal: 'warga', 'petugas', 'admin')
  Future<List<UserModel>> getUsersByRole(String role) async {
    final response = await _client
        .from('User')
        .select('*, Housing(*)')
        .eq('role', role);
    return (response as List).map((item) => UserModel.fromMap(item)).toList();
  }

  /// Registrasi / Tambah User baru
  Future<void> addUser(UserModel user) async {
    await _client.from('User').insert(user.toMap());
  }

  // ==========================================
  // PAYMENTS CRUD
  // ==========================================

  /// Mengambil semua pembayaran iuran beserta data user yang membayar
  Future<List<PaymentModel>> getAllPayments() async {
    final response = await _client
        .from('Payments')
        .select('*, User(*)');
    return (response as List).map((item) => PaymentModel.fromMap(item)).toList();
  }

  /// Menambahkan catatan pembayaran
  Future<void> addPayment(PaymentModel payment) async {
    await _client.from('Payments').insert(payment.toMap());
  }

  // ==========================================
  // PICKUP REQUEST CRUD
  // ==========================================

  /// Mengambil semua permintaan penjemputan sampah
  Future<List<PickupReqModel>> getAllPickupRequests() async {
    final response = await _client
        .from('Pickup_req')
        .select()
        .order('pickup_date', ascending: false);
    return (response as List).map((item) => PickupReqModel.fromMap(item)).toList();
  }

  /// Mengajukan permintaan penjemputan sampah baru
  Future<void> createPickupRequest(PickupReqModel request) async {
    await _client.from('Pickup_req').insert(request.toMap());
  }

  /// Mengubah status penjemputan sampah (misal: 'in_progress', 'completed')
  Future<void> updatePickupStatus(int idPickup, String newStatus) async {
    await _client
        .from('Pickup_req')
        .update({'status': newStatus})
        .eq('id_pickup', idPickup);
  }
}
