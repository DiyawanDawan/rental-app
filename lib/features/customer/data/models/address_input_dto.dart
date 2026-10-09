class CreateAddressInput {
  const CreateAddressInput({
    required this.countryId,
    required this.fullAddress,
    this.provinceId,
    this.regencyId,
    this.districtId,
    this.villageId,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.isDefault,
  });

  final String countryId;
  final String fullAddress;
  final String? provinceId;
  final String? regencyId;
  final String? districtId;
  final String? villageId;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final bool? isDefault;

  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'fullAddress': fullAddress,
      if (provinceId != null && provinceId!.isNotEmpty) 'provinceId': provinceId,
      if (regencyId != null && regencyId!.isNotEmpty) 'regencyId': regencyId,
      if (districtId != null && districtId!.isNotEmpty) 'districtId': districtId,
      if (villageId != null && villageId!.isNotEmpty) 'villageId': villageId,
      if (zipCode != null && zipCode!.trim().isNotEmpty) 'zipCode': zipCode!.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isDefault != null) 'isDefault': isDefault,
    };
  }
}

class UpdateAddressInput {
  const UpdateAddressInput({
    this.countryId,
    this.provinceId,
    this.regencyId,
    this.districtId,
    this.villageId,
    this.fullAddress,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.isDefault,
  });

  final String? countryId;
  final String? provinceId;
  final String? regencyId;
  final String? districtId;
  final String? villageId;
  final String? fullAddress;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final bool? isDefault;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (countryId != null && countryId!.isNotEmpty) map['countryId'] = countryId;
    if (provinceId != null && provinceId!.isNotEmpty) map['provinceId'] = provinceId;
    if (regencyId != null && regencyId!.isNotEmpty) map['regencyId'] = regencyId;
    if (districtId != null && districtId!.isNotEmpty) map['districtId'] = districtId;
    if (villageId != null && villageId!.isNotEmpty) map['villageId'] = villageId;
    if (fullAddress != null && fullAddress!.isNotEmpty) map['fullAddress'] = fullAddress;
    if (zipCode != null) map['zipCode'] = zipCode;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (isDefault != null) map['isDefault'] = isDefault;
    return map;
  }
}
