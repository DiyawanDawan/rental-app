class RegionItemModel {
  const RegionItemModel({
    required this.id,
    required this.name,
    this.code,
    this.continent,
    this.countryId,
    this.provinceId,
    this.regencyId,
    this.districtId,
    this.type,
  });

  final String id;
  final String name;
  final String? code;
  final String? continent;
  final String? countryId;
  final String? provinceId;
  final String? regencyId;
  final String? districtId;
  final String? type;

  factory RegionItemModel.fromJson(Map<String, dynamic> json) {
    return RegionItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      continent: json['continent']?.toString(),
      countryId: json['countryId']?.toString(),
      provinceId: json['provinceId']?.toString(),
      regencyId: json['regencyId']?.toString(),
      districtId: json['districtId']?.toString(),
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
      if (continent != null) 'continent': continent,
      if (countryId != null) 'countryId': countryId,
      if (provinceId != null) 'provinceId': provinceId,
      if (regencyId != null) 'regencyId': regencyId,
      if (districtId != null) 'districtId': districtId,
      if (type != null) 'type': type,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionItemModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
