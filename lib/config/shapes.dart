import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color.dart';

/// Border radius, squircle, elevation — sudut organik ala Airbnb/Traveloka.
abstract final class AppShapes {
  // ── Radius scale (4dp grid) ─────────────────────────────────────────────
  static BorderRadius get xxs => BorderRadius.circular(4.r);
  static BorderRadius get xs => BorderRadius.circular(6.r);
  static BorderRadius get sm => BorderRadius.circular(8.r);
  static BorderRadius get md => BorderRadius.circular(12.r);
  static BorderRadius get lg => BorderRadius.circular(16.r);
  static BorderRadius get xl => BorderRadius.circular(20.r);
  static BorderRadius get pill => BorderRadius.circular(999.r);

  static double get cardRadius => 12.r;
  static double get buttonRadius => 10.r;
  static double get inputRadius => 12.r;
  static double get dialogRadius => 16.r;

  // ── Semantic shapes ───────────────────────────────────────────────────────
  /// Card destinasi / tour — squircle halus (tidak kotak tajam).
  static ShapeBorder get destinationCard => softCard(radius: md);

  /// Tombol — sedikit lebih tight dari card.
  static BorderRadius get button => BorderRadius.circular(buttonRadius);
  static ShapeBorder get buttonShape => RoundedRectangleBorder(borderRadius: button);

  /// Input field.
  static BorderRadius get input => BorderRadius.circular(inputRadius);

  /// Sudut atas bottom sheet / modal.
  static BorderRadius get sheetTop => BorderRadius.vertical(top: Radius.circular(16.r));

  /// Dialog / full-screen sheet.
  static BorderRadius get dialog => BorderRadius.circular(dialogRadius);

  // ── Squircle / continuous corner ──────────────────────────────────────────
  /// Squircle organik — prefer di card premium & tile besar.
  static ShapeBorder softCard({BorderRadius? radius}) {
    return RoundedSuperellipseBorder(
      borderRadius: radius ?? md,
      side: BorderSide(color: AppColors.border.withValues(alpha: 0.55), width: 0.5),
    );
  }

  static ShapeBorder softButton({bool outlined = false}) {
    if (outlined) {
      return RoundedSuperellipseBorder(
        borderRadius: button,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
      );
    }
    return RoundedSuperellipseBorder(borderRadius: button);
  }

  static ShapeBorder softSheet() => RoundedSuperellipseBorder(
        borderRadius: sheetTop,
      );

  // ── Shadows (soft elevation — bukan Material default keras) ───────────────
  static List<BoxShadow> cardShadow({double opacity = 0.08, double blur = 16, double y = 4}) => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: opacity),
          blurRadius: blur.r,
          offset: Offset(0, y.h),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> cardShadowPressed({double opacity = 0.14}) => cardShadow(opacity: opacity, blur: 20, y: 6);

  static List<BoxShadow> floatingShadow() => [
        BoxShadow(
          color: AppColors.shadowSoft,
          blurRadius: 24.r,
          offset: Offset(0, 8.h),
        ),
      ];

  // ── Media ratios ──────────────────────────────────────────────────────────
  static const double listImageAspectRatio = 16 / 9;
  static const double heroImageAspectRatio = 4 / 3;
  static const double compactImageAspectRatio = 4 / 3;
  static const double destinationCardAspectRatio = 16 / 9;

  /// Rasio foto listing (Airbnb-style) — sama di semua breakpoint.
  static const double listingCardAspectRatio = 20 / 19;
}
