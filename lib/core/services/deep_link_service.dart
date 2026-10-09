import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';

/// Handles cold-start and runtime deep links.
class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();

  static const _mitraReserved = {
    'vehicles',
    'bookings',
    'profile',
    'earnings',
    'operating-hours',
    'reviews',
    'travel-schedules',
    'tour-packages',
  };

  Future<void> initialize() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _navigate(initial);

      _appLinks.uriLinkStream.listen(_navigate, onError: (Object e) {
        debugPrint('DeepLink error: $e');
      });
    } catch (e) {
      debugPrint('DeepLink init skipped: $e');
    }
  }

  void _navigate(Uri uri) {
    final path = uri.path;
    final target = uri.query.isNotEmpty ? '$path?${uri.query}' : path;

    if (path.startsWith('/vehicles/')) {
      _router.go(target);
      return;
    }
    if (path.startsWith('/bookings/')) {
      _router.go(target);
      return;
    }
    if (path.startsWith('/mitra-stores/')) {
      _router.go(target);
      return;
    }
    if (path.startsWith('/travel')) {
      _router.go(target);
      return;
    }
    if (path == AppRoutePaths.wallet || path.startsWith('${AppRoutePaths.wallet}/')) {
      _router.go(target);
      return;
    }
    if (path.startsWith(AppRoutePaths.chat)) {
      _router.go(target);
      return;
    }
    if (path.startsWith(AppRoutePaths.blogs)) {
      _router.go(target);
      return;
    }
    if (path.startsWith('/mitra/')) {
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length >= 2) {
        final segment = segments[1];
        if (!_mitraReserved.contains(segment)) {
          _router.go(AppRoutePaths.mitraPublicProfile(segment));
          return;
        }
      }
    }
    if (path.startsWith('/tours/') && path.endsWith('/book')) {
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length >= 2) {
        _router.go(AppRoutePaths.tourDetail(segments[1]));
        return;
      }
    }
    if (path.startsWith('/tours/')) {
      _router.go(target);
    }
  }
}
