import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../app/router.dart';
import '../../config/routes.dart';
import 'device_token_service.dart';

/// FCM push via awesome_notifications_fcm.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String channelKey = 'travelindo_default';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Travelindo',
          channelDescription: 'Notifikasi pemesanan dan pembayaran',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF1565C0),
        ),
      ],
      debug: kDebugMode,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
    );

    try {
      await AwesomeNotificationsFcm().initialize(
        onFcmTokenHandle: _onFcmToken,
        onFcmSilentDataHandle: _onSilentData,
        onNativeTokenHandle: _onNativeToken,
        debug: kDebugMode,
      );
      await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (e) {
      debugPrint('PushNotificationService FCM init skipped: $e');
    }

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static Future<void> _onFcmToken(String token) async {
    await const DeviceTokenService().registerToken(token);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNativeToken(String token) async {
    await const DeviceTokenService().registerToken(token);
  }

  @pragma('vm:entry-point')
  static Future<void> _onSilentData(FcmSilentData silentData) async {
    debugPrint('FCM silent: ${silentData.createdLifeCycle}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    final payload = action.payload ?? {};
    final type = payload['type']?.toString() ?? '';
    final subType = payload['subType']?.toString() ?? '';
    final bookingId = payload['bookingId']?.toString();
    final vehicleId = payload['vehicleId']?.toString();
    final mitraId = payload['mitraId']?.toString();
    final packageId = payload['packageId']?.toString();
    try {
      final router = AppRouter.instance;
      if (bookingId != null && bookingId.isNotEmpty) {
        router.go('/bookings/$bookingId');
        return;
      }
      if (vehicleId != null && vehicleId.isNotEmpty) {
        router.go(AppRoutePaths.vehicleDetail(vehicleId));
        return;
      }
      if (packageId != null && packageId.isNotEmpty) {
        router.go('/tours/$packageId');
        return;
      }
      if (mitraId != null && mitraId.isNotEmpty) {
        router.go(AppRoutePaths.mitraPublicProfile(mitraId));
        return;
      }
      if (type == 'PROMO' || subType == 'PRICE_DROP' || subType == 'NEW_VEHICLE' || subType == 'NEW_TOUR') {
        router.go('/notifications');
        return;
      }
      if (type == 'PAYMENT' || type == 'REFUND') {
        router.go('/wallet');
      } else if (type == 'BOOKING') {
        router.go('/bookings');
      }
    } catch (e) {
      debugPrint('Notification navigation failed: $e');
    }
  }

  Future<void> unregister() async {
    try {
      final token = await AwesomeNotificationsFcm().requestFirebaseAppToken();
      if (token != null && token.isNotEmpty) {
        await const DeviceTokenService().unregisterToken(token);
      }
    } catch (_) {}
  }
}
