class PickupReqModel {
  final int? idPickup;
  final String description;
  final DateTime? pickupDate;
  final String? status; // e.g. 'pending', 'in_progress', 'completed', 'cancelled'
  final String? category;
  final String? photo;

  PickupReqModel({
    this.idPickup,
    required this.description,
    this.pickupDate,
    this.status,
    this.category,
    this.photo,
  });

  factory PickupReqModel.fromMap(Map<String, dynamic> map) {
    return PickupReqModel(
      idPickup: map['id_pickup'] != null ? int.tryParse(map['id_pickup'].toString()) : null,
      description: map['description'] as String? ?? '',
      pickupDate: map['pickup_date'] != null ? DateTime.tryParse(map['pickup_date'].toString()) : null,
      status: map['status'] as String?,
      category: map['category'] as String?,
      photo: map['photo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idPickup != null) 'id_pickup': idPickup,
      'description': description,
      'pickup_date': pickupDate?.toIso8601String(),
      'status': status,
      'category': category,
      'photo': photo,
    };
  }

  PickupReqModel copyWith({
    int? idPickup,
    String? description,
    DateTime? pickupDate,
    String? status,
    String? category,
    String? photo,
  }) {
    return PickupReqModel(
      idPickup: idPickup ?? this.idPickup,
      description: description ?? this.description,
      pickupDate: pickupDate ?? this.pickupDate,
      status: status ?? this.status,
      category: category ?? this.category,
      photo: photo ?? this.photo,
    );
  }
}
