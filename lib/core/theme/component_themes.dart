import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/color.dart';
import '../../config/motion.dart';
import '../../config/shapes.dart';
import '../../config/spacing.dart';
import '../../config/text_styles.dart';

/// Factory ThemeData sub-component — dipanggil dari [AppTheme].
abstract final class AppComponentThemes {
  static ButtonStyle primaryButton({bool fullWidth = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.orange,
      foregroundColor: AppColors.surface,
      disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.4),
      disabledForegroundColor: AppColors.surface.withValues(alpha: 0.8),
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: Size(fullWidth ? double.infinity : 0, AppSpacing.buttonMinHeight),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
      ),
      textStyle: AppTextStyles.buttonPrimary,
      animationDuration: AppMotion.fast,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.surface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.surface.withValues(alpha: 0.06);
        }
        return null;
      }),
    );
  }

  static ButtonStyle secondaryButton({bool fullWidth = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.orange,
      disabledForegroundColor: AppColors.orange.withValues(alpha: 0.4),
      side: BorderSide(color: AppColors.orange, width: 1.5.w),
      minimumSize: Size(fullWidth ? double.infinity : 0, AppSpacing.buttonMinHeight),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
      ),
      textStyle: AppTextStyles.buttonSecondary,
      animationDuration: AppMotion.fast,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.orange.withValues(alpha: 0.1);
        }
        return AppColors.orange.withValues(alpha: 0.04);
      }),
    );
  }

  static ButtonStyle ghostButton() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.navy,
      minimumSize: Size(0, AppSpacing.buttonMinHeight),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      textStyle: AppTextStyles.labelLarge,
      animationDuration: AppMotion.fast,
    );
  }

  static ButtonStyle iconButtonFilled() {
    return IconButton.styleFrom(
      backgroundColor: AppColors.lightGray,
      foregroundColor: AppColors.navy,
      highlightColor: AppColors.orange.withValues(alpha: 0.12),
      minimumSize: Size(AppSpacing.buttonMinHeight, AppSpacing.buttonMinHeight),
      shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
    );
  }

  static CardThemeData travelCardTheme() {
    return CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: BorderSide(color: AppColors.borderColor.withValues(alpha: 0.6), width: 0.5.w),
      ),
    );
  }

  static InputDecorationTheme inputTheme() {
    final radius = BorderRadius.circular(AppShapes.inputRadius);
    return InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.navy, width: 1.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.critical),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.critical, width: 1.5.w),
      ),
      hintStyle: AppTextStyles.placeholder,
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      errorStyle: AppTextStyles.error,
      prefixIconColor: AppColors.textTertiary,
      suffixIconColor: AppColors.textTertiary,
    );
  }

  static InputDecoration searchDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.lightGray,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppShapes.md,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppShapes.md,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppShapes.md,
        borderSide: BorderSide(color: AppColors.navy.withValues(alpha: 0.35), width: 1.5.w),
      ),
      hintStyle: AppTextStyles.placeholder,
    );
  }

  /// Chip & filter — mengikuti [ColorScheme] aktif (FilterChip + Chip).
  static ChipThemeData chipTheme(ColorScheme cs) => ChipThemeData(
        checkmarkColor: cs.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.65), width: 0.5),
        color: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          if (states.contains(WidgetState.disabled)) {
            return cs.surfaceContainerHighest.withValues(alpha: 0.55);
          }
          return cs.surfaceContainerHighest;
        }),
        labelStyle: AppTextStyles.badge.copyWith(color: cs.onSurfaceVariant),
        secondaryLabelStyle: AppTextStyles.badge.copyWith(color: cs.onPrimary),
      );
}
