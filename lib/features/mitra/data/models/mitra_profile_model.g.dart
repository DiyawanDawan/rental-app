// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mitra_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MitraProfileModel _$MitraProfileModelFromJson(Map<String, dynamic> json) =>
    _MitraProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      bannerUrl: json['bannerUrl'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$MitraProfileModelToJson(_MitraProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'storeName': instance.storeName,
      'phoneNumber': instance.phoneNumber,
      'isVerified': instance.isVerified,
      'bannerUrl': instance.bannerUrl,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
    };
