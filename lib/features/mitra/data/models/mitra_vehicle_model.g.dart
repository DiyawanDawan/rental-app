// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mitra_vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MitraVehicleModel _$MitraVehicleModelFromJson(Map<String, dynamic> json) =>
    _MitraVehicleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      color: json['color'] as String? ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      rentalType: json['rentalType'] as String?,
      isInstantBooking: json['isInstantBooking'] as bool? ?? false,
      primaryPhotoUrl: json['primaryPhotoUrl'] as String?,
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      year: (json['year'] as num?)?.toInt(),
      transmission: json['transmission'] as String?,
      seatingCapacity: (json['seatingCapacity'] as num?)?.toInt(),
      description: json['description'] as String?,
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      priceWithDriver: (json['priceWithDriver'] as num?)?.toDouble(),
      priceFullPackage: (json['priceFullPackage'] as num?)?.toDouble(),
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      blockedDates: (json['blockedDates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MitraVehicleModelToJson(_MitraVehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'brand': instance.brand,
      'model': instance.model,
      'licensePlate': instance.licensePlate,
      'color': instance.color,
      'pricePerDay': instance.pricePerDay,
      'status': instance.status,
      'rentalType': instance.rentalType,
      'isInstantBooking': instance.isInstantBooking,
      'primaryPhotoUrl': instance.primaryPhotoUrl,
      'amenities': instance.amenities,
      'year': instance.year,
      'transmission': instance.transmission,
      'seatingCapacity': instance.seatingCapacity,
      'description': instance.description,
      'photos': instance.photos,
      'priceWithDriver': instance.priceWithDriver,
      'priceFullPackage': instance.priceFullPackage,
      'depositAmount': instance.depositAmount,
      'blockedDates': instance.blockedDates,
    };
