import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// Token animasi fluid — durasi, kurva, dan micro-interaction Travelindo.
///
/// **Prinsip:** Transisi halaman & tap feedback harus konsisten di seluruh app.
/// Jangan hardcode `Duration(milliseconds: 250)` di widget.
abstract final class AppMotion {
  // ── Durasi ──────────────────────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration leisurely = Duration(milliseconds: 600);

  /// Interval auto-advance carousel promo/banner di home.
  static const Duration bannerCarouselInterval = Duration(seconds: 5);

  /// Alias enterprise (nama eksplisit untuk dokumentasi & onboarding dev).
  static const Duration durationInstant = instant;
  static const Duration durationFast = fast;
  static const Duration durationMedium = medium;
  static const Duration durationSlow = slow;

  // ── Kurva organik (Airbnb / Traveloka feel) ─────────────────────────────
  /// Masuk — decelerate halus (card expand, sheet slide up).
  static const Curve enter = Curves.easeOutCubic;

  /// Keluar — accelerate ringan.
  static const Curve exit = Curves.easeInCubic;

  /// Pergerakan dua arah — page transition, tab switch.
  static const Curve move = Curves.easeInOutCubic;

  /// Overshoot halus — FAB, success checkmark.
  static const Curve spring = Curves.easeOutQuart;

  /// Kurva paling organik — hero, parallax, press release.
  static const Curve curveOrganic = Curves.easeOutCubic;

  /// Emphasis — modal, bottom sheet peak.
  static const Curve curveEmphasized = Curves.easeOutBack;

  // ── Micro-interaction scale ───────────────────────────────────────────────
  static const double pressScale = 0.97;
  static const double cardPressScale = 0.985;
  static const double chipPressScale = 0.96;

  // ── Page transition offsets ─────────────────────────────────────────────
  static const Offset pageSlideBegin = Offset(0.04, 0);
  static const Offset pageSlideUpBegin = Offset(0, 0.06);

  // ── Stagger list ──────────────────────────────────────────────────────────
  static const Duration staggerBase = Duration(milliseconds: 40);
  static const int staggerMaxDelay = 8;

  /// Delay stagger untuk index list (cap di [staggerMaxDelay]).
  static Duration staggerDelay(int index) =>
      Duration(milliseconds: (staggerBase.inMilliseconds * index.clamp(0, staggerMaxDelay)).toInt());

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Animation<double> tweenDouble({
    required AnimationController controller,
    double begin = 0,
    double end = 1,
    Curve curve = enter,
  }) =>
      CurvedAnimation(parent: controller, curve: curve)
          .drive(Tween<double>(begin: begin, end: end));
}
