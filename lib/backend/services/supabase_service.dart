import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
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
import '../models/schedule_model.dart';

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

  /// Helper untuk hashing password menggunakan SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    return sha256.convert(bytes).toString();
  }

  // ==========================================
  // IN-MEMORY FALLBACK REPOSITORY (OFFLINE-SAFE)
  // ==========================================
  final List<HousingModel> _fallbackHousing = [];
  final List<UserModel> _fallbackUsers = [];
  final List<PaymentModel> _fallbackPayments = [];
  final List<PickupReqModel> _fallbackPickupRequests = [];
  final List<ScheduleModel> _fallbackSchedules = [];

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
    final cleanPassword = password.trim();

    // 1. Cek akun khusus Admin bawaan terlebih dahulu
    // Supaya Admin selalu bisa masuk langsung tanpa hambatan auth/verifikasi email
    if (cleanEmail == 'admin@resik.id') {
      if (cleanPassword != 'admin123') {
        throw Exception('Email atau kata sandi salah. Silakan coba lagi.');
      }
      var adminUser = _fallbackUsers.firstWhere(
        (u) => u.email?.toLowerCase() == 'admin@resik.id',
        orElse: () => UserModel(
          idUsers: 1,
          nameUsers: 'Admin RESIK',
          email: 'admin@resik.id',
          role: 'admin',
          password: 'admin123',
        ),
      );

      // Cek apakah di database Supabase Admin sudah punya data profil / perumahan
      if (_client != null) {
        try {
          final res = await _client!
              .from('User')
              .select('*, Housing(*)')
              .ilike('email', 'admin@resik.id')
              .maybeSingle();
          if (res != null) {
            adminUser = UserModel.fromMap(res);
          } else {
            // Jika akun User admin belum ada di DB, buatkan langsung agar id_house tersimpan permanen
            try {
              final insertRes = await _client!
                  .from('User')
                  .insert({
                    'name_users': adminUser.nameUsers,
                    'email': 'admin@resik.id',
                    'role': 'admin',
                    'password': 'admin123',
                  })
                  .select('*, Housing(*)')
                  .single();
              adminUser = UserModel.fromMap(insertRes);
            } catch (insErr) {
              debugPrint('Insert default admin to User table: $insErr');
            }
          }
        } catch (dbErr) {
          debugPrint('Supabase fetch admin User: $dbErr');
        }
      }

      if (adminUser.housing == null && adminUser.idHouse != null) {
        final h = await getHousingById(adminUser.idHouse!);
        if (h != null) adminUser = adminUser.copyWith(housing: h);
      }

      _currentUser = adminUser;
      return adminUser;
    }

    // 2. Cek Akun Petugas / Akun Internal (@resik.id)
    // Akun petugas dibuat langsung oleh Admin, sehingga bisa login langsung tanpa verifikasi email!
    if (_client != null) {
      try {
        final res = await _client!
            .from('User')
            .select('*, Housing(*)')
            .ilike('email', cleanEmail)
            .maybeSingle();

        if (res != null) {
          final userDb = UserModel.fromMap(res);
          final userRole = (userDb.role ?? '').toLowerCase();

          // Jika ini adalah Petugas (atau domain @resik.id)
          if (userRole == 'petugas' || cleanEmail.endsWith('@resik.id')) {
            final hashedInput = hashPassword(cleanPassword);
            final storedPass = userDb.password;

            if (storedPass != null &&
                storedPass != cleanPassword &&
                storedPass != hashedInput) {
              throw Exception(
                'Email atau kata sandi salah. Silakan coba lagi.',
              );
            }

            var fullPetugas = userDb;
            if (fullPetugas.housing == null && fullPetugas.idHouse != null) {
              final h = await getHousingById(fullPetugas.idHouse!);
              if (h != null) fullPetugas = fullPetugas.copyWith(housing: h);
            }

            _currentUser = fullPetugas;
            return fullPetugas;
          }
        }
      } catch (e) {
        debugPrint('Direct check for petugas login: $e');
        if (e.toString().contains('Email atau kata sandi salah')) {
          rethrow;
        }
      }
    }

    // 2. Coba lewat Supabase Auth (Verifikasi Email Supabase untuk Warga/Petugas) jika online
    if (_client != null) {
      try {
        final authRes = await _client!.auth.signInWithPassword(
          email: cleanEmail,
          password: cleanPassword,
        );

        // Login auth berhasil (email telah diverifikasi)
        UserModel? user;
        try {
          final res = await _client!
              .from('User')
              .select('*, Housing(*)')
              .ilike('email', cleanEmail)
              .maybeSingle();

          if (res != null) {
            user = UserModel.fromMap(res);
          }
        } catch (dbErr) {
          debugPrint('Supabase fetch User table after auth: $dbErr');
        }

        user ??= UserModel(
          nameUsers:
              authRes.user?.userMetadata?['name'] as String? ??
              cleanEmail.split('@').first,
          email: cleanEmail,
          role: authRes.user?.userMetadata?['role'] as String? ?? 'warga',
        );

        _currentUser = user;
        if (!_fallbackUsers.any((u) => u.email?.toLowerCase() == cleanEmail)) {
          _fallbackUsers.add(user);
        }
        return user;
      } on AuthException catch (e) {
        debugPrint('Supabase AuthException: ${e.message}');
        final msg = e.message.toLowerCase();
        if (msg.contains('email not confirmed') ||
            msg.contains('not confirmed') ||
            msg.contains('unconfirmed')) {
          throw Exception(
            'EMAIL_NOT_CONFIRMED:Email Anda belum diverifikasi. Silakan periksa inbox atau folder spam email Anda dan klik tautan verifikasi Supabase sebelum masuk.',
          );
        } else if (msg.contains('invalid login credentials') ||
            msg.contains('invalid credentials') ||
            msg.contains('invalid email or password')) {
          throw Exception('Email atau kata sandi salah. Silakan coba lagi.');
        } else {
          throw Exception(e.message);
        }
      } catch (e) {
        debugPrint('Supabase login check: $e');
        if (e.toString().contains('EMAIL_NOT_CONFIRMED') ||
            e.toString().contains('Email atau kata sandi salah')) {
          rethrow;
        }
      }
    }

    // 3. Fallback in-memory
    final matchedIndex = _fallbackUsers.indexWhere(
      (u) => u.email?.toLowerCase() == cleanEmail,
    );

    if (matchedIndex != -1) {
      var matched = _fallbackUsers[matchedIndex];
      final hashedInput = hashPassword(cleanPassword);
      if (matched.password != null &&
          matched.password != cleanPassword &&
          matched.password != hashedInput) {
        throw Exception('Email atau kata sandi salah. Silakan coba lagi.');
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

    final hashedPassword = hashPassword(password);
    final newUser = UserModel(
      nameUsers: name,
      email: cleanEmail,
      role: 'warga',
      password: hashedPassword,
      phoneNum: cleanPhone,
      idHouse: null,
      housing: null,
    );

    if (_client != null) {
      try {
        // 1. Mendaftar via Supabase Auth (Memicu pengiriman link verifikasi email resmi Supabase)
        await _client!.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {'name': name, 'phone': phone, 'role': 'warga'},
        );

        // 2. Simpan profil ke tabel User
        try {
          final res = await _client!
              .from('User')
              .insert(newUser.toMap())
              .select()
              .single();
          final created = UserModel.fromMap(res);
          _fallbackUsers.add(created);
          return created;
        } catch (dbErr) {
          debugPrint('User table insert fallback: $dbErr');
        }

        _fallbackUsers.add(newUser);
        return newUser;
      } on AuthException catch (e) {
        debugPrint('Supabase Auth signUp error: ${e.message}');
        if (e.message.toLowerCase().contains('already registered') ||
            e.message.toLowerCase().contains('already exists')) {
          throw Exception(
            'Email "$cleanEmail" sudah terdaftar. Silakan login atau periksa email verifikasi Anda.',
          );
        }
        throw Exception(e.message);
      } catch (e) {
        debugPrint('Supabase register warga fallback: $e');
        if (e.toString().contains('sudah terdaftar')) rethrow;
      }
    }

    if (_fallbackUsers.any((u) => u.email?.toLowerCase() == cleanEmail)) {
      throw Exception('Email "$cleanEmail" sudah terdaftar. Silakan login.');
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
  Future<void> resendVerificationEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_client != null) {
      try {
        await _client!.auth.resend(type: OtpType.signup, email: cleanEmail);
      } catch (e) {
        debugPrint('Supabase resend email error: $e');
        throw Exception('Gagal mengirim ulang email verifikasi: $e');
      }
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    if (_client != null) {
      try {
        await _client!.auth.signOut();
      } catch (e) {
        debugPrint('Supabase signOut error: $e');
      }
    }
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
      final idx = _fallbackUsers.indexWhere(
        (u) =>
            u.idUsers == _currentUser!.idUsers ||
            u.email?.toLowerCase() == _currentUser!.email?.toLowerCase(),
      );
      if (idx != -1) {
        _fallbackUsers[idx] = _currentUser!;
      }
      if (_client != null) {
        try {
          if (_currentUser!.idUsers != null) {
            await _client!
                .from('User')
                .update({'id_house': created.idHouse})
                .eq('id_users', _currentUser!.idUsers!);
          } else if (_currentUser!.email != null) {
            await _client!
                .from('User')
                .update({'id_house': created.idHouse})
                .ilike('email', _currentUser!.email!);
          }
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
    if (codeStr.isEmpty) return false;

    HousingModel? matched;

    // 1. Cek di database Supabase jika online
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

    // 2. Cek di fallback perumahan (hanya cocokkan kode atau nama perumahan yang benar-benar tersimpan)
    if (matched == null) {
      for (var h in _fallbackHousing) {
        final hc = h.houseCode?.toString().toUpperCase() ?? '';
        if (hc == codeStr || h.nameHouse.toUpperCase() == codeStr) {
          matched = h;
          break;
        }
      }
    }

    // Jika kode tidak cocok dengan perumahan manapun yang dibuat admin, tolak!
    if (matched == null) {
      return false;
    }

    // Perbarui data pengguna lokal dan session
    final userIdx = _fallbackUsers.indexWhere((u) => u.idUsers == userId);
    if (userIdx != -1) {
      _fallbackUsers[userIdx] = _fallbackUsers[userIdx].copyWith(
        idHouse: matched.idHouse,
        housing: matched,
      );
    }

    // Pastikan _currentUser selalu diperbarui dengan data perumahan baru
    _currentUser =
        (_currentUser ??
                UserModel(idUsers: userId, nameUsers: 'Warga', role: 'warga'))
            .copyWith(idHouse: matched.idHouse, housing: matched);

    // Simpan relasi ke Supabase User table (berdasarkan id_users atau email)
    if (_client != null) {
      try {
        if (_currentUser?.email != null) {
          await _client!
              .from('User')
              .update({'id_house': matched.idHouse})
              .ilike('email', _currentUser!.email!);
        } else {
          await _client!
              .from('User')
              .update({'id_house': matched.idHouse})
              .eq('id_users', userId);
        }
      } catch (e) {
        debugPrint('Supabase joinHousing fallback: $e');
      }
    }
    return true;
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

    if (_client != null) {
      try {
        final response = await _client!
            .from('User')
            .select('*, Housing(*)')
            .ilike('role', cleanRole);
        final list = (response as List)
            .map((item) => UserModel.fromMap(item))
            .toList();
        return list; // Mengembalikan langsung data murni dari database Supabase
      } catch (e) {
        debugPrint(
          'Supabase getUsersByRole with Housing failed: $e, retrying without join...',
        );
        try {
          final response = await _client!
              .from('User')
              .select('*')
              .ilike('role', cleanRole);
          final list = (response as List)
              .map((item) => UserModel.fromMap(item))
              .toList();
          return list; // Mengembalikan langsung data murni dari database Supabase
        } catch (e2) {
          debugPrint('Supabase getUsersByRole fallback: $e2');
        }
      }
    }

    // Jika offline / client null, gunakan fallback lokal
    return _fallbackUsers
        .where((u) => u.role?.toLowerCase() == cleanRole)
        .toList();
  }

  @override
  Future<UserModel> addPetugas({
    required String name,
    required String phone,
    String? email,
    String? password,
    String? role = 'petugas',
    int? idHouse,
  }) async {
    final cleanPhone =
        num.tryParse(phone.replaceAll(RegExp(r'[^0-9]'), '')) ?? 081234567890;
    final generatedEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim().toLowerCase()
        : '${name.toLowerCase().replaceAll(RegExp(r'\s+'), '.')}@resik.id';
    final userPassword = (password != null && password.trim().isNotEmpty)
        ? password.trim()
        : 'petugas123';
    final hashedPassword = hashPassword(userPassword);

    if (_fallbackUsers.any((u) => u.email?.toLowerCase() == generatedEmail)) {
      throw Exception(
        'Email "$generatedEmail" sudah digunakan oleh pengguna lain.',
      );
    }

    // Ambil perumahan spesifik admin atau idHouse yang dikirim
    HousingModel? targetHousing;
    if (idHouse != null) {
      targetHousing = await getHousingById(idHouse);
    }
    if (targetHousing == null && _currentUser?.housing != null) {
      targetHousing = _currentUser!.housing;
      idHouse = _currentUser!.housing!.idHouse;
    }

    final newPetugas = UserModel(
      nameUsers: name,
      phoneNum: cleanPhone,
      email: generatedEmail,
      role: role ?? 'petugas',
      password: hashedPassword,
      idHouse: idHouse,
      housing: targetHousing,
    );

    if (_client != null) {
      try {
        await _client!.auth.signUp(
          email: generatedEmail,
          password: userPassword,
          data: {'name': name, 'phone': phone, 'role': role ?? 'petugas'},
        );
      } catch (authErr) {
        debugPrint('Supabase Auth signUp for petugas: $authErr');
      }

      try {
        final res = await _client!
            .from('User')
            .insert(newPetugas.toMap())
            .select()
            .single();
        final created = UserModel.fromMap(res);
        _fallbackUsers.removeWhere(
          (u) => u.email?.toLowerCase() == generatedEmail,
        );
        _fallbackUsers.add(created);
        return created;
      } catch (e) {
        debugPrint(
          'Supabase addPetugas with id_house failed: $e. Retrying without id_house...',
        );
        try {
          final mapWithoutHouse = Map<String, dynamic>.from(newPetugas.toMap())
            ..remove('id_house');
          final res = await _client!
              .from('User')
              .insert(mapWithoutHouse)
              .select()
              .single();
          final created = UserModel.fromMap(res);
          _fallbackUsers.removeWhere(
            (u) => u.email?.toLowerCase() == generatedEmail,
          );
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
      updates['phone_num'] = num.tryParse(
        phone.replaceAll(RegExp(r'[^0-9]'), ''),
      );
    }
    if (email != null) updates['email'] = email;
    if (password != null) updates['password'] = hashPassword(password);

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
    if (_client != null) {
      try {
        final response = await _client!
            .from('Pickup_req')
            .select('*, User(*)')
            .order('pickup_date', ascending: false);
        final list = (response as List)
            .map((item) => PickupReqModel.fromMap(item))
            .toList();
        return list;
      } catch (e) {
        debugPrint(
          'Supabase getAllPickupRequests with User join failed: $e. Retrying plain select...',
        );
        try {
          final response = await _client!
              .from('Pickup_req')
              .select('*')
              .order('pickup_date', ascending: false);
          final list = (response as List)
              .map((item) => PickupReqModel.fromMap(item))
              .toList();
          return list;
        } catch (e2) {
          debugPrint('Supabase getAllPickupRequests fallback: $e2');
        }
      }
    }

    return List.from(_fallbackPickupRequests);
  }

  @override
  Future<List<PickupReqModel>> getPickupRequestsByUserId(int userId) async {
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
        return list;
      } catch (e) {
        debugPrint(
          'Supabase getPickupRequestsByUserId with User failed: $e, retrying plain select...',
        );
        try {
          final response = await _client!
              .from('Pickup_req')
              .select('*')
              .eq('id_users', userId)
              .order('pickup_date', ascending: false);
          final list = (response as List)
              .map((item) => PickupReqModel.fromMap(item))
              .toList();
          return list;
        } catch (e2) {
          debugPrint('Supabase getPickupRequestsByUserId fallback: $e2');
        }
      }
    }

    return _fallbackPickupRequests.where((r) => r.idUsers == userId).toList();
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

  /// Mengunggah file foto ke Bucket Supabase Storage 'laporan-sampah'
  /// Mengembalikan URL publik gambar yang bisa diakses langsung via internet
  Future<String?> uploadLaporanPhoto({
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
  }) async {
    if (_client == null) return null;
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
      final cleanFileName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';

      if (!kIsWeb && filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
        final file = File(filePath);
        await _client!.storage
            .from('laporan-sampah')
            .upload(cleanFileName, file, fileOptions: FileOptions(contentType: 'image/$ext', upsert: true));
      } else if (fileBytes != null && fileBytes.isNotEmpty) {
        await _client!.storage
            .from('laporan-sampah')
            .uploadBinary(cleanFileName, fileBytes, fileOptions: FileOptions(contentType: 'image/$ext', upsert: true));
      } else {
        return null;
      }

      final publicUrl = _client!.storage.from('laporan-sampah').getPublicUrl(cleanFileName);
      debugPrint('Foto berhasil diunggah ke Supabase Storage: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Gagal upload foto ke Supabase Storage: $e');
      return null;
    }
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

    final index = _fallbackPickupRequests.indexWhere(
      (p) => p.idPickup == idPickup,
    );
    if (index != -1) {
      _fallbackPickupRequests[index] = _fallbackPickupRequests[index].copyWith(
        status: newStatus,
      );
    }
  }

  @override
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
  Future<Map<String, dynamic>> getPaymentStats({
    String month = 'Oktober',
    int year = 2026,
  }) async {
    final allPayments = await getAllPayments();
    final allWarga = await getUsersByRole('warga');

    final paidForMonth = allPayments
        .where((p) => p.month == month && p.year == year)
        .toList();
    final paidUserIds = paidForMonth.map((p) => p.idUsers).toSet();

    final totalCollected = paidForMonth.fold<int>(
      0,
      (sum, p) => sum + (p.amount ?? 0),
    );
    final lunasCount = paidUserIds.length;
    final belumLunasCount = allWarga
        .where((w) => !paidUserIds.contains(w.idUsers))
        .length;

    return {
      'totalCollected': totalCollected,
      'lunasCount': lunasCount,
      'belumLunasCount': belumLunasCount,
      'targetCount': allWarga.length,
    };
  }

  // ==========================================
  // SCHEDULE SERVICE
  // ==========================================

  Future<List<ScheduleModel>> getAllSchedules() async {
    if (_client != null) {
      try {
        final res = await _client!.from('Schedule').select();
        final list = (res as List)
            .map((i) => ScheduleModel.fromMap(i))
            .toList();
        return list;
      } catch (e) {
        debugPrint('Supabase getAllSchedules fallback: $e');
      }
    }
    return List.from(_fallbackSchedules);
  }

  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    if (_client != null) {
      try {
        final res = await _client!
            .from('Schedule')
            .insert(schedule.toMap())
            .select()
            .single();
        final created = ScheduleModel.fromMap(res);
        _fallbackSchedules.insert(0, created);
        return created;
      } catch (e) {
        debugPrint('Supabase createSchedule fallback: $e');
      }
    }
    final created = schedule.copyWith(
      idSchedule: _fallbackSchedules.length + 1,
    );
    _fallbackSchedules.insert(0, created);
    return created;
  }
}
