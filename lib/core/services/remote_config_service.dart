import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(const {
        "maintenance_mode": false,
        "maintenance_message": "Travelindo sedang dalam pemeliharaan rutin. Silakan kembali lagi nanti.",
        "min_version": "1.0.0",
        "force_update": false,
      });
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint("Remote Config Error: $e");
    }
  }

  bool get isMaintenanceMode => _remoteConfig.getBool("maintenance_mode");
  String get maintenanceMessage => _remoteConfig.getString("maintenance_message");
  String get minVersion => _remoteConfig.getString("min_version");
  bool get forceUpdate => _remoteConfig.getBool("force_update");
}
