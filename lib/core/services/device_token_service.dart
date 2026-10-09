import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/di.dart';
import '../../features/customer/data/customer_repository.dart';

/// Registers FCM device token with backend for push notifications.
class DeviceTokenService {
  const DeviceTokenService();

  static const _tokenKey = 'device_push_token';

  Future<void> registerIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_tokenKey);
    if (stored != null && stored.isNotEmpty && !stored.startsWith('device-')) {
      await registerToken(stored);
    }
  }

  Future<void> registerToken(String token) async {
    if (token.isEmpty || token.startsWith('device-')) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final previous = prefs.getString(_tokenKey);
      if (previous == token) return;

      await prefs.setString(_tokenKey, token);
      final platform = _resolvePlatform();
      await getIt<CustomerRepository>().registerDeviceToken(token, platform);
    } catch (e) {
      debugPrint('DeviceTokenService: register failed — $e');
    }
  }

  Future<void> unregisterToken(String token) async {
    try {
      await getIt<CustomerRepository>().unregisterDeviceToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('DeviceTokenService: unregister failed — $e');
    }
  }

  String _resolvePlatform() {
    if (kIsWeb) return 'WEB';
    if (Platform.isIOS) return 'IOS';
    return 'ANDROID';
  }
}
