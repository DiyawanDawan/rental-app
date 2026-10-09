// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String? ?? '',
  email: json['email'] as String? ?? '',
  role: json['role'] as String? ?? '',
  fullName: json['fullName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  status: json['status'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isVerified: json['isVerified'] as bool?,
  verificationStatus: json['verificationStatus'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'status': instance.status,
      'avatarUrl': instance.avatarUrl,
      'isVerified': instance.isVerified,
      'verificationStatus': instance.verificationStatus,
      'rejectionReason': instance.rejectionReason,
    };
