import 'user_model.dart';

class PickupReqModel {
  final int? idPickup;
  final String description;
  final int idUsers;
  final DateTime? pickupDate;
  final String? status; // 'pending' (Baru), 'in_progress' (Diproses), 'completed' (Selesai), 'cancelled'
  final String? category;
  final String? photo;
  final UserModel? user;

  PickupReqModel({
    this.idPickup,
    required this.description,
    required this.idUsers,
    this.pickupDate,
    this.status = 'pending',
    this.category,
    this.photo,
    this.user,
  });

  factory PickupReqModel.fromMap(Map<String, dynamic> map) {
    return PickupReqModel(
      idPickup: map['id_pickup'] != null ? int.tryParse(map['id_pickup'].toString()) : null,
      description: map['description'] as String? ?? '',
      idUsers: int.tryParse(map['id_users']?.toString() ?? '0') ?? 0,
      pickupDate: map['pickup_date'] != null ? DateTime.tryParse(map['pickup_date'].toString()) : null,
      status: map['status'] as String? ?? 'pending',
      category: map['category'] as String?,
      photo: map['photo'] as String?,
      user: map['User'] != null && map['User'] is Map<String, dynamic>
          ? UserModel.fromMap(map['User'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idPickup != null) 'id_pickup': idPickup,
      'description': description,
      'id_users': idUsers,
      'pickup_date': (pickupDate ?? DateTime.now()).toIso8601String(),
      'status': status ?? 'pending',
      'category': category,
      'photo': photo,
    };
  }

  /// Alias untuk kompatibilitas UI
  String? get tipePickup => category;
  String? get lokasi => description;
  String? get tanggalPickup => pickupDate != null
      ? '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}'
      : null;

  /// UI Status label matching the mockup: 'Baru', 'Diproses', 'Selesai'
  String get statusLabel {
    switch ((status ?? '').toLowerCase()) {
      case 'in_progress':
      case 'diproses':
        return 'Diproses';
      case 'completed':
      case 'selesai':
        return 'Selesai';
      case 'cancelled':
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'pending':
      case 'baru':
      default:
        return 'Baru';
    }
  }

  PickupReqModel copyWith({
    int? idPickup,
    String? description,
    int? idUsers,
    DateTime? pickupDate,
    String? status,
    String? category,
    String? photo,
    UserModel? user,
  }) {
    return PickupReqModel(
      idPickup: idPickup ?? this.idPickup,
      description: description ?? this.description,
      idUsers: idUsers ?? this.idUsers,
      pickupDate: pickupDate ?? this.pickupDate,
      status: status ?? this.status,
      category: category ?? this.category,
      photo: photo ?? this.photo,
      user: user ?? this.user,
    );
  }
}
