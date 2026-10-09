import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> setUserRole(String role) async {
    try {
      await _analytics.setUserProperty(name: 'role', value: role);
    } catch (e) {
      debugPrint('Analytics setUserRole: $e');
    }
  }

  Future<void> logSearchVehicle({String? query}) async {
    await _safeLog('search_vehicle', {'query': query ?? ''});
  }

  Future<void> logViewVehicle(String vehicleId) async {
    await _safeLog('view_vehicle', {'vehicle_id': vehicleId});
  }

  Future<void> logStartBooking(String vehicleId) async {
    await _safeLog('start_booking', {'vehicle_id': vehicleId});
  }

  Future<void> logPaymentInitiated(String bookingId) async {
    await _safeLog('payment_initiated', {'booking_id': bookingId});
  }

  Future<void> logPaymentSuccess(String bookingId) async {
    await _safeLog('payment_success', {'booking_id': bookingId});
  }

  Future<void> _safeLog(String name, Map<String, Object> params) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics $name: $e');
    }
  }
}
