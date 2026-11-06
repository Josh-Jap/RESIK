import 'housing_model.dart';

class UserModel {
  final int? idUsers;
  final String nameUsers;
  final num? phoneNum;
  final String? email;
  final String? role; // 'admin', 'petugas', 'warga'
  final String? password;
  final int? idHouse;
  final HousingModel? housing;

  UserModel({
    this.idUsers,
    required this.nameUsers,
    this.phoneNum,
    this.email,
    this.role,
    this.password,
    this.idHouse,
    this.housing,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUsers: map['id_users'] != null ? int.tryParse(map['id_users'].toString()) : null,
      nameUsers: map['name_users'] as String? ?? '',
      phoneNum: map['phone_num'] != null ? num.tryParse(map['phone_num'].toString()) : null,
      email: map['email'] as String?,
      role: map['role'] as String?,
      password: map['password'] as String?,
      idHouse: map['id_house'] != null ? int.tryParse(map['id_house'].toString()) : null,
      housing: map['Housing'] != null && map['Housing'] is Map<String, dynamic>
          ? HousingModel.fromMap(map['Housing'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idUsers != null) 'id_users': idUsers,
      'name_users': nameUsers,
      'phone_num': phoneNum,
      'email': email,
      'role': role,
      'password': password,
      'id_house': idHouse,
    };
  }

  /// Alias untuk kompatibilitas UI
  String get namaLengkap => nameUsers;
  String? get noHp => phoneNum?.toString();

  /// Inisial nama untuk avatar (misal: "Budi Santoso" -> "BS")
  String get initials {
    final words = nameUsers.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words[0].isEmpty) return 'U';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Format nomor HP rapi (misal: "081234567890" -> "0812-3456-7890")
  String get displayPhone {
    if (phoneNum == null) return '-';
    String str = phoneNum.toString();
    if (!str.startsWith('0')) str = '0$str';
    if (str.length >= 10) {
      return '${str.substring(0, 4)}-${str.substring(4, 8)}-${str.substring(8)}';
    }
    return str;
  }

  UserModel copyWith({
    int? idUsers,
    String? nameUsers,
    num? phoneNum,
    String? email,
    String? role,
    String? password,
    int? idHouse,
    HousingModel? housing,
  }) {
    return UserModel(
      idUsers: idUsers ?? this.idUsers,
      nameUsers: nameUsers ?? this.nameUsers,
      phoneNum: phoneNum ?? this.phoneNum,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
      idHouse: idHouse ?? this.idHouse,
      housing: housing ?? this.housing,
    );
  }
}
