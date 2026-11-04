class HousingModel {
  final int? idHouse;
  final String nameHouse;
  final String? address;
  final int? houseCode;
  final int? houseNum;
  final String? block;

  HousingModel({
    this.idHouse,
    required this.nameHouse,
    this.address,
    this.houseCode,
    this.houseNum,
    this.block,
  });

  factory HousingModel.fromMap(Map<String, dynamic> map) {
    return HousingModel(
      idHouse: map['id_house'] != null ? int.tryParse(map['id_house'].toString()) : null,
      nameHouse: map['name_house'] as String? ?? '',
      address: map['address'] as String?,
      houseCode: map['house_code'] != null ? int.tryParse(map['house_code'].toString()) : null,
      houseNum: map['house_num'] != null ? int.tryParse(map['house_num'].toString()) : null,
      block: map['block'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idHouse != null) 'id_house': idHouse,
      'name_house': nameHouse,
      'address': address,
      'house_code': houseCode,
      'house_num': houseNum,
      'block': block,
    };
  }

  HousingModel copyWith({
    int? idHouse,
    String? nameHouse,
    String? address,
    int? houseCode,
    int? houseNum,
    String? block,
  }) {
    return HousingModel(
      idHouse: idHouse ?? this.idHouse,
      nameHouse: nameHouse ?? this.nameHouse,
      address: address ?? this.address,
      houseCode: houseCode ?? this.houseCode,
      houseNum: houseNum ?? this.houseNum,
      block: block ?? this.block,
    );
  }
}
