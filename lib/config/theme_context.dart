import 'package:flutter/material.dart';

import 'color.dart';
import 'text_styles.dart';

/// Akses warna & tipografi yang mengikuti [ThemeData] aktif.
extension ThemeContextX on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get cs => appTheme.colorScheme;
  bool get isDarkTheme => appTheme.brightness == Brightness.dark;

  TextStyle _onSurface(TextStyle base) => base.copyWith(color: cs.onSurface);

  TextStyle _onSurfaceVariant(TextStyle base) => base.copyWith(color: cs.onSurfaceVariant);

  TextStyle _onPrimary(TextStyle base) => base.copyWith(color: cs.primary);

  TextStyle get textHeadlineLarge => _onSurface(AppTextStyles.headlineLarge);

  TextStyle get textHeadlineMedium => _onSurface(AppTextStyles.headlineMedium);

  TextStyle get textTitleLarge => _onSurface(AppTextStyles.titleLarge);

  TextStyle get textTitleMedium => _onSurface(AppTextStyles.titleMedium);

  TextStyle get textTitleSmall => _onSurface(AppTextStyles.titleSmall);

  TextStyle get textBodyLarge => _onSurfaceVariant(AppTextStyles.bodyLarge);

  TextStyle get textBodyMedium => _onSurfaceVariant(AppTextStyles.bodyMedium);

  TextStyle get textBodySmall => _onSurfaceVariant(AppTextStyles.bodySmall);

  /// Label pendek di atas background scaffold (kontras lebih kuat di dark mode).
  TextStyle get textCaption => AppTextStyles.bodySmall.copyWith(color: cs.onSurface);

  TextStyle get textLabelLarge => _onPrimary(AppTextStyles.labelLarge);

  TextStyle get textLabelSmall => _onSurfaceVariant(AppTextStyles.labelSmall);

  TextStyle get textTertiary => _onSurfaceVariant(AppTextStyles.tertiary);

  TextStyle get textCardPrice => AppTextStyles.cardPrice.copyWith(color: cs.tertiary);

  TextStyle get textCardMeta => _onSurfaceVariant(AppTextStyles.cardMeta);

  /// Aksen hijau alam (destinasi) — token brand, selaras [AppColors.sageGreen].
  Color get accentNature => AppColors.sageGreen;
}
