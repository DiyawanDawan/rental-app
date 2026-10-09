import 'package:freezed_annotation/freezed_annotation.dart';

part 'mitra_booking_model.freezed.dart';
part 'mitra_booking_model.g.dart';

@freezed
abstract class MitraBookingModel with _$MitraBookingModel {
  const factory MitraBookingModel({
    @Default('') String id,
    @Default('') String vehicleId,
    @Default('') String vehicleName,
    @Default('') String customerEmail,
    @Default('') String customerName,
    @Default('') String startDate,
    @Default('') String endDate,
    @Default('') String status,
    @Default(0.0) double totalPrice,
    String? notes,
  }) = _MitraBookingModel;

  factory MitraBookingModel.fromJson(Map<String, dynamic> json) =>
      _$MitraBookingModelFromJson(json);
}
