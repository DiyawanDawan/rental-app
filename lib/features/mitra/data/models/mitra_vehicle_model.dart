import 'package:freezed_annotation/freezed_annotation.dart';

part 'mitra_vehicle_model.freezed.dart';
part 'mitra_vehicle_model.g.dart';

@freezed
abstract class MitraVehicleModel with _$MitraVehicleModel {
  const factory MitraVehicleModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String type,
    @Default('') String brand,
    @Default('') String model,
    @Default('') String licensePlate,
    @Default('') String color,
    @Default(0.0) double pricePerDay,
    @Default('') String status,
    String? rentalType,
    @Default(false) bool isInstantBooking,
    String? primaryPhotoUrl,
    @Default([]) List<Map<String, dynamic>> amenities,
    int? year,
    String? transmission,
    int? seatingCapacity,
    String? description,
    @Default([]) List<String> photos,
    double? priceWithDriver,
    double? priceFullPackage,
    double? depositAmount,
    List<String>? blockedDates,
  }) = _MitraVehicleModel;

  factory MitraVehicleModel.fromJson(Map<String, dynamic> json) =>
      _$MitraVehicleModelFromJson(json);
}
