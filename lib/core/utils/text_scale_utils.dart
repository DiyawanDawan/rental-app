import 'package:flutter/material.dart';

/// Batasi skala teks sistem agar layout tidak pecah di aksesibilitas ekstrem.
///
/// **QA:** Uji di Settings → Display → Font size = Largest (Android)
/// atau Dynamic Type XL (iOS). Tanpa clamp, `Row` dengan harga panjang sering overflow.
class ClampedTextScaler extends TextScaler {
  const ClampedTextScaler(
    this.parent, {
    this.minScaleFactor = 1.0,
    this.maxScaleFactor = 1.35,
  });

  final TextScaler parent;
  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor {
    return parent.textScaleFactor.clamp(minScaleFactor, maxScaleFactor);
  }

  @override
  double scale(double fontSize) {
    if (fontSize <= 0) return fontSize;
    final factor = parent.scale(fontSize) / fontSize;
    return fontSize * factor.clamp(minScaleFactor, maxScaleFactor);
  }
}

extension TextScaleContext on BuildContext {
  /// Faktor skala teks efektif setelah clamp (untuk keputusan layout dinamis).
  double get effectiveTextScale {
    final mq = MediaQuery.of(this);
    final fontSize = 14.0;
    return mq.textScaler.scale(fontSize) / fontSize;
  }

  /// `true` saat user memakai font besar — kurangi maxLines atau ubah layout.
  bool get isLargeAccessibilityText => effectiveTextScale >= 1.2;
}
