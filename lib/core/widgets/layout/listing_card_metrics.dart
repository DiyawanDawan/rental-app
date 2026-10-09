import '../../../config/shapes.dart';
import 'listing_card_typography.dart';

/// Perhitungan dimensi card listing (Airbnb-style) — dipakai semua section home.
abstract final class ListingCardMetrics {
  /// Buffer grid — ruang antar baris + bayangan card.
  static const double gridRowSpacingBuffer = 12;

  /// Buffer carousel — tanpa shadow listing.
  static const double carouselHeightBuffer = 8;

  static double gridChildAspectRatio(
    double cellWidth, {
    required double textBlockHeight,
  }) {
    final height = totalHeight(
      cellWidth,
      textBlockHeight: textBlockHeight,
      includeCarouselBuffer: true,
    );
    return cellWidth / height;
  }

  static double totalHeight(
    double cardWidth, {
    required double textBlockHeight,
    bool includeCarouselBuffer = false,
  }) {
    final imageHeight = cardWidth / AppShapes.listingCardAspectRatio;
    final buffer = includeCarouselBuffer ? carouselHeightBuffer : gridRowSpacingBuffer;
    return imageHeight + textBlockHeight + buffer;
  }

  /// Tinggi blok teks — selaras [ListingCardTypography] (fixed px + slack).
  static double get destinationTextBlockHeight =>
      ListingCardTypography.twoLineBlockHeight;

  static double get vehicleTextBlockHeight =>
      ListingCardTypography.vehicleTextBlockHeight;

  static double get tourTextBlockHeight =>
      ListingCardTypography.tourTextBlockHeight;
}
