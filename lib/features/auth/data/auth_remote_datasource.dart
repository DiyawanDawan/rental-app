import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/multipart_upload_helper.dart';
import '../../../core/network/upload_executor.dart';
import '../../../core/utils/image_prepare_util.dart';
import 'models/auth_session_model.dart';
import 'models/user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse<AuthSessionModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    return ApiResponse<AuthSessionModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => AuthSessionModel.fromBackendJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<UserModel>> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authRegisterCustomer,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );

    return ApiResponse<UserModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<UserModel>> registerMitra({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authRegisterMitra,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      },
    );

    return ApiResponse<UserModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthSessionModel>> verifyRegistration({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authVerifyRegistration,
      data: {
        'email': email,
        'code': code,
      },
    );

    return ApiResponse<AuthSessionModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => AuthSessionModel.fromBackendJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<UserModel>> getMe() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.authMe);

    return ApiResponse<UserModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthSessionModel>> refreshToken(String token) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authRefreshToken,
      data: {'token': token},
    );

    return ApiResponse<AuthSessionModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => AuthSessionModel.fromBackendJson(json as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _apiClient.post<Map<String, dynamic>>(ApiEndpoints.authLogout);
  }

  Future<ApiResponse<void>> resendOtp({
    required String email,
    String type = 'REGISTRATION',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authResendOtp,
      data: {
        'email': email,
        'type': type,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authForgotPassword,
      data: {'email': email},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<String>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authVerifyResetCode,
      data: {
        'email': email,
        'code': code,
      },
    );

    return ApiResponse<String>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as Map<String, dynamic>)['resetToken']?.toString() ?? '',
    );
  }

  Future<ApiResponse<void>> resetPasswordWithToken({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authResetPasswordWithToken(resetToken),
      data: {
        'password': newPassword,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<UserModel>> updateProfile(
    Map<String, dynamic> data, {
    String? avatarPath,
  }) async {
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final prepared = await ImagePrepareUtil.prepareForUpload(avatarPath);
      final formData = await MultipartUploadHelper.buildProfileForm(
        data,
        avatarPath: prepared,
      );
      await UploadExecutor(_apiClient).uploadMultipart(
        endpoint: ApiEndpoints.authProfile,
        formData: formData,
        usePatch: true,
      );
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.authMe);
      return ApiResponse<UserModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    }

    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.authProfile,
      data: data,
    );

    return ApiResponse<UserModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> resetPassword({
    required String newPassword,
    String? currentPassword,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authResetPassword,
      data: {
        'newPassword': newPassword,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'currentPassword': currentPassword,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<AuthSessionModel>> loginWithFacebook(String accessToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authFacebook,
      data: {'token': accessToken},
    );

    return ApiResponse<AuthSessionModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => AuthSessionModel.fromBackendJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthSessionModel>> loginWithGoogle(String idToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authGoogle,
      data: {'token': idToken},
    );

    return ApiResponse<AuthSessionModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => AuthSessionModel.fromBackendJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> submitVerification({
    required String ktpPath,
    required String simPath,
    required String selfiePath,
    required String ktpNumber,
    String? simNumber,
    UploadProgressCallback? onDocProgress,
  }) async {
    final formData = await MultipartUploadHelper.buildNamedDocForm(
      {
        'ktp': ktpPath,
        'sim': simPath,
        'selfie': selfiePath,
      },
      extraFields: {
        'ktpNumber': ktpNumber,
        if (simNumber != null && simNumber.isNotEmpty) 'simNumber': simNumber,
      },
    );

    await UploadExecutor(_apiClient).uploadMultipart(
      endpoint: ApiEndpoints.authVerification,
      formData: formData,
      onProgress: onDocProgress,
    );

    return ApiResponse<void>.fromJson(<String, dynamic>{}, (_) {});
  }

  Future<ApiResponse<void>> requestPhoneUpdate(String phoneNumber) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authRequestPhoneUpdate,
      data: {'phoneNumber': phoneNumber},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> verifyPhoneUpdate({
    required String phoneNumber,
    required String code,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authVerifyPhoneUpdate,
      data: {
        'phoneNumber': phoneNumber,
        'code': code,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }
}
