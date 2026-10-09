import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    @Default('') String id,
    @Default('') String email,
    @Default('') String role,
    String? fullName,
    String? phoneNumber,
    String? status,
    String? avatarUrl,
    bool? isVerified,
    String? verificationStatus,
    String? rejectionReason,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
