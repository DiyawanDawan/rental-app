import '../../../core/network/api_response.dart';
import '../../../core/network/upload_executor.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_remote_datasource.dart';
import 'models/auth_session_model.dart';
import 'models/user_model.dart';

class AuthRepository {
  const AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  Future<ApiResponse<AuthSessionModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(email: email, password: password);
    await _persistSession(response.data);
    return response;
  }

  Future<ApiResponse<AuthSessionModel>> loginWithGoogle(String idToken) async {
    final response = await _remoteDataSource.loginWithGoogle(idToken);
    await _persistSession(response.data);
    return response;
  }

  Future<ApiResponse<AuthSessionModel>> loginWithFacebook(String accessToken) async {
    final response = await _remoteDataSource.loginWithFacebook(accessToken);
    await _persistSession(response.data);
    return response;
  }

  Future<ApiResponse<String>> verifyResetCode({
    required String email,
    required String code,
  }) =>
      _remoteDataSource.verifyResetCode(email: email, code: code);

  Future<ApiResponse<UserModel>> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) {
    return _remoteDataSource.registerCustomer(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }

  Future<ApiResponse<UserModel>> registerMitra({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) {
    return _remoteDataSource.registerMitra(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }

  Future<ApiResponse<AuthSessionModel>> verifyRegistration({
    required String email,
    required String code,
  }) async {
    final response = await _remoteDataSource.verifyRegistration(email: email, code: code);
    await _persistSession(response.data);
    return response;
  }

  Future<ApiResponse<AuthSessionModel>> refreshToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token tidak tersedia');
    }

    final response = await _remoteDataSource.refreshToken(refreshToken);
    await _persistSession(response.data);
    return response;
  }

  Future<ApiResponse<UserModel>> getMe() => _remoteDataSource.getMe();

  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _tokenStorage.clear();
  }

  Future<ApiResponse<void>> resendOtp(
    String email, {
    String type = 'REGISTRATION',
  }) =>
      _remoteDataSource.resendOtp(email: email, type: type);

  Future<ApiResponse<void>> forgotPassword(String email) => _remoteDataSource.forgotPassword(email);

  Future<ApiResponse<void>> resetPasswordWithToken({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final verifyResponse = await _remoteDataSource.verifyResetCode(
      email: email,
      code: code,
    );
    final resetToken = verifyResponse.data;
    if (resetToken == null || resetToken.isEmpty) {
      throw Exception('Token reset tidak valid');
    }
    return _remoteDataSource.resetPasswordWithToken(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }

  Future<ApiResponse<UserModel>> updateProfile(
    Map<String, dynamic> data, {
    String? avatarPath,
  }) =>
      _remoteDataSource.updateProfile(data, avatarPath: avatarPath);

  Future<ApiResponse<void>> submitVerification({
    required String ktpPath,
    required String simPath,
    required String selfiePath,
    required String ktpNumber,
    String? simNumber,
    UploadProgressCallback? onDocProgress,
  }) =>
      _remoteDataSource.submitVerification(
        ktpPath: ktpPath,
        simPath: simPath,
        selfiePath: selfiePath,
        ktpNumber: ktpNumber,
        simNumber: simNumber,
        onDocProgress: onDocProgress,
      );

  Future<ApiResponse<void>> requestPhoneUpdate(String phoneNumber) =>
      _remoteDataSource.requestPhoneUpdate(phoneNumber);

  Future<ApiResponse<void>> verifyPhoneUpdate({
    required String phoneNumber,
    required String code,
  }) =>
      _remoteDataSource.verifyPhoneUpdate(
        phoneNumber: phoneNumber,
        code: code,
      );

  Future<ApiResponse<void>> resetPassword({
    required String newPassword,
    String? currentPassword,
  }) =>
      _remoteDataSource.resetPassword(
        newPassword: newPassword,
        currentPassword: currentPassword,
      );

  Future<bool> hasStoredSession() => _tokenStorage.hasStoredSession();

  Future<void> _persistSession(AuthSessionModel? session) async {
    if (session == null || session.token.isEmpty) {
      return;
    }

    await _tokenStorage.saveTokens(
      accessToken: session.token,
      refreshToken: session.refreshToken,
    );

    final user = session.user;
    if (user != null && user.id.isNotEmpty && user.role.isNotEmpty) {
      await _tokenStorage.saveUserSession(userId: user.id, role: user.role);
    }
  }
}
