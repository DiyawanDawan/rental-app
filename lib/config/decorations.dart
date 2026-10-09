import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color.dart';
import 'shapes.dart';

/// Premium visual tokens — shadow, gradient, glass, border halus.
///
/// **Aturan:** Semua dekorasi visual melalui class ini. Jangan hardcode shadow/gradient di widget.
abstract final class AppDecorations {
  // ── Shimmer palette ───────────────────────────────────────────────────────
  static Color get shimmerBase => AppColors.neutral50;
  static Color get shimmerMid => AppColors.neutral100;
  static Color get shimmerHighlight => AppColors.surface;

  // ── Airbnb-style shadow — besar, lembut, melayang (fixed px, web-safe) ─────
  /// Bayangan mengambang ala Airbnb — listing foto & floating card.
  static List<BoxShadow> airbnbFloatingShadow(
    BuildContext context, {
    bool emphasized = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: emphasized ? 0.42 : 0.32),
          blurRadius: emphasized ? 36 : 28,
          offset: Offset(0, emphasized ? 14 : 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: emphasized ? 0.16 : 0.12),
        blurRadius: emphasized ? 36 : 32,
        offset: Offset(0, emphasized ? 14 : 12),
      ),
      BoxShadow(
        color: AppColors.primaryDeep.withValues(alpha: emphasized ? 0.08 : 0.06),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ── Soft shadow (legacy — prefer [airbnbFloatingShadow]) ─────────────────
  /// Drop shadow halus — default diselaraskan Airbnb.
  static List<BoxShadow> softShadow({
    double opacity = 0.1,
    double blur = 32,
    double spread = 0,
    double offsetY = 12,
    Color? tint,
  }) =>
      [
        BoxShadow(
          color: (tint ?? AppColors.primaryDeep).withValues(alpha: opacity),
          blurRadius: blur.r,
          spreadRadius: spread.r,
          offset: Offset(0, offsetY.h),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity * 0.45),
          blurRadius: (blur * 0.28).r,
          spreadRadius: spread.r,
          offset: Offset(0, (offsetY * 0.35).h),
        ),
      ];

  /// Shadow lebih tegas saat pressed / emphasized.
  static List<BoxShadow> softShadowElevated({double opacity = 0.14}) => softShadow(
        opacity: opacity,
        blur: 36,
        spread: 0,
        offsetY: 14,
      );

