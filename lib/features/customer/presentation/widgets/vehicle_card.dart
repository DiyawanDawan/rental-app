import '../../../../core/widgets/media/app_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/utils/image_cache_url.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/badges/service_provider_label.dart';
import '../../../../core/widgets/badges/card_badge.dart';
import '../../../../core/widgets/buttons/listing_favorite_button.dart';
import '../../../../core/widgets/layout/listing_card_layout.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_card_typography.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../data/models/vehicle_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum VehicleCardLayout { full, listing, compact }

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    required this.vehicle,
    required this.onTap,
    this.layout = VehicleCardLayout.full,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.enableHero = true,
    super.key,
  });

  final VehicleModel vehicle;
  final VoidCallback onTap;
  final VehicleCardLayout layout;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool enableHero;

  Future<void> _handleTap(BuildContext context) async {
    final photoUrl = vehicle.primaryPhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await precacheNetworkImageUrl(
        context,
        cacheBustImageUrl(photoUrl, version: vehicle.id),
      );
    }
    if (!context.mounted) return;
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    if (layout == VehicleCardLayout.listing || layout == VehicleCardLayout.compact) {
      final listing = _buildListingCard(context);
      if (layout == VehicleCardLayout.compact) {
        return SizedBox(width: AppBreakpoints.listingCardWidth, child: listing);
      }
      return listing;
    }

    return AnimatedInkWell(
      onTap: () => _handleTap(context),
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCardOf(context),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: AppShapes.listImageAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _VehiclePhoto(vehicle: vehicle, enableHero: enableHero),
                  if (showNearestBadge(vehicle.distanceKm))
                    Positioned(
                      top: AppSpacing.sm,
                      right: onFavoriteTap != null ? 40 : AppSpacing.sm,
                      child: const CardBadge.nearest(),
                    ),
                  if (onFavoriteTap != null)
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: ListingFavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteTap,
                        size: ListingFavoriteButton.fullIconSize,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.name, style: context.textTitleMedium),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    [vehicle.brand, vehicle.model, vehicle.transmission].whereType<String>().join(' • '),
                    style: context.textCardMeta,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${MoneyFormatter.rupiah(vehicle.pricePerDay)}/hari',
                          style: context.textCardPrice,
                        ),
                      ),
                      Icon(LucideIcons.star, size: 16.sp, color: AppColors.warning),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        (vehicle.ratingAvg ?? 0).toStringAsFixed(1),
                        style: context.textCardMeta,
                      ),
                    ],
                  ),
                  if (vehicle.mitra != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    ServiceProviderLabel.fromMitra(
                      storeName: vehicle.mitra!.storeName,
                      isVerified: vehicle.mitra!.isVerified,
                    ),
                  ] else ...[
                    SizedBox(height: AppSpacing.sm),
                    const ServiceProviderLabel(name: 'Mitra Travelindo'),
                  ],
                  if (vehicle.distanceKm != null) ...[
                    AppGap.xs,
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 14.sp, color: context.cs.secondary),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          '${vehicle.distanceKm!.toStringAsFixed(1)} km',
                          style: context.textCardMeta.copyWith(color: context.cs.secondary),
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

  Widget _buildListingCard(BuildContext context) {
    final colors = context.cs;
    final meta = [vehicle.brand, vehicle.model].whereType<String>().join(' · ');

    return AnimatedInkWell(
      onTap: () => _handleTap(context),
      borderRadius: AppDecorations.listingCardRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      showPressedShadow: false,
      child: ListingCardLayout(
        textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
        image: Stack(
          fit: StackFit.expand,
          children: [
            _VehiclePhoto(vehicle: vehicle, enableHero: enableHero),
            if (onFavoriteTap != null)
              Positioned(
                top: ListingCardBadge.overlayInset,
                right: ListingCardBadge.overlayInset,
                child: ListingFavoriteButton(
                  isFavorite: isFavorite,
                  onTap: onFavoriteTap,
                ),
              ),
          ],
        ),
        text: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListingCardTypography.line(
              height: ListingCardTypography.titleLineAllocated,
              child: Text(
                vehicle.name,
                style: ListingCardTypography.title(context.textTitleSmall),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (meta.isNotEmpty) ...[
              SizedBox(height: ListingCardTypography.lineGap),
              ListingCardTypography.line(
                height: ListingCardTypography.bodyLineAllocated,
                child: Text(
                  meta,
                  style: ListingCardTypography.body(
                    context.textBodySmall.copyWith(color: colors.onSurfaceVariant),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            SizedBox(height: ListingCardTypography.lineGap),
            ListingCardTypography.line(
              height: ListingCardTypography.actionRowAllocated,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${MoneyFormatter.rupiah(vehicle.pricePerDay)}/hari',
                      style: ListingCardTypography.price(context.textCardPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    LucideIcons.star,
                    size: ListingCardTypography.metaIconSize,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: ListingCardTypography.lineGap),
                  Text(
                    (vehicle.ratingAvg ?? 0).toStringAsFixed(1),
                    style: ListingCardTypography.body(context.textCardMeta),
                  ),
                ],
              ),
            ),
            SizedBox(height: ListingCardTypography.providerLeadGap),
            ListingCardTypography.line(
              height: ListingCardTypography.providerLineAllocated,
              child: ServiceProviderLabel.fromMitra(
                storeName: vehicle.mitra?.storeName,
                isVerified: vehicle.mitra?.isVerified ?? false,
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehiclePhoto extends StatelessWidget {
  const _VehiclePhoto({required this.vehicle, this.enableHero = true});

  final VehicleModel vehicle;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (vehicle.primaryPhotoUrl == null) {
      image = Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(LucideIcons.car, size: 40.sp, color: Theme.of(context).colorScheme.primary),
      );
    } else {
      image = AppCachedNetworkImage(
        imageUrl: cacheBustImageUrl(vehicle.primaryPhotoUrl!, version: vehicle.id),
        fit: BoxFit.cover,
        errorIcon: LucideIcons.car,
      );
    }

    if (!enableHero || vehicle.id == 'loading') return image;

    return AppHero(
      tag: AppHeroTags.vehiclePhoto(vehicle.id),
      child: image,
    );
  }
}
