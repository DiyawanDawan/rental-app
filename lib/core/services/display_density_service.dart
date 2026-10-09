import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/spacing.dart';

/// Toggle tampilan padat — skala teks & spacing opsional.
class DisplayDensityService extends ChangeNotifier {
  static const _prefKey = 'compact_display';

  bool _compact = false;
  bool _loaded = false;

  bool get isCompact => _compact;
  bool get isLoaded => _loaded;

  /// Multiplier teks: normal 1.04, compact 0.96.
  double get textScaleFactor => _compact ? 0.96 : 1.04;

  /// Multiplier spacing untuk layout padat.
  double get spacingMultiplier => _compact ? 0.92 : 1.0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _compact = prefs.getBool(_prefKey) ?? false;
    _loaded = true;
    _applySpacing();
    notifyListeners();
  }

  Future<void> setCompact(bool value) async {
    if (_compact == value) return;
    _compact = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    _applySpacing();
    notifyListeners();
  }

  void _applySpacing() => AppSpacing.density = spacingMultiplier;
}
