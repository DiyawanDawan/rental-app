import 'package:freezed_annotation/freezed_annotation.dart';

part 'mitra_profile_model.freezed.dart';
part 'mitra_profile_model.g.dart';

@freezed
abstract class MitraProfileModel with _$MitraProfileModel {
  const factory MitraProfileModel({
    @Default('') String id,
    @Default('') String email,
    @Default('') String storeName,
    @Default('') String phoneNumber,
    @Default(false) bool isVerified,
    String? bannerUrl,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
  }) = _MitraProfileModel;

  factory MitraProfileModel.fromJson(Map<String, dynamic> json) =>
      _$MitraProfileModelFromJson(json);
}
