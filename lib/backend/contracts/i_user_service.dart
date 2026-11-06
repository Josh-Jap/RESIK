import '../models/user_model.dart';

/// Contract for User & Petugas operations
abstract class IUserService {
  Future<UserModel?> getUserById(int idUsers);
  Future<List<UserModel>> getUsersByRole(String role);
  Future<UserModel> addPetugas({
    required String name,
    required String phone,
    String? email,
    String? password,
    String? role,
    int? idHouse,
  });
  Future<void> updateUserProfile(
    int idUsers, {
    String? name,
    String? phone,
    String? email,
    String? password,
  });
}
