import 'package:flutter/material.dart';

/// Enterprise breakpoint tokens — logical pixels, platform-agnostic.
///
/// **Aturan:** Jangan hardcode `600` / `1024` di widget. Selalu pakai [AppBreakpoints]
/// atau extension [AppBreakpointsContext] pada [BuildContext].
abstract final class AppBreakpoints {
  /// Batas atas form factor mobile (exclusive).
  static const double mobile = 600;

  /// Batas atas form factor tablet / iPad (exclusive).
  static const double tablet = 1024;

  /// Batas atas form factor laptop (exclusive) — di atas ini = desktop monitor.
  static const double laptop = 1440;

  /// Lebar maksimum konten absolut (monitor ultrawide).
  static const double maxContentWidth = 1920;

  /// Padding horizontal dalam kotak shell (setelah margin %).
  static const double desktopPageInset = 40;

  /// Fraksi margin shell pada monitor lebar (≥1440px).
  static const double desktopShellMarginFraction = 0.06;

  /// Margin simetris kiri/kanan — ringan di tablet, naik perlahan di layar lebar.
  static double shellSideMargin(double screenWidth) {
    if (screenWidth < mobile) return 0;
    if (screenWidth < tablet) {
      return (screenWidth * 0.03).clamp(12.0, 24.0);
    }
    if (screenWidth < laptop) {
      return (screenWidth * 0.04).clamp(20.0, 44.0);
    }
    return (screenWidth * desktopShellMarginFraction)
        .clamp(48.0, screenWidth * 0.12);
  }

  /// Lebar kotak shell (header + body) — viewport dikurangi margin % kiri/kanan.
  static double shellContentBoxWidth(double screenWidth) {
    if (screenWidth < mobile) return screenWidth;
    return screenWidth - shellSideMargin(screenWidth) * 2;
  }

  /// Lebar area konten di dalam shell (setelah margin + [pageInset]).
  static double shellListingRowWidth(double screenWidth) {
    if (screenWidth < mobile) {
      return screenWidth - pageInset(screenWidth) * 2;
    }
    return shellContentBoxWidth(screenWidth) - pageInset(screenWidth) * 2;
  }

  /// Lebar baris carousel ideal: N card + jarak + peek (referensi slot 2/4/6/7).
  static double listingCarouselRowWidth(
    double screenWidth, {
    double spacing = 8,
  }) {
    final slots = listingCarouselVisibleCount(screenWidth);
    final card = listingCardWidth;
    final peek = card * listingCarouselPeekFraction;
    return slots * card + (slots - 1) * spacing + peek;
  }

  /// Lebar efektif area konten dari lebar viewport.
  static double contentWidth(double screenWidth) {
    if (screenWidth < tablet) return screenWidth;
    return (screenWidth - desktopPageInset * 2).clamp(mobile, maxContentWidth);
  }

  /// Padding horizontal halaman — naik per form factor, tidak dobel dengan margin shell.
  static double pageInset(double screenWidth) {
    if (screenWidth >= laptop) return desktopPageInset;
    if (screenWidth >= tablet) return 20;
    if (screenWidth >= mobile) return 16;
    return 16;
  }

  /// Lebar sidebar promo / panel sekunder di layout desktop.
  static const double desktopSidebarWidth = 320;

  /// Lebar minimum area konten (setelah nav rail) untuk layout desktop penuh.
  static const double desktopLayoutMinWidth = 900;

  /// Lebar maksimum shell halaman detail (galeri + 2 kolom).
  static const double detailShellMaxWidth = 1280;

  /// Lebar kartu booking sticky di desktop (Airbnb ~368px).
  static const double detailBookingCardWidth = 368;

  /// Tinggi galeri foto detail.
  static const double detailGalleryHeightMobile = 320;
  static const double detailGalleryHeightDesktop = 420;

  static bool detailUsesSidebar(double screenWidth) =>
      screenWidth >= desktopLayoutMinWidth;

  /// Lebar minimum area konten untuk split-screen (konten + sidebar promo).
  static const double desktopSplitMinWidth = 1100;

  /// Lebar [NavigationRail] compact (tablet).
  static const double navigationRailWidth = 80;

  /// Lebar [NavigationRail] extended (desktop).
  static const double navigationRailExtendedWidth = 256;

  static AppFormFactor formFactorOf(double width) {
    if (width >= tablet) return AppFormFactor.desktop;
    if (width >= mobile) return AppFormFactor.tablet;
    return AppFormFactor.mobile;
  }

  /// Lebar tetap card listing — SAMA di mobile, iPad, laptop, desktop.
  ///
  /// Isi card (font/spacing) pakai [ListingCardTypography] — fixed px, bukan `.sp`/`.w`.
  /// Lihat `docs/design-system.md` §3.3 Scale vs Fixed.
  static const double listingCardWidth = 172;

  /// @deprecated Pakai [listingCardWidth].
  static const double listingCardMinWidth = listingCardWidth;

  /// @deprecated Pakai [listingCardWidth].
  static const double listingCardMaxWidth = listingCardWidth;

