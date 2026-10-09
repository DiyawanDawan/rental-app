import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color.dart';

/// Unified Text Styles for Travelindo
/// All text styles use Poppins font and follow Material 3 design system
class AppTextStyles {
  // ====== Display Styles (Large headlines) ======

  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  static TextStyle get displaySmall => GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  // ====== Headline Styles ======

  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  // ====== Title Styles ======

  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: 0.5.w,
      );

  // ====== Body Styles ======

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ====== Label Styles ======

  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
        letterSpacing: 0.5.w,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
        letterSpacing: 0.5.w,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
        letterSpacing: 0.5.w,
      );

  // ====== Custom Semantic Styles ======

  /// Primary action button text
  static TextStyle get buttonPrimary => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
        letterSpacing: 0.5.w,
      );

  /// Secondary action button text
  static TextStyle get buttonSecondary => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.orange,
        letterSpacing: 0.5.w,
      );

  /// Price/amount text
  static TextStyle get price => GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.teal,
        letterSpacing: 0.3.w,
      );

  /// Discount/promo text
  static TextStyle get discount => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.critical,
        letterSpacing: 0.3.w,
      );

  /// Card subtitle text
  static TextStyle get cardSubtitle => GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );

  /// Tertiary text (least important)
  static TextStyle get tertiary => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  /// Input placeholder text
  static TextStyle get placeholder => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textTertiary.withValues(alpha: 0.6),
      );

  /// Error/validation message
  static TextStyle get error => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.critical,
      );

  /// Success message
  static TextStyle get success => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.statusAvailable,
      );

  /// Badge text
  static TextStyle get badge => GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
        letterSpacing: 0.3.w,
      );

  /// Navigation label
  static TextStyle get navLabel => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.surface,
      );

  /// Tab label
  static TextStyle get tabLabel => GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      );

  /// Card subtitle / deskripsi destinasi — height rapat untuk list padat
  static TextStyle get destinationDescription => bodySmall.copyWith(
        height: 1.35,
        color: AppColors.textTertiary,
      );

  /// Metadata baris card (lokasi, durasi) — single line
  static TextStyle get cardMeta => bodySmall.copyWith(
        height: 1.25,
        color: AppColors.textTertiary,
      );

  /// Harga di card list — scan cepat (pasar ID)
  static TextStyle get cardPrice => price.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  /// Label "Mulai dari" di sticky bar
  static TextStyle get priceLabel => bodySmall.copyWith(
        height: 1.2,
        color: AppColors.textTertiary,
      );

  // ====== Utility Methods ======

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get disabled text style
  static TextStyle disabled(TextStyle style) {
    return style.copyWith(
      color: style.color?.withValues(alpha: 0.5) ?? AppColors.textSecondary.withValues(alpha: 0.5),
    );
  }

  /// Get bold variant of style
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }
}
