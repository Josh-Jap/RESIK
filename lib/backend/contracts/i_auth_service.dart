import '../models/user_model.dart';

/// Contract for Authentication and Session Management (Single Responsibility & Interface Segregation)
abstract class IAuthService {
  UserModel? get currentUser;
  void setCurrentUser(UserModel? user);

  Future<UserModel?> login({
    required String email,
    required String password,
    String? role,
  });

  Future<UserModel> registerWarga({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<UserModel> registerAdmin({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<void> logout();
}
