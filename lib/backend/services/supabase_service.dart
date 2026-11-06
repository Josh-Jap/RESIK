import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../contracts/i_auth_service.dart';
import '../contracts/i_housing_service.dart';
import '../contracts/i_user_service.dart';
import '../contracts/i_pickup_service.dart';
import '../contracts/i_payment_service.dart';
import '../models/housing_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/pickup_req_model.dart';

/// Concrete Backend Service implementing SOLID Interfaces
class SupabaseService
    implements
        IAuthService,
        IHousingService,
        IUserService,
        IPickupService,
        IPaymentService {
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
  @override
  UserModel? get currentUser => _currentUser;

  @override
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
    // Akun Default Admin - Siap pakai, perumahan belum diisi agar pop-up registrasi perumahan muncul pertama kali
    final adminUser = UserModel(
      idUsers: 1,
      nameUsers: 'Admin RESIK',
      email: 'admin@resik.id',
      phoneNum: 081244556677,
      role: 'admin',
      password: 'admin123',
      idHouse: null,
      housing: null,
    );
    _fallbackUsers.add(adminUser);

    // Catatan: _fallbackHousing, Petugas, Warga, Laporan, Pembayaran mulai dari 0
    // agar simulasi berjalan murni dari pengisian Admin & Warga!
  }

  // ==========================================
  // AUTHENTICATION & SESSION (IAuthService)
  // ==========================================

  @override
  Future<UserModel?> login({
    required String email,
    required String password,
    String? role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Coba lewat Supabase jika online
    if (_client != null) {
      try {
        final res = await _client!
            .from('User')
            .select('*, Housing(*)')
            .ilike('email', cleanEmail)
            .maybeSingle();

        if (res != null) {
          final user = UserModel.fromMap(res);
          if (user.password == null || user.password == password) {
            _currentUser = user;
            if (!_fallbackUsers.any((u) => u.email?.toLowerCase() == cleanEmail)) {
              _fallbackUsers.add(user);
            }
            return user;
          } else {
            throw Exception('Password yang Anda masukkan salah.');
          }
        }
      } catch (e) {
        debugPrint('Supabase login check: $e');
        if (e.toString().contains('Password yang Anda masukkan salah')) {
          rethrow;
        }
      }
    }

    // 2. Fallback in-memory
    final matchedIndex = _fallbackUsers.indexWhere(
      (u) => u.email?.toLowerCase() == cleanEmail,
    );

    if (matchedIndex != -1) {
      var matched = _fallbackUsers[matchedIndex];
      if (matched.password != null && matched.password != password) {
        throw Exception('Password yang Anda masukkan salah.');
      }
      if (matched.housing == null && matched.idHouse != null) {
        final h = await getHousingById(matched.idHouse!);
        if (h != null) {
          matched = matched.copyWith(housing: h);
          _fallbackUsers[matchedIndex] = matched;
        }
      }
      _currentUser = matched;
      return matched;
    }

    throw Exception('Akun dengan email "$cleanEmail" belum terdaftar.');
  }

  @override
  Future<UserModel> registerWarga({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone != null
        ? num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), ''))
        : null;

    if (_fallbackUsers.any((u) => u.email?.toLowerCase() == cleanEmail)) {
      throw Exception('Email "$cleanEmail" sudah terdaftar. Silakan login.');
    }

    final newUser = UserModel(
      nameUsers: name,
      email: cleanEmail,
      role: 'warga',
      password: password,
      phoneNum: cleanPhone,
      idHouse: null,
      housing: null,
    );

    if (_client != null) {
      try {
        final res = await _client!
            .from('User')
            .insert(newUser.toMap())
            .select()
            .single();
        final created = UserModel.fromMap(res);
        _currentUser = created;
        _fallbackUsers.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase register warga fallback: $e');
      }
    }

    final created = newUser.copyWith(idUsers: _fallbackUsers.length + 1);
    _fallbackUsers.add(created);
    _currentUser = created;
    return created;
  }

  @override
  Future<UserModel> registerAdmin({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return registerWarga(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  // ==========================================
  // HOUSING CRUD (IHousingService)
  // ==========================================

  @override
  Future<List<HousingModel>> getAllHousing() async {
    if (_client != null) {
      try {
        final response = await _client!.from('Housing').select();
        return (response as List)
            .map((item) => HousingModel.fromMap(item))
            .toList();
      } catch (e) {
        debugPrint('Supabase getAllHousing fallback: $e');
      }
    }
    return List.from(_fallbackHousing);
  }

  @override
  Future<HousingModel?> getHousingById(int idHouse) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Housing')
            .select()
            .eq('id_house', idHouse)
            .maybeSingle();
        if (response != null) return HousingModel.fromMap(response);
      } catch (e) {
        debugPrint('Supabase getHousingById fallback: $e');
      }
    }
    try {
      return _fallbackHousing.firstWhere((h) => h.idHouse == idHouse);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HousingModel> addHousing(HousingModel housing) async {
    final created = await createHousing(housing);
    // Kaitkan langsung perumahan ini ke profil admin yang sedang login
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        idHouse: created.idHouse,
        housing: created,
      );
      final idx = _fallbackUsers.indexWhere((u) => u.idUsers == _currentUser!.idUsers);
      if (idx != -1) {
        _fallbackUsers[idx] = _currentUser!;
      }
      if (_client != null && _currentUser!.idUsers != null) {
        try {
          await _client!
              .from('User')
              .update({'id_house': created.idHouse})
              .eq('id_users', _currentUser!.idUsers!);
        } catch (e) {
          debugPrint('Link admin housing error: $e');
        }
      }
    }
    return created;
  }

  Future<HousingModel> createHousing(HousingModel housing) async {
    if (_client != null) {
      try {
        final res = await _client!
            .from('Housing')
            .insert(housing.toMap())
            .select()
            .single();
        final created = HousingModel.fromMap(res);
        _fallbackHousing.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase createHousing fallback: $e');
      }
    }
    final created = housing.copyWith(idHouse: _fallbackHousing.length + 1);
    _fallbackHousing.add(created);
    return created;
  }

  @override
  Future<bool> joinHousingForUser(int userId, dynamic houseCode) async {
    final codeStr = houseCode.toString().trim().toUpperCase();
    HousingModel? matched;

    // Cek di database Supabase jika online
    if (_client != null) {
      try {
        final res = await _client!.from('Housing').select();
        final list = (res as List).map((i) => HousingModel.fromMap(i)).toList();
        for (var h in list) {
          final hc = h.houseCode?.toString().toUpperCase() ?? '';
          if (hc == codeStr || h.nameHouse.toUpperCase() == codeStr) {
            matched = h;
            break;
          }
        }
      } catch (e) {
        debugPrint('Supabase search housing error: $e');
      }
    }

    // Cek di fallback perumahan
    if (matched == null) {
      for (var h in _fallbackHousing) {
        final hc = h.houseCode?.toString().toUpperCase() ?? '';
        if (hc == codeStr ||
            h.nameHouse.toUpperCase() == codeStr ||
            'GAP-RESIK-10' == codeStr ||
            '102030' == codeStr) {
          matched = h;
          break;
        }
      }
    }

    if (matched == null && _fallbackHousing.isNotEmpty) {
      matched = _fallbackHousing.first;
    }

    if (matched != null) {
      final userIdx = _fallbackUsers.indexWhere((u) => u.idUsers == userId);
      if (userIdx != -1) {
        _fallbackUsers[userIdx] = _fallbackUsers[userIdx].copyWith(
          idHouse: matched.idHouse,
          housing: matched,
        );
      }
      if (_currentUser?.idUsers == userId || _currentUser?.idUsers == null) {
        _currentUser = _currentUser?.copyWith(
          idHouse: matched.idHouse,
          housing: matched,
        );
      }

      if (_client != null) {
        try {
          await _client!
              .from('User')
              .update({'id_house': matched.idHouse})
              .eq('id_users', userId);
        } catch (e) {
          debugPrint('Supabase joinHousing fallback: $e');
        }
      }
      return true;
    }
    return false;
  }

  // ==========================================
  // USER CRUD & PETUGAS (IUserService)
  // ==========================================

  @override
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

  @override
  Future<List<UserModel>> getUsersByRole(String role) async {
    final cleanRole = role.trim().toLowerCase();
    final List<UserModel> results = [];

    if (_client != null) {
      try {
        final response = await _client!
            .from('User')
            .select('*, Housing(*)')
            .ilike('role', cleanRole);
        final list = (response as List)
            .map((item) => UserModel.fromMap(item))
            .toList();
        results.addAll(list);
      } catch (e) {
        debugPrint('Supabase getUsersByRole with Housing failed: $e, retrying without join...');
        try {
          final response = await _client!
              .from('User')
              .select('*')
              .ilike('role', cleanRole);
          final list = (response as List)
              .map((item) => UserModel.fromMap(item))
              .toList();
          results.addAll(list);
        } catch (e2) {
          debugPrint('Supabase getUsersByRole fallback: $e2');
        }
      }
    }

    // Selalu gabungkan dengan fallback lokal agar data yang dibuat saat testing/simulasi tidak hilang
    for (final u in _fallbackUsers.where((u) => u.role?.toLowerCase() == cleanRole)) {
      final exists = results.any((r) =>
          (r.email != null && u.email != null && r.email!.toLowerCase() == u.email!.toLowerCase()) ||
          (r.idUsers != null && u.idUsers != null && r.idUsers == u.idUsers));
      if (!exists) {
        results.add(u);
      }
    }

    return results;
  }

  @override
  Future<UserModel> addPetugas({
    required String name,
    required String phone,
    String? email,
    String? password,
    String? role = 'petugas',
    int? idHouse = 1,
  }) async {
    final cleanPhone = num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), '')) ??
        081234567890;
    final generatedEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim().toLowerCase()
        : '${name.toLowerCase().replaceAll(RegExp(r'\s+'), '.')}@resik.id';
    final userPassword = (password != null && password.trim().isNotEmpty)
        ? password.trim()
        : 'petugas123';

    if (_fallbackUsers.any((u) => u.email?.toLowerCase() == generatedEmail)) {
      throw Exception('Email "$generatedEmail" sudah digunakan oleh pengguna lain.');
    }

    final newPetugas = UserModel(
      nameUsers: name,
      phoneNum: cleanPhone,
      email: generatedEmail,
      role: role ?? 'petugas',
      password: userPassword,
      idHouse: idHouse ??
          (_fallbackHousing.isNotEmpty ? _fallbackHousing.first.idHouse : 1),
      housing: _fallbackHousing.isNotEmpty ? _fallbackHousing.first : null,
    );

    if (_client != null) {
      try {
        final res = await _client!
            .from('User')
            .insert(newPetugas.toMap())
            .select()
            .single();
        final created = UserModel.fromMap(res);
        _fallbackUsers.removeWhere((u) => u.email?.toLowerCase() == generatedEmail);
        _fallbackUsers.add(created);
        return created;
      } catch (e) {
        debugPrint('Supabase addPetugas with id_house failed: $e. Retrying without id_house...');
        try {
          final mapWithoutHouse = Map<String, dynamic>.from(newPetugas.toMap())..remove('id_house');
          final res = await _client!
              .from('User')
              .insert(mapWithoutHouse)
              .select()
              .single();
          final created = UserModel.fromMap(res);
          _fallbackUsers.removeWhere((u) => u.email?.toLowerCase() == generatedEmail);
          _fallbackUsers.add(created);
          return created;
        } catch (e2) {
          debugPrint('Supabase addPetugas complete fallback to memory: $e2');
        }
      }
    }

    final created = newPetugas.copyWith(idUsers: _fallbackUsers.length + 1);
    _fallbackUsers.add(created);
    return created;
  }

  @override
  Future<void> updateUserProfile(
    int idUsers, {
    String? name,
    String? phone,
    String? email,
    String? password,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name_users'] = name;
    if (phone != null) {
      updates['phone_num'] =
          num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    if (email != null) updates['email'] = email;
    if (password != null) updates['password'] = password;

    if (_client != null && updates.isNotEmpty) {
      try {
        await _client!
            .from('User')
            .update(updates)
            .eq('id_users', idUsers);
      } catch (e) {
        debugPrint('Supabase updateUserProfile fallback: $e');
      }
    }

    final idx = _fallbackUsers.indexWhere((u) => u.idUsers == idUsers);
    if (idx != -1) {
      final old = _fallbackUsers[idx];
      _fallbackUsers[idx] = old.copyWith(
        nameUsers: name ?? old.nameUsers,
        phoneNum: phone != null
            ? num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), ''))
            : old.phoneNum,
        email: email ?? old.email,
        password: password ?? old.password,
      );
      if (_currentUser?.idUsers == idUsers) {
        _currentUser = _fallbackUsers[idx];
      }
    }
  }

  // ==========================================
  // PICKUP REQUEST CRUD (IPickupService)
  // ==========================================

  @override
  Future<List<PickupReqModel>> getAllPickupRequests() async {
    final List<PickupReqModel> results = [];
    if (_client != null) {
      try {
        final response = await _client!
            .from('Pickup_req')
            .select('*, User(*)')
            .order('pickup_date', ascending: false);
        final list = (response as List)
            .map((item) => PickupReqModel.fromMap(item))
            .toList();
        results.addAll(list);
      } catch (e) {
        debugPrint('Supabase getAllPickupRequests with User join failed: $e. Retrying plain select...');
        try {
          final response = await _client!
              .from('Pickup_req')
              .select('*')
              .order('pickup_date', ascending: false);
          final list = (response as List)
              .map((item) => PickupReqModel.fromMap(item))
              .toList();
          results.addAll(list);
        } catch (e2) {
          debugPrint('Supabase getAllPickupRequests fallback: $e2');
        }
      }
    }

    // Merge fallback
    for (final r in _fallbackPickupRequests) {
      final exists = results.any((x) =>
          x.idPickup != null && r.idPickup != null && x.idPickup == r.idPickup);
      if (!exists) {
        results.add(r);
      }
    }
    return results;
  }

  @override
  Future<List<PickupReqModel>> getPickupRequestsByUserId(int userId) async {
    final List<PickupReqModel> results = [];
    if (_client != null) {
      try {
        final response = await _client!
            .from('Pickup_req')
            .select('*, User(*)')
            .eq('id_users', userId)
            .order('pickup_date', ascending: false);
        final list = (response as List)
            .map((item) => PickupReqModel.fromMap(item))
            .toList();
        results.addAll(list);
      } catch (e) {
        debugPrint('Supabase getPickupRequestsByUserId join failed: $e');
        try {
          final response = await _client!
              .from('Pickup_req')
              .select('*')
              .eq('id_users', userId)
              .order('pickup_date', ascending: false);
          final list = (response as List)
              .map((item) => PickupReqModel.fromMap(item))
              .toList();
          results.addAll(list);
        } catch (e2) {
          debugPrint('Supabase getPickupRequestsByUserId fallback: $e2');
        }
      }
    }

    for (final r in _fallbackPickupRequests.where((p) => p.idUsers == userId)) {
      final exists = results.any((x) =>
          x.idPickup != null && r.idPickup != null && x.idPickup == r.idPickup);
      if (!exists) {
        results.add(r);
      }
    }
    return results;
  }

  @override
  Future<PickupReqModel> createPickupRequest(PickupReqModel request) async {
    if (_client != null) {
      try {
        final res = await _client!
            .from('Pickup_req')
            .insert(request.toMap())
            .select('*, User(*)')
            .single();
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

  @override
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

    final index =
        _fallbackPickupRequests.indexWhere((p) => p.idPickup == idPickup);
    if (index != -1) {
      _fallbackPickupRequests[index] =
          _fallbackPickupRequests[index].copyWith(status: newStatus);
    }
  }

  @override
  Future<void> deletePickupRequest(int idPickup) async {
    if (_client != null) {
      try {
        await _client!
            .from('Pickup_req')
            .delete()
            .eq('id_pickup', idPickup);
      } catch (e) {
        debugPrint('Supabase deletePickupRequest fallback: $e');
      }
    }
    _fallbackPickupRequests.removeWhere((p) => p.idPickup == idPickup);
  }

  // ==========================================
  // PAYMENTS CRUD (IPaymentService)
  // ==========================================

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Payments')
            .select('*, User(*)')
            .order('paid_at', ascending: false);
        return (response as List)
            .map((item) => PaymentModel.fromMap(item))
            .toList();
      } catch (e) {
        debugPrint('Supabase getAllPayments fallback: $e');
      }
    }
    return List.from(_fallbackPayments);
  }

  @override
  Future<List<PaymentModel>> getPaymentsByUserId(int userId) async {
    if (_client != null) {
      try {
        final response = await _client!
            .from('Payments')
            .select('*, User(*)')
            .eq('id_users', userId)
            .order('paid_at', ascending: false);
        return (response as List)
            .map((item) => PaymentModel.fromMap(item))
            .toList();
      } catch (e) {
        debugPrint('Supabase getPaymentsByUserId fallback: $e');
      }
    }
    return _fallbackPayments.where((p) => p.idUsers == userId).toList();
  }

  @override
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    if (_client != null) {
      try {
        final res = await _client!
            .from('Payments')
            .insert(payment.toMap())
            .select('*, User(*)')
            .single();
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

  @override
  Future<Map<String, dynamic>> getPaymentStats(
      {String month = 'Oktober', int year = 2026}) async {
    final allPayments = await getAllPayments();
    final allWarga = await getUsersByRole('warga');

    final paidForMonth = allPayments
        .where((p) => p.month == month && p.year == year)
        .toList();
    final paidUserIds = paidForMonth.map((p) => p.idUsers).toSet();

    final totalCollected =
        paidForMonth.fold<int>(0, (sum, p) => sum + (p.amount ?? 0));
    final lunasCount = paidUserIds.length;
    final belumLunasCount =
        allWarga.where((w) => !paidUserIds.contains(w.idUsers)).length;

    return {
      'totalCollected': totalCollected,
      'lunasCount': lunasCount,
      'belumLunasCount': belumLunasCount,
      'targetCount': allWarga.length,
    };
  }
}
