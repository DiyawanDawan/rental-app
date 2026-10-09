// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mitra_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MitraStatsModel _$MitraStatsModelFromJson(Map<String, dynamic> json) =>
    _MitraStatsModel(
      totalVehicles: (json['totalVehicles'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MitraStatsModelToJson(_MitraStatsModel instance) =>
    <String, dynamic>{
      'totalVehicles': instance.totalVehicles,
      'totalBookings': instance.totalBookings,
      'revenue': instance.revenue,
      'ratingAverage': instance.ratingAverage,
    };
