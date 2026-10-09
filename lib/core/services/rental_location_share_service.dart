import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

import '../../features/customer/data/customer_repository.dart';

/// Shares customer phone GPS with mitra while rental booking(s) are HANDOVER.
/// Uses foreground service on Android and background updates on iOS when permitted.
class RentalLocationShareService {
  RentalLocationShareService(this._repository);

  final CustomerRepository _repository;
  StreamSubscription<Position>? _positionSub;
  Timer? _fallbackTimer;
  String? _activeBookingId;
  String? _lastError;

  String? get activeBookingId => _activeBookingId;
  String? get lastError => _lastError;

  void syncHandoverBookings(List<({String id, String status, bool isShuttle})> bookings) {
    final handover = bookings.where((b) => !b.isShuttle && b.status == 'HANDOVER').toList();
    if (handover.isEmpty) {
      stopSharing();
      return;
    }
    startSharing(handover.first.id);
  }

  void startSharing(String bookingId) {
    if (_activeBookingId == bookingId && _positionSub != null) return;
    stopSharing();
    _activeBookingId = bookingId;
    unawaited(_sendOnce());
    _startTracking();
  }

  void stopSharing() {
    _positionSub?.cancel();
    _positionSub = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    _activeBookingId = null;
    _lastError = null;
  }

  void _startTracking() {
    if (kIsWeb) {
      _fallbackTimer = Timer.periodic(const Duration(minutes: 3), (_) => _sendOnce());
      return;
    }

    _positionSub = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
      (_) => _sendOnce(),
      onError: (Object error) {
        _lastError = error.toString();
      },
    );

    _fallbackTimer = Timer.periodic(const Duration(minutes: 3), (_) => _sendOnce());
  }

  LocationSettings get _locationSettings {
    if (!kIsWeb && Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
        intervalDuration: const Duration(minutes: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Lokasi sewa aktif',
          notificationText: 'Travelindo membagikan lokasi untuk keamanan unit yang sedang disewa',
          enableWakeLock: true,
        ),
      );
    }
    if (!kIsWeb && Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.medium,
        activityType: ActivityType.automotiveNavigation,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
        distanceFilter: 50,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 50,
    );
  }

  Future<void> _sendOnce() async {
    final bookingId = _activeBookingId;
    if (bookingId == null) return;

    final position = await _getFreshPosition();
    if (position == null) {
      _lastError = 'Izin lokasi diperlukan untuk keamanan sewa';
      return;
    }

    try {
      await _repository.submitBookingLocation(
        bookingId,
        lat: position.latitude,
        lng: position.longitude,
        accuracyM: position.accuracy,
        heading: position.heading,
        speedKmh: position.speed > 0 ? position.speed * 3.6 : null,
      );
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    }
  }

  Future<Position?> _getFreshPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    if (!kIsWeb && Platform.isIOS && permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );
  }
}
