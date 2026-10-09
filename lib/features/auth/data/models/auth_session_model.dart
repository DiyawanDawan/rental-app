import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'auth_session_model.freezed.dart';
part 'auth_session_model.g.dart';

@freezed
abstract class AuthSessionModel with _$AuthSessionModel {
  const AuthSessionModel._();

  const factory AuthSessionModel({
    @Default('') String token,
    String? refreshToken,
    UserModel? user,
  }) = _AuthSessionModel;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  factory AuthSessionModel.fromBackendJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final parsedUser = userJson is Map<String, dynamic>
        ? UserModel.fromJson(userJson)
        : _tryParseFlatUser(json);

    return AuthSessionModel(
      token: json['token']?.toString() ?? json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
      user: parsedUser,
    );
  }

  static UserModel? _tryParseFlatUser(Map<String, dynamic> json) {
    if (json['id'] == null && json['email'] == null) {
      return null;
    }
    return UserModel.fromJson(json);
  }
}
