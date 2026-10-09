class AddressModel {
  const AddressModel({
    required this.id,
    required this.userId,
    required this.fullAddress,
    this.zipCode,
    required this.countryId,
    this.countryName,
    this.provinceId,
    this.provinceName,
    this.regencyId,
    this.regencyName,
    this.districtId,
    this.districtName,
    this.villageId,
    this.villageName,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.isPrimary = false,
  });

  final String id;
  final String userId;
  final String fullAddress;
  final String? zipCode;
  final String countryId;
  final String? countryName;
  final String? provinceId;
  final String? provinceName;
  final String? regencyId;
  final String? regencyName;
  final String? districtId;
  final String? districtName;
  final String? villageId;
  final String? villageName;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPrimary;

  // Legacy compatibility getters
  String get address => fullAddress;
  String get name => regencyName ?? districtName ?? countryName ?? 'Alamat Tersimpan';
  String? get city => regencyName;
  String? get province => provinceName;

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Returns a clean formatted regional hierarchy string
  /// Example: "Menteng, Jakarta Pusat, DKI Jakarta, Indonesia"
  String get formattedHierarchy {
    final parts = [
      villageName,
      districtName,
      regencyName,
      provinceName,
      countryName,
    ].where((e) => e != null && e.trim().isNotEmpty).toList();

    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? json['address']?.toString() ?? '',
      zipCode: json['zipCode']?.toString(),
      countryId: json['countryId']?.toString() ?? '',
      countryName: json['countryName']?.toString(),
      provinceId: json['provinceId']?.toString(),
      provinceName: json['provinceName']?.toString() ?? json['province']?.toString(),
      regencyId: json['regencyId']?.toString(),
      regencyName: json['regencyName']?.toString() ?? json['city']?.toString(),
      districtId: json['districtId']?.toString(),
      districtName: json['districtName']?.toString(),
      villageId: json['villageId']?.toString(),
      villageName: json['villageName']?.toString(),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      isPrimary: json['isPrimary'] == true || json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullAddress': fullAddress,
      if (zipCode != null) 'zipCode': zipCode,
      'countryId': countryId,
      if (countryName != null) 'countryName': countryName,
      if (provinceId != null) 'provinceId': provinceId,
      if (provinceName != null) 'provinceName': provinceName,
      if (regencyId != null) 'regencyId': regencyId,
      if (regencyName != null) 'regencyName': regencyName,
      if (districtId != null) 'districtId': districtId,
      if (districtName != null) 'districtName': districtName,
      if (villageId != null) 'villageId': villageId,
      if (villageName != null) 'villageName': villageName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isPrimary': isPrimary,
    };
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
