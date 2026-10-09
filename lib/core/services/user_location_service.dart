import 'package:geolocator/geolocator.dart';

/// Resolves the user's current GPS position with permission handling.
class UserLocationService {
  UserLocationService._();
  static final UserLocationService instance = UserLocationService._();

  Position? _cached;

  Position? get lastKnown => _cached;

  Future<Position?> getCurrentPosition() async {
    if (_cached != null) return _cached;

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

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 12),
      ),
    );
    _cached = position;
    return position;
  }

  void clearCache() => _cached = null;
}
