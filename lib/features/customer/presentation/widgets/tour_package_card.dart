import '../../../../core/widgets/media/app_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/decorations.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/badges/service_provider_label.dart';
import '../../../../core/widgets/badges/card_badge.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../core/widgets/layout/listing_card_layout.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_card_typography.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../data/models/tour_model.dart';
import '../../data/models/tourist_destination_model.dart';
import 'destination_media_gallery.dart';

enum TourPackageCardLayout { full, listing, compact }

/// Unified tour package card for home preview and list page.
class TourPackageCard extends StatelessWidget {
  const TourPackageCard({
    required this.tour,
    this.layout = TourPackageCardLayout.full,
    this.showRecommendedBadge = false,
    this.enableHero = true,
    this.listingVariantIndex,
    super.key,
  });

  final TourPackageModel tour;
  final TourPackageCardLayout layout;
  final bool showRecommendedBadge;
  final bool enableHero;

  /// Variasi kolase foto antar card di grid/list.
  final int? listingVariantIndex;

  Future<void> _openDetail(BuildContext context) async {
    final urls = tour.galleryUrls;
    await precacheNetworkImageUrl(context, urls.isNotEmpty ? urls.first : tour.imageUrl);
    if (!context.mounted) return;
    context.push('/tours/${tour.id}');
  }

  int get _collageVariantIndex => listingVariantIndex ?? tour.id.hashCode.abs();

  bool get _usePhotoCollage => tour.galleryUrls.length > 1;

  Widget _buildTourVisual(BuildContext context, {double? height}) {
    if (_usePhotoCollage) {
      return DestinationCardPhotoCollage(
        media: [
          for (final url in tour.galleryUrls)
            DestinationMediaModel(url: url),
        ],
        maxCells: 4,
        variantIndex: _collageVariantIndex,
      );
    }

    return _TourImage(tour: tour, height: height, enableHero: enableHero);
  }

  @override
  Widget build(BuildContext context) {
    final metaIconColor = context.cs.onSurfaceVariant;

    if (layout == TourPackageCardLayout.listing || layout == TourPackageCardLayout.compact) {
      final listing = _buildListingCard(context, metaIconColor);
      if (layout == TourPackageCardLayout.compact) {
        return SizedBox(width: AppBreakpoints.listingCardWidth, child: listing);
      }
      return listing;
    }

    return AnimatedInkWell(
      onTap: () => _openDetail(context),
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCardOf(context),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildTourVisual(context, height: 160.h),
                if (showRecommendedBadge)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: const CardBadge.promo(label: 'Rekomendasi'),
                  ),
                if (showNearestBadge(tour.distanceKm))
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: const CardBadge.nearest(),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(tour.title, style: context.textTitleMedium)),
                      Text(MoneyFormatter.rupiah(tour.price), style: context.textCardPrice),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14.sp, color: metaIconColor),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          tour.distanceKm != null
                              ? '${tour.location ?? '-'} • ${tour.distanceKm!.toStringAsFixed(1)} km'
                              : tour.location ?? '-',
                          style: context.textCardMeta,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(LucideIcons.clock, size: 14.sp, color: metaIconColor),
                      SizedBox(width: AppSpacing.xs),
                      Text(tour.durationLabel, style: context.textCardMeta),
                    ],
                  ),
                  AppGap.xs,
                  ServiceProviderLabel.fromMitra(
                    storeName: tour.mitra?.storeName,
                    alternateName: tour.mitra?.name,
                    isVerified: tour.mitra?.isVerified ?? false,
                  ),
                  if (tour.destinations.length > 1) ...[
                    AppGap.xs,
                    Row(
                      children: [
                        Icon(LucideIcons.route, size: 14.sp, color: metaIconColor),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          '${tour.destinations.length} destinasi',
                          style: context.textCardMeta,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, Color metaIconColor) {
    return AnimatedInkWell(
      onTap: () => _openDetail(context),
      borderRadius: AppDecorations.listingCardRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      showPressedShadow: false,
      child: ListingCardLayout(
        textBlockHeight: ListingCardMetrics.tourTextBlockHeight,
        image: Stack(
          fit: StackFit.expand,
          children: [
            _buildTourVisual(context),
            if (showRecommendedBadge)
              Positioned(
                top: ListingCardBadge.overlayInset,
                left: ListingCardBadge.overlayInset,
                child: ListingCardBadge.promo(label: 'Rekomendasi'),
              ),
            if (showNearestBadge(tour.distanceKm))
              Positioned(
                top: ListingCardBadge.overlayInset,
                right: ListingCardBadge.overlayInset,
                child: ListingCardBadge.nearest(),
              ),
          ],
        ),
        text: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListingCardTypography.line(
              height: ListingCardTypography.titleLineAllocated,
              child: Text(
                tour.title,
                style: ListingCardTypography.title(context.textTitleSmall),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: ListingCardTypography.lineGap),
            ListingCardTypography.line(
              height: ListingCardTypography.priceLineAllocated,
              child: Text(
                MoneyFormatter.rupiah(tour.price),
                style: ListingCardTypography.price(context.textCardPrice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: ListingCardTypography.lineGap),
            ListingCardTypography.line(
              height: ListingCardTypography.actionRowAllocated,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: ListingCardTypography.metaIconSize,
                    color: metaIconColor,
                  ),
                  SizedBox(width: ListingCardTypography.lineGap),
                  Text(
                    tour.durationLabel,
                    style: ListingCardTypography.body(context.textCardMeta),
                  ),
                  if (tour.location != null) ...[
                    SizedBox(width: ListingCardTypography.lineGap),
                    Text('·', style: ListingCardTypography.body(context.textCardMeta)),
                    SizedBox(width: ListingCardTypography.lineGap),
                    Expanded(
                      child: Text(
                        tour.location!,
                        style: ListingCardTypography.body(context.textCardMeta),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: ListingCardTypography.providerLeadGap),
            ListingCardTypography.line(
              height: ListingCardTypography.providerLineAllocated,
              child: ServiceProviderLabel.fromMitra(
                storeName: tour.mitra?.storeName,
                alternateName: tour.mitra?.name,
                isVerified: tour.mitra?.isVerified ?? false,
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourImage extends StatelessWidget {
  const _TourImage({
    required this.tour,
    this.height,
    this.enableHero = true,
  });

  final TourPackageModel tour;
  final double? height;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (tour.imageUrl != null) {
      image = AppCachedNetworkImage(
        imageUrl: tour.imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorIcon: LucideIcons.treePalm,
      );
    } else {
      image = ColoredBox(
        color: context.cs.surfaceContainerHighest,
        child: height == null
            ? Center(child: Icon(LucideIcons.treePalm, color: context.cs.primary))
            : Icon(LucideIcons.treePalm, color: context.cs.primary),
      );
    }

    if (!enableHero || tour.id == 'loading') return image;

    return AppHero(
      tag: AppHeroTags.tourImage(tour.id),
      child: image,
    );
  }
}
