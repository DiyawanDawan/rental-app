import 'package:freezed_annotation/freezed_annotation.dart';

part 'mitra_stats_model.freezed.dart';
part 'mitra_stats_model.g.dart';

@freezed
abstract class MitraStatsModel with _$MitraStatsModel {
  const factory MitraStatsModel({
    @Default(0) int totalVehicles,
    @Default(0) int totalBookings,
    @Default(0.0) double revenue,
    @Default(0.0) double ratingAverage,
  }) = _MitraStatsModel;

  factory MitraStatsModel.fromJson(Map<String, dynamic> json) =>
      _$MitraStatsModelFromJson(json);
}
