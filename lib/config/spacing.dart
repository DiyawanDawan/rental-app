import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Skala spatial 4dp — satu-satunya sumber spacing di Travelindo.
///
/// **Prinsip:** Semua angka kelipatan 4. Jangan pakai 10, 14, 18, 28, 30 di layout.
/// Lihat [`docs/pixel-perfect-spacing-layout.md`](../docs/pixel-perfect-spacing-layout.md).
///
/// Skala Traveloka-tier: `md` = 12dp (bukan 16). Gunakan `lg` / `verticalHeight16` untuk 16dp.
abstract final class AppSpacing {
  /// Density multiplier dari [DisplayDensityService] (1.0 normal, 0.92 compact).
  static double density = 1.0;

  static double _d(double value) => value * density;

  // ── Skala dasar (4dp grid) ──────────────────────────────────────────────
  static double get xxs => _d(2.w); // micro: badge inset — jangan untuk section
  static double get xs => _d(4.w); // stack: label→value, icon→teks 1 baris
  static double get sm => _d(8.w); // tight: title→subtitle, chip gap
  static double get md => _d(12.w); // default list/card — standar Traveloka-tier
  static double get lg => _d(16.w); // page horizontal, form field gap
  static double get xl => _d(20.w); // section break antar blok konten
  static double get xxl => _d(24.w); // section besar (max 1× per scroll viewport)

  /// Alias eksplisit 16dp — untuk dev yang terbiasa `spacing: 16`.
  static double get spacing16 => lg;

  // ── Semantic aliases (wajib dipakai di page) ────────────────────────────
  static double get page => lg; // 16dp — margin kiri/kanan layar
  static double get pageTop => md; // 12dp — jarak bawah AppBar ke konten
  static double get section => xl; // 20dp — antar section Home / detail
  /// Jarak antar blok carousel/listing di home (desktop & mobile).
  static double get homeSection => xxl + lg; // 40dp
  static double get listGap => md; // 12dp — antar card di ListView
  static double get cardPad => md; // 12dp — padding dalam card
  static double get cardPadCompact => sm; // 8dp — carousel horizontal
  static double get stackGap => xs; // 4dp — judul→meta dalam card
  static double get formGap => md; // 12dp — antar TextField
  static double get ctaBar => lg; // 16dp — sticky bottom bar inset
  static double get buttonMinHeight => 48.h; // thumb zone ID

  // ── Vertical rhythm (pixel-perfect pairs) ─────────────────────────────
  static double get titleToSubtitle => sm; // 8dp
  static double get imageToContent => sm; // 8dp — foto → teks (card/list)
  static double get headlineToBody => md; // 12dp — H1/H2 → paragraf
  static double get bodyToCta => lg; // 16dp — deskripsi → tombol (min)
  static double get sectionTitleToContent => sm; // 8dp — "Rekomendasi" → list

  // ── Layout khusus (bukan rhythm umum) ─────────────────────────────────
  static double get ctaSpacer => xxl + sm; // 32dp — konten → tombol utama / sticky CTA
  static double get fabListClearance => _d(88.h); // list scroll clearance di atas FAB
  static double get mapBoundsPad => _d(48.w); // inset camera fit peta
  static double get mapPickerFabClearance => _d(200.h); // mini FAB di atas bottom card (map picker)
}

/// Padding & margin siap pakai — hindari `EdgeInsets.all(16.w)` manual.
abstract final class AppPadding {
  /// Horizontal 16dp — standar semua halaman list/detail.
  static EdgeInsets get screenH => EdgeInsets.symmetric(horizontal: AppSpacing.page);

  /// All 16dp — halaman form sederhana.
  static EdgeInsets get screen => EdgeInsets.all(AppSpacing.page);

  /// Atas 12dp, samping 16dp — konten di bawah AppBar.
  static EdgeInsets get screenBody =>
      EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.pageTop, AppSpacing.page, 0);

  /// List scroll — horizontal page, vertical listGap antar item via separator.
  static EdgeInsets get list => EdgeInsets.all(AppSpacing.page);

  /// Card interior — 12dp all sides.
  static EdgeInsets get card => EdgeInsets.all(AppSpacing.cardPad);

  /// Sticky CTA bar — 16dp + SafeArea bottom.
  static EdgeInsets get ctaBar => EdgeInsets.all(AppSpacing.ctaBar);

  /// List dengan FAB mengambang di kanan bawah.
  static EdgeInsets get listWithFab =>
      EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.page, AppSpacing.page, AppSpacing.fabListClearance);
}

/// Gap vertikal/horizontal eksplisit — ganti `SizedBox(height: X.h)`.
abstract final class AppGap {
  static Widget get xxs => SizedBox(height: AppSpacing.xxs);
  static Widget get xs => SizedBox(height: AppSpacing.xs);
  static Widget get sm => SizedBox(height: AppSpacing.sm);
  static Widget get md => SizedBox(height: AppSpacing.md);
  static Widget get lg => SizedBox(height: AppSpacing.lg);
  static Widget get xl => SizedBox(height: AppSpacing.xl);
  static Widget get section => SizedBox(height: AppSpacing.section);
  static Widget get homeSection => SizedBox(height: AppSpacing.homeSection);

  /// Alias vertikal eksplisit (enterprise naming).
  static Widget get verticalHeight4 => xs;
  static Widget get verticalHeight8 => sm;
  static Widget get verticalHeight12 => md;
  static Widget get verticalHeight16 => lg;
  static Widget get verticalHeight20 => xl;
  static Widget get verticalHeight24 => SizedBox(height: AppSpacing.xxl);

  static Widget get titleToSubtitle => SizedBox(height: AppSpacing.titleToSubtitle);
  static Widget get imageToContent => SizedBox(height: AppSpacing.imageToContent);
  static Widget get headlineToBody => SizedBox(height: AppSpacing.headlineToBody);
  static Widget get bodyToCta => SizedBox(height: AppSpacing.bodyToCta);
  static Widget get sectionTitleToContent => SizedBox(height: AppSpacing.sectionTitleToContent);
  static Widget get ctaSpacer => SizedBox(height: AppSpacing.ctaSpacer);

  static Widget h(double width) => SizedBox(width: width);
  static Widget v(double height) => SizedBox(height: height);

  static Widget get horizontalWidth4 => SizedBox(width: AppSpacing.xs);
  static Widget get horizontalWidth8 => SizedBox(width: AppSpacing.sm);
  static Widget get horizontalWidth12 => SizedBox(width: AppSpacing.md);
  static Widget get horizontalWidth16 => SizedBox(width: AppSpacing.lg);
}

/// Extension — shorthand di widget tree.
extension AppSpacingContext on BuildContext {
  double get screenPad => AppSpacing.page;
  EdgeInsets get screenPaddingH => AppPadding.screenH;
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
}