  /// @deprecated Pakai [listingCardWidth].
  static const double listingCarouselCardWidth = listingCardWidth;

  /// Fraksi card berikutnya yang mengintip di ujung carousel.
  static const double listingCarouselPeekFraction = 0.2;

  /// Target card terlihat per form factor: HP 2 · iPad 4 · Laptop 6 · Desktop 7.
  /// Hanya untuk scroll/panah — ukuran card tetap [listingCardWidth].
  static int listingCarouselVisibleCount(double screenWidth) {
    if (screenWidth < mobile) return 2;
    if (screenWidth < tablet) return 4;
    if (screenWidth < laptop) return 6;
    return 7;
  }

  /// @deprecated Pakai [listingCarouselVisibleCount].
  static int listingCarouselVisibleSlots(double screenWidth) =>
      listingCarouselVisibleCount(screenWidth);

  /// Lebar sel carousel — mengisi [viewportWidth] persis (N slot + peek), ala Airbnb web.
  ///
  /// Grid halaman list tetap pakai [listingCardWidth] tetap; carousel home menyesuaikan lebar baris.
  static double listingCellWidthForViewport(
    double viewportWidth, {
    required double screenWidth,
    required int itemCount,
    double spacing = 8,
  }) {
    if (viewportWidth <= 0 || itemCount <= 0) return listingCardWidth;

    final maxSlots = listingCarouselVisibleCount(screenWidth);
    final slots = itemCount < maxSlots ? itemCount : maxSlots;
    final peek =
        itemCount > maxSlots ? listingCarouselPeekFraction : 0.0;
    final gaps = (slots - 1) * spacing;
    final cell = (viewportWidth - gaps) / (slots + peek);
    return cell.clamp(120.0, 320.0);
  }

  /// @deprecated Pakai [listingCellWidthForViewport].
  static double listingCarouselCardWidthFor(
    double contentWidth, {
    double spacing = 8,
    required double screenWidth,
    int itemCount = 7,
  }) =>
      listingCellWidthForViewport(
        contentWidth,
        screenWidth: screenWidth,
        itemCount: itemCount,
        spacing: spacing,
      );

  /// @deprecated Pakai [listingCarouselVisibleCount] sebagai batas kolom grid.
  static const int listingGridMaxColumns = 7;

  /// Maks kolom grid halaman list — slot sama carousel home (2/4/6/7).
  static int listingGridListMaxColumns(double screenWidth) {
    return listingCarouselVisibleCount(screenWidth);
  }

  /// Hitung kolom grid halaman list.
  static int listingGridColumns(double width, {double spacing = 8}) {
    final maxCols = listingGridListMaxColumns(width);
    final computed =
        ((width + spacing) / (listingCardWidth + spacing)).floor();
    if (width < mobile) {
      return computed.clamp(1, 2);
    }
    return computed.clamp(1, maxCols);
  }

  /// Lebar sel grid — mengisi baris (min [listingCardWidth]).
  static double listingGridCellWidth(double width, {double spacing = 8}) {
    final columns = listingGridColumns(width, spacing: spacing);
    final gaps = (columns - 1) * spacing;
    return ((width - gaps) / columns).clamp(listingCardWidth, width);
  }
}

/// Form factor aktif berdasarkan lebar viewport.
enum AppFormFactor {
  mobile,
  tablet,
  desktop,
}

/// Shorthand responsif di widget tree.
extension AppBreakpointsContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  AppFormFactor get formFactor => AppBreakpoints.formFactorOf(screenWidth);

  bool get isMobile => formFactor == AppFormFactor.mobile;

  bool get isTablet => formFactor == AppFormFactor.tablet;

  bool get isDesktop => formFactor == AppFormFactor.desktop;

  bool get isLaptop => screenWidth >= AppBreakpoints.tablet && screenWidth < AppBreakpoints.laptop;

  bool get isLargeDesktop => screenWidth >= AppBreakpoints.laptop;

  int get listingCarouselVisibleCount =>
      AppBreakpoints.listingCarouselVisibleCount(screenWidth);

  int get destinationGridColumns => AppBreakpoints.listingGridColumns(screenWidth);

  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;

  /// HP landscape: tinggi viewport sangat kecil — layout harus scrollable & compact.
  bool get isLandscapeNarrow =>
      isLandscape && screenHeight < AppBreakpoints.mobile && isMobile;

  /// Tablet/desktop & web — aktifkan hover state mouse.
  bool get supportsHover => isTablet || isDesktop;

  double get pageInset => AppBreakpoints.pageInset(screenWidth);

  double get contentWidth => AppBreakpoints.contentWidth(screenWidth);

  double get listingCarouselRowWidth =>
      AppBreakpoints.listingCarouselRowWidth(screenWidth);

  double get shellContentBoxWidth =>
      AppBreakpoints.shellContentBoxWidth(screenWidth);

  double get shellListingRowWidth =>
      AppBreakpoints.shellListingRowWidth(screenWidth);

  bool get detailUsesSidebar => AppBreakpoints.detailUsesSidebar(screenWidth);
}