  /// Shadow untuk FAB / chip mengambang.
  static List<BoxShadow> softShadowFloating() => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.14),
          blurRadius: 20.r,
          offset: Offset(0, 6.h),
        ),
        BoxShadow(
          color: AppColors.shadowSoft,
          blurRadius: 12.r,
          offset: Offset(0, 2.h),
        ),
      ];

  // ── Premium gradients ───────────────────────────────────────────────────────
  /// Gradasi promo utama — hangat → deep navy (mewah, dinamis).
  static LinearGradient get premiumGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentWarm,
          AppColors.accentWarm.withValues(alpha: 0.85),
          AppColors.primaryDeep,
        ],
        stops: const [0.0, 0.42, 1.0],
      );

  /// Gradasi header / hero — cyan travel professional.
  static LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary,
          AppColors.primaryDeep,
        ],
      );

  /// Gradasi subtle untuk surface card (bukan flat putih).
  static LinearGradient get surfaceGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface,
          AppColors.surfaceMuted.withValues(alpha: 0.35),
        ],
      );

  /// Gradasi shimmer kilauan kiri → kanan.
  static LinearGradient shimmerGradient(double slide) => LinearGradient(
        begin: Alignment(-1.0 + slide * 2, 0),
        end: Alignment(slide * 2, 0),
        colors: [
          shimmerBase,
          shimmerMid,
          shimmerHighlight,
          shimmerMid,
          shimmerBase,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      );

  /// Overlay gelap di atas foto banner.
  static LinearGradient get imageScrimGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.scrim.withValues(alpha: 0.05),
          AppColors.scrim.withValues(alpha: 0.55),
        ],
      );

  // ── Borders halus ───────────────────────────────────────────────────────────
  static Border borderSubtle({double width = 0.5, Color? color}) => Border.all(
        color: (color ?? AppColors.border).withValues(alpha: 0.65),
        width: width,
      );

  static Border borderGlow({Color? color}) => Border.all(
        color: (color ?? AppColors.primaryLight).withValues(alpha: 0.35),
        width: 1,
      );

  // ── BoxDecoration presets ───────────────────────────────────────────────────
  /// Card premium mengambang — squircle + soft shadow.
  static BoxDecoration floatingCard({
    BorderRadius? radius,
    Color? color,
    List<BoxShadow>? shadows,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius ?? AppShapes.md,
        border: borderSubtle(),
        boxShadow: shadows ?? softShadow(),
      );

  /// Card promo dengan gradasi penuh.
  static BoxDecoration promoCard({BorderRadius? radius}) => BoxDecoration(
        gradient: premiumGradient,
        borderRadius: radius ?? AppShapes.lg,
        boxShadow: softShadow(opacity: 0.14, blur: 24, offsetY: 8, tint: AppColors.accentWarm),
        border: Border.all(color: AppColors.onDark.withValues(alpha: 0.12)),
      );

  /// Destinasi card — squircle brand + soft shadow (selaras [floatingCard]).
  static ShapeDecoration destinationFloatingCard({Color? color}) => ShapeDecoration(
        color: color ?? AppColors.surface,
        shape: AppShapes.destinationCard,
        shadows: softShadow(),
      );

  /// Surface datar elegan — anti flat polos.
  static BoxDecoration elevatedSurface({BorderRadius? radius}) => BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: radius ?? AppShapes.md,
        border: borderSubtle(),
        boxShadow: softShadow(opacity: 0.05, blur: 20, offsetY: 6),
      );

  /// [elevatedSurface] yang mengikuti [ThemeData] aktif.
  static BoxDecoration elevatedSurfaceOf(BuildContext context, {BorderRadius? radius}) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: surface,
      gradient: isDark
          ? null
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [surface, theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)],
            ),
      borderRadius: radius ?? AppShapes.md,
      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.45)),
      boxShadow: isDark ? null : softShadow(opacity: 0.05, blur: 20, offsetY: 6),
    );
  }

  /// Shadow card umum — halus (bukan Semua Layanan).
  static List<BoxShadow> cardShadowForTheme(
    BuildContext context, {
    bool emphasized = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) {
      return emphasized ? softShadowElevated() : softShadow();
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: emphasized ? 0.4 : 0.28),
        blurRadius: emphasized ? 24 : 18,
        offset: Offset(0, emphasized ? 10 : 6),
      ),
    ];
  }

  /// Card blok **Semua Layanan** — shadow Airbnb besar + surface putih.
  static BoxDecoration serviceBlockCardOf(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: AppShapes.md,
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.28 : 0.2),
      ),
      boxShadow: airbnbFloatingShadow(context),
    );
  }

  /// Radius foto listing — fixed 12px (tanpa shadow).
  static const BorderRadius listingCardRadius = BorderRadius.all(Radius.circular(12));

  /// [floatingCard] yang mengikuti [ThemeData] aktif.
  static BoxDecoration floatingCardOf(BuildContext context, {BorderRadius? radius, List<BoxShadow>? shadows}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: radius ?? AppShapes.md,
      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.45 : 0.65)),
      boxShadow: shadows ?? cardShadowForTheme(context),
    );
  }

  /// [destinationFloatingCard] yang mengikuti [ThemeData] aktif.
  static ShapeDecoration destinationFloatingCardOf(BuildContext context, {Color? color}) {
    return ShapeDecoration(
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: AppShapes.destinationCard,
      shadows: cardShadowForTheme(context),
    );
  }

  // ── Glassmorphism ───────────────────────────────────────────────────────────
  /// Dekorasi dasar kaca — pair dengan [glassmorphicFilter].
  static BoxDecoration glassmorphicStyle({
    BorderRadius? radius,
    double fillOpacity = 0.72,
    double borderOpacity = 0.22,
  }) =>
      BoxDecoration(
        color: AppColors.surface.withValues(alpha: fillOpacity),
        borderRadius: radius ?? AppShapes.lg,
        border: Border.all(
          color: AppColors.onDark.withValues(alpha: borderOpacity),
          width: 0.5,
        ),
        boxShadow: softShadow(opacity: 0.04, blur: 16, offsetY: 4),
      );

  /// Blur filter untuk bottom nav / floating header.
  static ImageFilter glassmorphicFilter({double sigma = 16}) => ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.clamp,
      );

  /// Widget wrapper glassmorphic siap pakai.
  static Widget glassmorphic({
    required Widget child,
    BorderRadius? radius,
    double blurSigma = 16,
    double fillOpacity = 0.72,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final borderRadius = radius ?? AppShapes.lg;
    return Container(
      margin: margin,
      decoration: glassmorphicStyle(radius: borderRadius, fillOpacity: fillOpacity),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: glassmorphicFilter(sigma: blurSigma),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
