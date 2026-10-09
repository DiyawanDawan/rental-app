import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  const AppEnv._();

  static Future<void> load() async {
    try {
      await dotenv.load();
    } catch (_) {
      // Keep local defaults available when .env is not bundled yet.
    }
  }

  /// Web/iOS/desktop → localhost; Android emulator → 10.0.2.2 (host machine).
  static String get _defaultApiBaseUrl {
    if (kIsWeb) return 'http://localhost:4000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL', fallback: _defaultApiBaseUrl) ??
      _defaultApiBaseUrl;

  static String get apiVersionPath => dotenv.maybeGet(
        'API_VERSION_PATH',
        fallback: '/api/v1',
      ) ?? '/api/v1';

  static int get apiTimeoutMs {
    final rawValue = dotenv.maybeGet('API_TIMEOUT_MS', fallback: '30000') ?? '30000';
    return int.tryParse(rawValue) ?? 30000;
  }

  /// Longer timeout for file uploads (multipart / chunk).
  static int get uploadTimeoutMs {
    final rawValue = dotenv.maybeGet('UPLOAD_TIMEOUT_MS', fallback: '120000') ?? '120000';
    return int.tryParse(rawValue) ?? 120000;
  }

  static String get apiV1BaseUrl => '$apiBaseUrl$apiVersionPath';

  static String get pusherKey => dotenv.maybeGet('PUSHER_KEY', fallback: '') ?? '';
  static String get pusherCluster => dotenv.maybeGet('PUSHER_CLUSTER', fallback: 'ap1') ?? 'ap1';

  /// Release builds must use HTTPS to prevent MITM.
  static void assertProductionSecurity() {
    if (kReleaseMode && !apiBaseUrl.startsWith('https://')) {
      throw StateError(
        'Production build requires HTTPS API_BASE_URL (got: $apiBaseUrl)',
      );
    }
  }
}
