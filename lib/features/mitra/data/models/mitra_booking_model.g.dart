// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mitra_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MitraBookingModel _$MitraBookingModelFromJson(Map<String, dynamic> json) =>
    _MitraBookingModel(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      vehicleName: json['vehicleName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MitraBookingModelToJson(_MitraBookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'vehicleName': instance.vehicleName,
      'customerEmail': instance.customerEmail,
      'customerName': instance.customerName,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'status': instance.status,
      'totalPrice': instance.totalPrice,
      'notes': instance.notes,
    };
