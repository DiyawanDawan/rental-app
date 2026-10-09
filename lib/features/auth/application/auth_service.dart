import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/di.dart';
import '../../../core/cache/reference_data_cache.dart';
import '../../../core/utils/error_message_util.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/device_token_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../customer/application/customer_service.dart';
import '../../mitra/application/mitra_service.dart';
import '../data/auth_repository.dart';
import '../data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  awaitingVerification,
  failure,
}

class AuthService extends ChangeNotifier {
  AuthService(this._authRepository);

  final AuthRepository _authRepository;
  final _localAuth = LocalAuthentication();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _message;
  String? _pendingEmail;
  bool _isBiometricEnabled = false;
  int _uploadDocCurrent = 0;
  int _uploadDocTotal = 0;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get message => _message;
  String? get pendingEmail => _pendingEmail;
  bool get isLoading => _status == AuthStatus.loading;
  double? get uploadDocProgress =>
      _uploadDocTotal > 0 ? _uploadDocCurrent / _uploadDocTotal : null;
  String? get uploadDocProgressLabel => _uploadDocTotal > 0
      ? 'Mengunggah dokumen $_uploadDocCurrent dari $_uploadDocTotal'
      : null;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isKycVerified =>
      _user?.isVerified == true || _user?.verificationStatus == 'VERIFIED';
  bool get isKycPending => _user?.verificationStatus == 'PENDING';
  bool get isKycRejected => _user?.verificationStatus == 'REJECTED';
  String? get kycRejectionReason => _user?.rejectionReason;

  Future<void> initBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      if (enabled) {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isSupported = await _localAuth.isDeviceSupported();
        if (!canCheck || !isSupported) return false;

        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Konfirmasi sidik jari/wajah untuk mengaktifkan login biometrik',
        );
        if (!authenticated) return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', enabled);
      _isBiometricEnabled = enabled;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Masuk ke Travelindo',
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.login(email: email, password: password);
      _user = response.data?.user;
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      await _postAuthSetup();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> loginWithFacebook(String accessToken) async {
    _setLoading();
    try {
      final response = await _authRepository.loginWithFacebook(accessToken);
      _user = response.data?.user;
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      await _postAuthSetup();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    _setLoading();
    try {
      final response = await _authRepository.loginWithGoogle(idToken);
      _user = response.data?.user;
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      await _postAuthSetup();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase first if needed (optional depending on backend strategy)
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (googleAuth.idToken != null) {
        return await loginWithGoogle(googleAuth.idToken!);
      }
      
      _setFailure('Gagal mendapatkan ID Token dari Google');
      return false;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.registerCustomer(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _pendingEmail = email;
      _user = response.data;
      _message = response.message;
      _status = AuthStatus.awaitingVerification;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> registerMitra({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.registerMitra(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _pendingEmail = email;
      _user = response.data;
      _message = response.message;
      _status = AuthStatus.awaitingVerification;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> verifyRegistration({
    required String email,
    required String code,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.verifyRegistration(email: email, code: code);
      _user = response.data?.user;
      _pendingEmail = null;
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      await _postAuthSetup();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> _postAuthSetup() async {
    await const DeviceTokenService().registerIfNeeded();
    final user = _user;
    if (user == null) return;

    final role = user.role.toLowerCase();
    await AnalyticsService.instance.setUserRole(role);

    if (user.role == 'CUSTOMER' && getIt.isRegistered<CustomerService>()) {
      await getIt<CustomerService>().initCustomerRealtime(user.id);
      await getIt<CustomerService>().loadMyBookings();
    }
  }

  Future<void> restoreSessionIfNeeded() async {
    final hasToken = await _authRepository.hasStoredSession();
    if (!hasToken) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    if (_isBiometricEnabled) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      await refreshSession();
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> restoreSessionWithBiometrics() async {
    final hasToken = await _authRepository.hasStoredSession();
    if (!hasToken) return false;

    final authenticated = await authenticateWithBiometrics();
    if (!authenticated) return false;

    return refreshSession();
  }

  Future<bool> refreshSession() async {
    _setLoading();
    try {
      final response = await _authRepository.refreshToken();
      if (response.data?.user != null) {
        _user = response.data!.user;
      } else if (_user == null) {
        final profileRes = await _authRepository.getMe();
        _user = profileRes.data;
      }
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      await _postAuthSetup();
      return true;
    } catch (error) {
      _setFailure(error);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    _setLoading();
    try {
      final response = await _authRepository.getMe();
      _user = response.data;
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> logout() async {
    _setLoading();
    try {
      await PushNotificationService.instance.unregister();
      if (getIt.isRegistered<CustomerService>()) {
        await getIt<CustomerService>().teardownCustomerRealtime();
      }
      await _authRepository.logout();
      if (getIt.isRegistered<ReferenceDataCache>()) {
        getIt<ReferenceDataCache>().clearAll();
      }
      if (getIt.isRegistered<CustomerService>()) {
        await getIt<CustomerService>().clearSearchHistory();
      }
      if (getIt.isRegistered<MitraService>()) {
        getIt<MitraService>().clearSessionData();
      }
      _user = null;
      _message = 'Logout berhasil';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> resendOtp(String email, {String type = 'REGISTRATION'}) async {
    _setLoading();
    try {
      final response = await _authRepository.resendOtp(email, type: type);
      _message = response.message;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading();
    try {
      final response = await _authRepository.forgotPassword(email);
      _message = response.message;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> resetPasswordWithToken({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.resetPasswordWithToken(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      _message = response.message;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data, {String? avatarPath}) async {
    _setLoading();
    try {
      final response = await _authRepository.updateProfile(data, avatarPath: avatarPath);
      _user = response.data;
      _message = response.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> submitVerification({
    required String ktpPath,
    required String simPath,
    required String selfiePath,
    required String ktpNumber,
    String? simNumber,
  }) async {
    _setLoading();
    _uploadDocCurrent = 0;
    _uploadDocTotal = 1;
    notifyListeners();
    try {
      final response = await _authRepository.submitVerification(
        ktpPath: ktpPath,
        simPath: simPath,
        selfiePath: selfiePath,
        ktpNumber: ktpNumber,
        simNumber: simNumber,
        onDocProgress: (current, total) {
          _uploadDocCurrent = current;
          _uploadDocTotal = total;
          notifyListeners();
        },
      );
      _message = response.message;
      _status = AuthStatus.authenticated;
      await loadProfile(); // Reload to get updated verification status
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    } finally {
      _uploadDocCurrent = 0;
      _uploadDocTotal = 0;
      notifyListeners();
    }
  }

  Future<bool> requestPhoneUpdate(String phoneNumber) async {
    _setLoading();
    try {
      final response = await _authRepository.requestPhoneUpdate(phoneNumber);
      _message = response.message;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> verifyPhoneUpdate({
    required String phoneNumber,
    required String code,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.verifyPhoneUpdate(
        phoneNumber: phoneNumber,
        code: code,
      );
      _message = response.message;
      await loadProfile();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String newPassword,
    String? currentPassword,
  }) async {
    _setLoading();
    try {
      final response = await _authRepository.resetPassword(
        newPassword: newPassword,
        currentPassword: currentPassword,
      );
      _message = response.message;
      notifyListeners();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _message = null;
    notifyListeners();
  }

  void _setFailure(Object error) {
    _message = userFacingError(error);
    _status = AuthStatus.failure;
    notifyListeners();
  }
}
