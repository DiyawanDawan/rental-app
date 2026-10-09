import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tipografi & spacing **listing card** — fixed logical px (bukan `.sp`/`.w`).
///
/// Card lebar tetap [AppBreakpoints.listingCardWidth]; isi harus predictable
/// agar [ListingCardMetrics] tidak overflow di layar lebar.
///
/// **Kapan pakai ini vs AppTextStyles:** lihat `docs/design-system.md` §3.3.
abstract final class ListingCardTypography {
  static const double paddingHorizontal = 8;
  static const double paddingTop = 14;
  static const double paddingBottom = 8;
  static const double lineGap = 8;
  static const double providerLeadGap = 10;
  static const double providerIconGap = 6;
  static const double titleSize = 13;
  static const double bodySize = 11;
  static const double priceSize = 13;
  static const double metaIconSize = 11;

  static const double titleLineHeight = 1.2;
  static const double bodyLineHeight = 1.25;
  static const double priceLineHeight = 1.1;

  /// Slack cadangan sub-pixel (sudah termasuk [paddingBottom] di layout).
  static const double textBlockSlack = 2;

  static double get providerLineAllocated =>
      math.max(bodyLineAllocated, metaIconSize + 4).ceilToDouble();

  /// Judul w600 — sedikit lebih tinggi dari metrik teori.
  static double get titleLineAllocated => (titleLinePx + 1).ceilToDouble();

  static double get bodyLineAllocated => bodyLinePx.ceilToDouble();

  /// Baris harga / ikon bintang / durasi.
  static double get actionRowAllocated =>
      math.max(priceLinePx, metaIconSize).ceilToDouble() + 1;

  /// Baris harga tunggal (paket wisata baris 2).
  static double get priceLineAllocated => (priceLinePx + 1).ceilToDouble();

  static double get titleLinePx => titleSize * titleLineHeight;

  static double get bodyLinePx => bodySize * bodyLineHeight;

  static double get priceLinePx => priceSize * priceLineHeight;

  static TextStyle title(TextStyle base) => base.copyWith(
        fontSize: titleSize,
        height: titleLineHeight,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle body(TextStyle base) => base.copyWith(
        fontSize: bodySize,
        height: bodyLineHeight,
        letterSpacing: 0,
      );

  static TextStyle price(TextStyle base) => base.copyWith(
        fontSize: priceSize,
        height: priceLineHeight,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
      );

  /// Dua baris: judul + meta.
  static double get twoLineBlockHeight =>
      paddingTop +
      titleLineAllocated +
      lineGap +
      bodyLineAllocated +
      textBlockSlack;

  /// Tiga baris kendaraan: judul + meta + harga/rating + penyedia.
  static double get vehicleTextBlockHeight =>
      paddingTop +
      titleLineAllocated +
      lineGap +
      bodyLineAllocated +
      lineGap +
      actionRowAllocated +
      providerLeadGap +
      providerLineAllocated +
      paddingBottom +
      textBlockSlack;

  static double get tourTextBlockHeight =>
      paddingTop +
      titleLineAllocated +
      lineGap +
      priceLineAllocated +
      lineGap +
      actionRowAllocated +
      providerLeadGap +
      providerLineAllocated +
      paddingBottom +
      textBlockSlack;

  /// Padding blok teks listing — inset kiri/kanan agar tidak nempel antar card.
  static EdgeInsets get textPadding => const EdgeInsets.fromLTRB(
        paddingHorizontal,
        paddingTop,
        paddingHorizontal,
        paddingBottom,
      );

  /// Bungkus satu baris teks dengan tinggi tetap — cegah overflow Column.
  static Widget line({
    required double height,
    required Widget child,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Align(alignment: alignment, child: child),
    );
  }
}
