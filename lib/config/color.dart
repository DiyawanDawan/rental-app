import 'package:flutter/material.dart';

/// Enterprise color system — Travelindo (Traveloka/Airbnb tier).
///
/// **Aturan:** Jangan pakai `Colors.blue`, `Color(0xFF…)`, atau hex mentah di widget.
/// Selalu gunakan [AppColors] atau `Theme.of(context).colorScheme`.
abstract final class AppColors {
  // ── Brand / Primary (Travel Professional Cyan-Blue) ─────────────────────
  /// Aksen utama — header, link, trust anchor (Traveloka-class cyan-blue).
  static const Color primary = Color(0xFF006989);

  /// Varian gelap — AppBar, nav, teks headline kuat.
  static const Color primaryDeep = Color(0xFF1E3A5F);

  /// Varian terang — hover, chip selected, ilustrasi.
  static const Color primaryLight = Color(0xFF4DA8BC);

  /// Container primary — background subtle badge/info.
  static Color get primaryContainer => primary.withValues(alpha: 0.12);

  // ── Secondary / Warm Accent (Promo & CTA) ─────────────────────────────
  /// Aksen hangat — tombol utama, promo, urgency.
  static const Color accentWarm = Color(0xFFFF6B35);

  /// Aksen hangat soft — secondary CTA background.
  static Color get accentWarmContainer => accentWarm.withValues(alpha: 0.12);

  // ── Tertiary (Eco / Verified / Nature) ──────────────────────────────────
  static const Color tertiary = Color(0xFF26A69A);
  static Color get tertiaryContainer => tertiary.withValues(alpha: 0.12);

  static const Color sageGreen = Color(0xFF7C9A6E);
  static Color get verifiedBadge => sageGreen;
  static Color get verifiedBadgeBg => sageGreen.withValues(alpha: 0.12);

