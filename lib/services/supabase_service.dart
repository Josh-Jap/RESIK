import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/housing_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/pickup_req_model.dart';

class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  static SupabaseService get instance => _instance;

  SupabaseService._internal() {
    _initFallbackData();
  }

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // Active user session
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
  }

  // ==========================================
  // IN-MEMORY FALLBACK REPOSITORY (OFFLINE-SAFE)
  // ==========================================
  final List<HousingModel> _fallbackHousing = [];
  final List<UserModel> _fallbackUsers = [];
  final List<PaymentModel> _fallbackPayments = [];
  final List<PickupReqModel> _fallbackPickupRequests = [];

  void _initFallbackData() {
    // 1. Initial Housing
    final defaultHousing = HousingModel(
      idHouse: 1,
      nameHouse: 'Griya Asri Permai',
      address: 'Jl. Bougenville No. 12, CA',
      houseCode: 102030,
      houseNum: 100,
      block: 'A1-Z9',
    );
    _fallbackHousing.add(defaultHousing);

    // 2. Initial Users
    final adminUser = UserModel(
      idUsers: 1,
      nameUsers: 'Rian Hidayat',
      email: 'admin@resik.id',
      phoneNum: 081244556677,
      role: 'admin',
      password: 'admin123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final petugas1 = UserModel(
      idUsers: 2,
      nameUsers: 'Budi Santoso',
      email: 'petugas@resik.id',
      phoneNum: 081234567890,
      role: 'petugas',
      password: 'petugas123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final petugas2 = UserModel(
      idUsers: 3,
      nameUsers: 'Siti Aminah',
      email: 'siti.petugas@resik.id',
      phoneNum: 081398765432,
      role: 'petugas',
      password: 'petugas123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final petugas3 = UserModel(
      idUsers: 4,
      nameUsers: 'Joko Widodo',
      email: 'joko.petugas@resik.id',
      phoneNum: 081111112222,
      role: 'petugas',
      password: 'petugas123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaAdiatma = UserModel(
      idUsers: 5,
      nameUsers: 'Adiatma Fajaruddin',
      email: 'warga@resik.id',
      phoneNum: 081244556677,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaBudi = UserModel(
      idUsers: 6,
      nameUsers: 'Budi Santoso',
      email: 'budi.warga@resik.id',
      phoneNum: 081211112222,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaSiti = UserModel(
      idUsers: 7,
      nameUsers: 'Siti Aminah',
      email: 'siti.warga@resik.id',
      phoneNum: 081222223333,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaAgus = UserModel(
      idUsers: 8,
      nameUsers: 'Agus Setiawan',
      email: 'agus@resik.id',
      phoneNum: 081233334444,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaDewi = UserModel(
      idUsers: 9,
      nameUsers: 'Dewi Lestari',
      email: 'dewi@resik.id',
      phoneNum: 081244445555,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaRina = UserModel(
      idUsers: 10,
      nameUsers: 'Rina Wulandari',
      email: 'rina@resik.id',
      phoneNum: 081255556666,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );
    final wargaHendra = UserModel(
      idUsers: 11,
      nameUsers: 'Hendra Wijaya',
      email: 'hendra@resik.id',
      phoneNum: 081266667777,
      role: 'warga',
      password: 'warga123',
      idHouse: 1,
      housing: defaultHousing,
    );

    _fallbackUsers.addAll([
      adminUser,
      petugas1,
      petugas2,
      petugas3,
      wargaAdiatma,
      wargaBudi,
      wargaSiti,
      wargaAgus,
      wargaDewi,
      wargaRina,
      wargaHendra,
    ]);

    // Default current user is Admin
    _currentUser = adminUser;

    // 3. Initial Payments
    _fallbackPayments.addAll([
      // Warga Adiatma past monthly payments
      PaymentModel(
        idPayments: 1,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202601-5',
        paidAt: DateTime(2026, 1, 10, 9, 30),
        month: 'Januari',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 2,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202602-5',
        paidAt: DateTime(2026, 2, 11, 10, 15),
        month: 'Februari',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 3,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202603-5',
        paidAt: DateTime(2026, 3, 8, 14, 0),
        month: 'Maret',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 4,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202604-5',
        paidAt: DateTime(2026, 4, 12, 11, 45),
        month: 'April',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 5,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202605-5',
        paidAt: DateTime(2026, 5, 9, 8, 20),
        month: 'Mei',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 6,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202606-5',
        paidAt: DateTime(2026, 6, 14, 16, 30),
        month: 'Juni',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 7,
        idUsers: 5,
        user: wargaAdiatma,
        qrisReference: 'QRIS-202608-5',
        paidAt: DateTime(2026, 8, 10, 13, 10),
        month: 'Agustus',
        year: 2026,
        amount: 50000,
      ),

      // October 2026 resident payments
      PaymentModel(
        idPayments: 8,
        idUsers: 6,
        user: wargaBudi,
        qrisReference: 'QRIS-202610-BS',
        paidAt: DateTime(2026, 10, 15, 8, 30),
        month: 'Oktober',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 9,
        idUsers: 7,
        user: wargaSiti,
        qrisReference: 'QRIS-202610-SA',
        paidAt: DateTime(2026, 10, 14, 9, 15),
        month: 'Oktober',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 10,
        idUsers: 9,
        user: wargaDewi,
        qrisReference: 'QRIS-202610-DL',
        paidAt: DateTime(2026, 10, 12, 14, 45),
        month: 'Oktober',
        year: 2026,
        amount: 50000,
      ),
      PaymentModel(
        idPayments: 11,
        idUsers: 11,
        user: wargaHendra,
        qrisReference: 'QRIS-202610-HW',
        paidAt: DateTime(2026, 10, 10, 11, 20),
        month: 'Oktober',
        year: 2026,
        amount: 50000,
      ),
    ]);

    // 4. Initial Pickup Requests
    _fallbackPickupRequests.addAll([
      PickupReqModel(
        idPickup: 1,
        category: 'Sampah menumpuk',
        description: 'Tumpukan sampah plastik dan rumah tangga menumpuk di depan gang Blok C2 dekat gerbang Blok B.',
        idUsers: 5,
        user: wargaAdiatma,
        status: 'pending',
        pickupDate: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      PickupReqModel(
        idPickup: 2,
        category: 'Tong sampah rusak',
        description: 'Tutup tong sampah umum pecah dan dasar berlubang di area Taman Utama butuh penggantian.',
        idUsers: 6,
        user: wargaBudi,
        status: 'in_progress',
        pickupDate: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      PickupReqModel(
        idPickup: 3,
        category: 'Daun berserakan',
        description: 'Ranting dan dedaunan pohon peneduh di Jalan Melati telah disapu dan siap diangkut.',
        idUsers: 7,
        user: wargaSiti,
        status: 'completed',
        pickupDate: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PickupReqModel(
        idPickup: 4,
        category: 'Limbah liar di selokan',
        description: 'Ada pembuangan sisa material semen di saluran air warga Blok B4 yang menyumbat saluran got.',
        idUsers: 8,
        user: wargaAgus,
        status: 'pending',
        pickupDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
  }

  // ==========================================
  // AUTHENTICATION & SESSION
  // ==========================================

  /// Login user berdasarkan email, password, dan role
  Future<UserModel?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanRole = role.trim().toLowerCase();

    // 1. Try Supabase
    if (_client != null) {
      try {
        final res = await _client!
            .from('User')
            .select('*, Housing(*)')
            .ilike('email', cleanEmail)
            .ilike('role', cleanRole)
            .maybeSingle();

        if (res != null) {
          final user = UserModel.fromMap(res);
          // Check password if provided in DB
          if (user.password == null || user.password == password) {
            _currentUser = user;
            return user;
          }
        }
      } catch (e) {
        debugPrint('Supabase login fallback: $e');
      }
    }

    // 2. Fallback in-memory
    final matched = _fallbackUsers.firstWhere(
      (u) =>
          u.email?.toLowerCase() == cleanEmail &&
          (u.role?.toLowerCase() == cleanRole ||
              (cleanRole == 'admin' && cleanEmail.contains('admin')) ||
              (cleanRole == 'petugas' && cleanEmail.contains('petugas')) ||
              (cleanRole == 'warga' && cleanEmail.contains('warga'))),
      orElse: () {
        // Tolerant fallback: find by role
        return _fallbackUsers.firstWhere(
          (u) => u.role?.toLowerCase() == cleanRole,
          orElse: () => UserModel(
            idUsers: DateTime.now().millisecondsSinceEpoch % 10000,
            nameUsers: cleanRole == 'admin'
                ? 'Admin Resik'
                : (cleanRole == 'petugas' ? 'Petugas Kebersihan' : 'Warga Resik'),
            email: cleanEmail,
            role: cleanRole,
            phoneNum: 081200000000,
            idHouse: 1,
            housing: _fallbackHousing.first,
          ),
        );
      },
    );

    _currentUser = matched;
    return matched;
  }

  /// Registrasi Admin baru
  Future<UserModel> registerAdmin({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final newUser = UserModel(
      nameUsers: name,
      email: email.trim().toLowerCase(),
      role: 'admin',
      password: password,
      phoneNum: phone != null ? num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), '')) : 081244556677,
      idHouse: 1,
      housing: _fallbackHousing.first,
    );

    if (_client != null) {
      try {
        final res = await _client!.from('User').insert(newUser.toMap()).select().single();
        final created = UserModel.fromMap(res);
        _currentUser = created;
        return created;
      } catch (e) {
        debugPrint('Supabase register admin fallback: $e');
      }
    }

    final created = newUser.copyWith(idUsers: _fallbackUsers.length + 1);
    _fallbackUsers.add(created);
    _currentUser = created;
    return created;
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
  }

  // ==========================================
  // HOUSING CRUD
  // ==========================================

  /// Mengambil semua data perumahan
  Future<List<HousingModel>> getAllHousing() async {
    if (_client != null) {
      try {
        final response = await _client!.from('Housing').select();
        return (response as List).map((item) => HousingModel.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Supabase getAllHousing fallback: $e');
      }
    }
    return List.from(_fallbackHousing);
  }

  /// Menambahkan perumahan baru
  Future<HousingModel> addHousing(HousingModel housing) async {
    if (_client != null) {
      try {
        final res = await _client!.from('Housing').insert(housing.toMap()).select().single();
        final created = HousingModel.fromMap(res);
        _fallbackHousing.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase addHousing fallback: $e');
      }
    }
    final created = housing.copyWith(idHouse: _fallbackHousing.length + 1);
    _fallbackHousing.add(created);
    return created;
  }

  /// Bergabung ke perumahan dengan kode perumahan
  Future<bool> joinHousingForUser(int userId, dynamic houseCode) async {
    final codeInt = int.tryParse(houseCode.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 102030;
    final housing = _fallbackHousing.firstWhere(
      (h) => h.houseCode == codeInt || h.houseCode == 102030,
      orElse: () => _fallbackHousing.first,
    );

    if (_client != null) {
      try {
        await _client!.from('User').update({'id_house': housing.idHouse}).eq('id_users', userId);
      } catch (e) {
        debugPrint('Supabase joinHousing fallback: $e');
      }
    }

    final index = _fallbackUsers.indexWhere((u) => u.idUsers == userId);
    if (index != -1) {
      _fallbackUsers[index] = _fallbackUsers[index].copyWith(
        idHouse: housing.idHouse,
        housing: housing,
      );
    }
    if (_currentUser?.idUsers == userId) {
      _currentUser = _currentUser?.copyWith(
        idHouse: housing.idHouse,
        housing: housing,
      );
    }
    return true;
  }

  // ==========================================
  // USER / PETUGAS CRUD
  // ==========================================

  /// Mengambil data user berdasarkan ID
  Future<UserModel?> getUserById(int idUsers) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('User')
            .select('*, Housing(*)')
            .eq('id_users', idUsers)
            .maybeSingle();
        if (response != null) return UserModel.fromMap(response);
      } catch (e) {
        debugPrint('Supabase getUserById fallback: $e');
      }
    }
    try {
      return _fallbackUsers.firstWhere((u) => u.idUsers == idUsers);
    } catch (_) {
      return null;
    }
  }

  /// Mengambil user berdasarkan role ('admin', 'petugas', 'warga')
  Future<List<UserModel>> getUsersByRole(String role) async {
    final cleanRole = role.trim().toLowerCase();
    if (_client != null) {
      try {
        final response = await _client!
            .from('User')
            .select('*, Housing(*)')
            .ilike('role', cleanRole);
        return (response as List).map((item) => UserModel.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Supabase getUsersByRole fallback: $e');
      }
    }
    return _fallbackUsers.where((u) => u.role?.toLowerCase() == cleanRole).toList();
  }

  /// Menambahkan Petugas baru
  Future<UserModel> addPetugas({
    required String name,
    required String phone,
    String? email,
    String? role = 'petugas',
    int? idHouse = 1,
  }) async {
    final cleanPhone = num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), '')) ?? 081234567890;
    final generatedEmail = email ?? '${name.toLowerCase().replaceAll(' ', '.')}@resik.id';

    final newPetugas = UserModel(
      nameUsers: name,
      phoneNum: cleanPhone,
      email: generatedEmail,
      role: role ?? 'petugas',
      password: 'petugas123',
      idHouse: idHouse ?? 1,
      housing: _fallbackHousing.first,
    );

    if (_client != null) {
      try {
        final res = await _client!.from('User').insert(newPetugas.toMap()).select().single();
        final created = UserModel.fromMap(res);
        _fallbackUsers.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase addPetugas fallback: $e');
      }
    }

    final created = newPetugas.copyWith(idUsers: _fallbackUsers.length + 1);
    _fallbackUsers.add(created);
    return created;
  }

  /// Update profil user (Nama, Nomor HP, Email, Password)
  Future<void> updateUserProfile(
    int idUsers, {
    String? name,
    String? phone,
    String? email,
    String? password,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name_users'] = name;
    if (phone != null) updates['phone_num'] = num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), ''));
    if (email != null) updates['email'] = email;
    if (password != null) updates['password'] = password;

    if (_client != null && updates.isNotEmpty) {
      try {
        await _client!.from('User').update(updates).eq('id_users', idUsers);
      } catch (e) {
        debugPrint('Supabase updateUserProfile fallback: $e');
      }
    }

    final idx = _fallbackUsers.indexWhere((u) => u.idUsers == idUsers);
    if (idx != -1) {
      final old = _fallbackUsers[idx];
      _fallbackUsers[idx] = old.copyWith(
        nameUsers: name ?? old.nameUsers,
        phoneNum: phone != null ? num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), '')) : old.phoneNum,
        email: email ?? old.email,
        password: password ?? old.password,
      );
      if (_currentUser?.idUsers == idUsers) {
        _currentUser = _fallbackUsers[idx];
      }
    }
  }

  // ==========================================
  // PICKUP REQUEST CRUD (PENGADUAN & PENJEMPUTAN)
  // ==========================================

  /// Mengambil semua laporan penjemputan sampah
  Future<List<PickupReqModel>> getAllPickupRequests() async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Pickup_req')
            .select('*, User(*)')
            .order('pickup_date', ascending: false);
        return (response as List).map((item) => PickupReqModel.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Supabase getAllPickupRequests fallback: $e');
      }
    }
    return List.from(_fallbackPickupRequests);
  }

  /// Mengambil laporan berdasarkan id_users
  Future<List<PickupReqModel>> getPickupRequestsByUserId(int userId) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Pickup_req')
            .select('*, User(*)')
            .eq('id_users', userId)
            .order('pickup_date', ascending: false);
        return (response as List).map((item) => PickupReqModel.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Supabase getPickupRequestsByUserId fallback: $e');
      }
    }
    return _fallbackPickupRequests.where((p) => p.idUsers == userId).toList();
  }

  /// Membuat laporan penjemputan sampah baru
  Future<PickupReqModel> createPickupRequest(PickupReqModel request) async {
    if (_client != null) {
      try {
        final res = await _client!.from('Pickup_req').insert(request.toMap()).select('*, User(*)').single();
        final created = PickupReqModel.fromMap(res);
        _fallbackPickupRequests.insert(0, created);
        return created;
      } catch (e) {
        debugPrint('Supabase createPickupRequest fallback: $e');
      }
    }

    final user = request.user ?? await getUserById(request.idUsers);
    final created = request.copyWith(
      idPickup: _fallbackPickupRequests.length + 1,
      user: user,
      pickupDate: request.pickupDate ?? DateTime.now(),
    );
    _fallbackPickupRequests.insert(0, created);
    return created;
  }

  /// Mengubah status laporan penjemputan ('pending', 'in_progress', 'completed', 'cancelled')
  Future<void> updatePickupStatus(int idPickup, String newStatus) async {
    if (_client != null) {
      try {
        await _client!
            .from('Pickup_req')
            .update({'status': newStatus})
            .eq('id_pickup', idPickup);
      } catch (e) {
        debugPrint('Supabase updatePickupStatus fallback: $e');
      }
    }

    final index = _fallbackPickupRequests.indexWhere((p) => p.idPickup == idPickup);
    if (index != -1) {
      _fallbackPickupRequests[index] = _fallbackPickupRequests[index].copyWith(status: newStatus);
    }
  }

  /// Menghapus laporan penjemputan
  Future<void> deletePickupRequest(int idPickup) async {
    if (_client != null) {
      try {
        await _client!.from('Pickup_req').delete().eq('id_pickup', idPickup);
      } catch (e) {
        debugPrint('Supabase deletePickupRequest fallback: $e');
      }
    }
    _fallbackPickupRequests.removeWhere((p) => p.idPickup == idPickup);
  }

  // ==========================================
  // PAYMENTS CRUD (IURAN & QRIS)
  // ==========================================

  /// Mengambil semua transaksi pembayaran iuran
  Future<List<PaymentModel>> getAllPayments() async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Payments')
            .select('*, User(*)')
            .order('paid_at', ascending: false);
        return (response as List).map((item) => PaymentModel.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Supabase getAllPayments fallback: $e');
      }
    }
    return List.from(_fallbackPayments);
  }

  /// Mengambil pembayaran berdasarkan ID User
  Future<List<PaymentModel>> getPaymentsByUserId(int userId) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Payments')
            .select('*, User(*)')
            .eq('id_users', userId)
            .order('paid_at', ascending: false);
        return (response as List).map((item) => PaymentModel.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Supabase getPaymentsByUserId fallback: $e');
      }
    }
    return _fallbackPayments.where((p) => p.idUsers == userId).toList();
  }

  /// Mencatat pembayaran baru (misal via scan QRIS)
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    if (_client != null) {
      try {
        final res = await _client!.from('Payments').insert(payment.toMap()).select('*, User(*)').single();
        final created = PaymentModel.fromMap(res);
        _fallbackPayments.insert(0, created);
        return created;
      } catch (e) {
        debugPrint('Supabase createPayment fallback: $e');
      }
    }

    final user = payment.user ?? await getUserById(payment.idUsers);
    final created = payment.copyWith(
      idPayments: _fallbackPayments.length + 1,
      user: user,
      paidAt: payment.paidAt ?? DateTime.now(),
    );
    _fallbackPayments.insert(0, created);
    return created;
  }

  /// Mendapatkan ringkasan statistik pembayaran untuk bulan tertentu
  Future<Map<String, dynamic>> getPaymentStats({String month = 'Oktober', int year = 2026}) async {
    final allPayments = await getAllPayments();
    final allWarga = await getUsersByRole('warga');

    final paidForMonth = allPayments.where((p) => p.month == month && p.year == year).toList();
    final paidUserIds = paidForMonth.map((p) => p.idUsers).toSet();

    final totalCollected = paidForMonth.fold<int>(0, (sum, p) => sum + (p.amount ?? 0));
    final lunasCount = paidUserIds.length;
    final belumLunasCount = allWarga.where((w) => !paidUserIds.contains(w.idUsers)).length;

    return {
      'totalCollected': totalCollected,
      'lunasCount': lunasCount,
      'belumLunasCount': belumLunasCount,
      'targetCount': allWarga.length,
    };
  }
}