  // ── Semantic (Status & Feedback) ──────────────────────────────────────
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFF4A261);
  static const Color error = Color(0xFFE63946);
  static const Color info = primary;

  static const Color statusAvailable = success;
  static const Color statusUnavailable = Color(0xFFB2BEC3);

  // ── Surfaces & Background ───────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  static const Color overlay = Color(0xCC1E3A5F);

  // ── Text on surfaces ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E3A5F);
  static const Color textSecondary = Color(0xFF2D3436);
  static const Color textTertiary = Color(0xFF636E72);
  static const Color textOnPrimary = surface;
  static const Color textOnAccent = surface;

  // ── Borders & Dividers ──────────────────────────────────────────────────
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderStrong = Color(0xFFCCCCCC);
  static const Color divider = border;

  // ── Neutral scale ───────────────────────────────────────────────────────
  static const Color neutral50 = Color(0xFFF5F5F5);
  static const Color neutral100 = Color(0xFFE8E8E8);
  static const Color neutral300 = Color(0xFFCCCCCC);
  static const Color neutral500 = Color(0xFF808080);
  static const Color neutral700 = Color(0xFF636E72);
  static const Color neutral900 = Color(0xFF2D3436);

  // ── On-dark / On-brand ───────────────────────────────────────────────────
  static const Color onDark = surface;
  static Color get onDarkMuted => surface.withValues(alpha: 0.7);
  static Color get onDarkDimmed => surface.withValues(alpha: 0.6);
  static Color get onDarkSubtle => surface.withValues(alpha: 0.24);

  // ── Shadows & scrims ─────────────────────────────────────────────────────
  static Color get shadow => primaryDeep.withValues(alpha: 0.1);
  static Color get shadowSoft => primaryDeep.withValues(alpha: 0.06);
  static Color get scrim => primaryDeep.withValues(alpha: 0.45);
  static Color get overlayScrim => scrim;
  static Color get overlayScrimHeavy => primaryDeep.withValues(alpha: 0.54);
  static Color get mediaBackdrop => primaryDeep;

  // ── Promo / Voucher (Traveloka coral-orange tier) ───────────────────────
  /// Merah-merona / coral khas promo Traveloka — badge, CTA voucher, aksen tiket.
  static const Color promoPrimary = Color(0xFFFF5C35);

  /// Coral lembut — highlight gradasi & hover state promo.
  static const Color promoSecondary = Color(0xFFFF8A65);

  /// Coral dalam — teks/ikon kontras di atas surface promo terang.
  static const Color promoDeep = Color(0xFFE84A2F);

  /// Background voucher lembut (light & dark-safe via alpha di widget).
  static Color get promoSurface => promoPrimary.withValues(alpha: 0.08);

  /// Surface promo sedikit lebih kuat — header section voucher list.
  static Color get promoSurfaceStrong => promoPrimary.withValues(alpha: 0.14);

  /// Container chip/kode voucher.
  static Color get promoContainer => promoPrimary.withValues(alpha: 0.12);

  /// Glow micro-interaction badge diskon.
  static Color get promoGlow => promoPrimary.withValues(alpha: 0.38);

  /// Teks di atas gradasi promo.
  static const Color promoOnGradient = surface;

  /// Gradasi horizontal badge & stub tiket voucher.
  static const List<Color> promoGradient = [promoPrimary, promoSecondary];

  /// Gradasi dramatis — hero banner voucher / kampanye.
  static const List<Color> promoGradientDeep = [promoPrimary, promoDeep, accentWarm];

  /// Gradasi vertikal lembut untuk surface kartu voucher.
  static List<Color> get promoSurfaceGradient => [
        promoSurface,
        promoSurfaceStrong,
      ];

  static LinearGradient get promoLinearGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: promoGradient,
      );

  static LinearGradient get promoHeroGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: promoGradientDeep,
        stops: [0.0, 0.55, 1.0],
      );

  static LinearGradient get promoSurfaceLinearGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: promoSurfaceGradient,
      );

  // ── Gradients ───────────────────────────────────────────────────────────
  static const List<Color> promotionGradient = [accentWarm, primaryDeep];
  static const List<Color> heroGradient = [primary, primaryDeep];
  static const List<Color> secondaryGradient = [tertiary, primaryDeep];

  // ── Legacy aliases (backward-compatible — jangan hapus) ─────────────────
  static const Color navy = primaryDeep;
  static const Color navyAlt = primary;
  static const Color orange = accentWarm;
  static const Color teal = tertiary;
  static const Color critical = error;
  static const Color backgroundMain = background;
  static const Color borderColor = border;
  static const Color lightGray = neutral50;
  static const Color mediumGray = neutral300;
  static const Color darkGray = neutral500;
  static const Color rating = warning;

  // ── Seat / map states ───────────────────────────────────────────────────
  static const Color seatOccupied = statusUnavailable;
  static const Color seatSelected = accentWarm;
  static const Color seatAvailable = neutral50;

  // ── Interaction helpers ─────────────────────────────────────────────────
  static Color getDisabledColor(Color color) => color.withValues(alpha: 0.5);

  static Color getHoverColor(Color color) => Color.lerp(color, primaryDeep, 0.1) ?? color;

  static Color getPressedColor(Color color) => Color.lerp(color, primaryDeep, 0.2) ?? color;

  /// Booking / order status badge color.
  static Color bookingStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'AWAITING_PAYMENT':
        return warning;
      case 'CONFIRMED':
      case 'APPROVED':
        return primary;
      case 'ACTIVE':
      case 'ONGOING':
      case 'HANDOVER':
      case 'HANDED_OVER':
        return tertiary;
      case 'COMPLETED':
      case 'RETURNED':
        return success;
      case 'CANCELLED':
      case 'REJECTED':
        return error;
      default:
        return neutral500;
    }
  }

  /// Resolve dari [ColorScheme] — untuk widget yang harus adaptif theme.
  static ColorScheme lightScheme() => ColorScheme.light(
        primary: primaryDeep,
        onPrimary: textOnPrimary,
        primaryContainer: primary,
        onPrimaryContainer: textOnPrimary,
        secondary: accentWarm,
        onSecondary: textOnAccent,
        secondaryContainer: accentWarmContainer,
        onSecondaryContainer: accentWarm,
        tertiary: tertiary,
        onTertiary: textOnPrimary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: tertiary,
        error: error,
        onError: textOnPrimary,
        surface: surface,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: border,
      );
}
