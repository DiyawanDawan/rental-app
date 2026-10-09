import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/breakpoints.dart';
import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/text_styles.dart';
import '../../../config/theme_context.dart';
import '../interaction/animated_inkwell.dart';
import '../media/app_cached_network_image.dart';
import '../media/responsive_cover_image.dart';
import '../../utils/text_scale_utils.dart';
import '../text/overflow_safe.dart';
import '../layout/listing_card_layout.dart';
import '../layout/listing_card_metrics.dart';
import '../layout/listing_card_typography.dart';
import '../motion/app_hero.dart';

enum DestinationCardLayout { full, compact, listing }

/// Card destinasi wisata premium — reusable di Home, list, search.
///
/// **Token:** [AppColors], [AppSpacing], [AppShapes], [AppDecorations] via [AnimatedInkWell].
/// Tidak ada warna hardcoded — semua dari design system.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    required this.title,
    this.imageUrl,
    this.image,
    this.subtitle,
    this.location,
    this.badgeLabel = 'Destinasi Wisata',
    this.onTap,
    this.heroTag,
    this.margin,
    this.aspectRatio = AppShapes.destinationCardAspectRatio,
    this.layout = DestinationCardLayout.full,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final Widget? image;
  final String? subtitle;
  final String? location;
  final String badgeLabel;
  final VoidCallback? onTap;
  final Object? heroTag;
  final EdgeInsetsGeometry? margin;
  final double aspectRatio;
  final DestinationCardLayout layout;

  /// [childAspectRatio] grid — rasio foto & teks tetap (Airbnb-style).
  static double gridChildAspectRatio(double cellWidth) {
    return ListingCardMetrics.gridChildAspectRatio(
      cellWidth,
      textBlockHeight: ListingCardMetrics.destinationTextBlockHeight,
    );
  }

  /// Tinggi total card listing (gambar + teks) — untuk horizontal list.
  static double listingTotalHeight(double cardWidth) {
    return ListingCardMetrics.totalHeight(
      cardWidth,
      textBlockHeight: ListingCardMetrics.destinationTextBlockHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cs;

    if (layout == DestinationCardLayout.listing || layout == DestinationCardLayout.compact) {
      final listing = _buildListingCard(context, colors);
      if (layout == DestinationCardLayout.compact) {
        return SizedBox(width: AppBreakpoints.listingCardWidth, child: listing);
      }
      return listing;
    }

    Widget card = Container(
      margin: margin,
      decoration: AppDecorations.destinationFloatingCardOf(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _DestinationImage(
            imageUrl: imageUrl,
            image: image,
            aspectRatio: aspectRatio,
            heroTag: heroTag,
            useResponsiveRatio: aspectRatio == AppShapes.destinationCardAspectRatio,
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryBadge(label: badgeLabel),
                AppGap.verticalHeight8,
                SafeText(
                  title,
                  style: context.textTitleMedium,
                  maxLines: context.isLargeAccessibilityText ? 3 : 2,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  AppGap.titleToSubtitle,
                  SafeText(
                    subtitle!,
                    style: context.textBodySmall,
                    maxLines: context.isLargeAccessibilityText ? 3 : 2,
                  ),
                ],
                if (location != null && location!.isNotEmpty) ...[
                  AppGap.sectionTitleToContent,
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14.sp, color: colors.onSurfaceVariant),
                      AppGap.horizontalWidth4,
                      FlexibleText(
                        location!,
                        style: context.textTertiary,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = AnimatedInkWell(
        onTap: onTap,
        borderRadius: AppShapes.md,
        child: card,
      );
    }

    return card;
  }

  Widget _buildListingCard(BuildContext context, ColorScheme colors) {
    Widget card = ListingCardLayout(
      textBlockHeight: ListingCardMetrics.destinationTextBlockHeight,
      image: _DestinationImage(
        imageUrl: imageUrl,
        image: image,
        aspectRatio: AppShapes.listingCardAspectRatio,
        heroTag: heroTag,
        useResponsiveRatio: false,
      ),
      text: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListingCardTypography.line(
            height: ListingCardTypography.titleLineAllocated,
            child: SafeText(
              title,
              style: ListingCardTypography.title(context.textTitleSmall),
              maxLines: 1,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: ListingCardTypography.lineGap),
            ListingCardTypography.line(
              height: ListingCardTypography.bodyLineAllocated,
              child: SafeText(
                subtitle!,
                style: ListingCardTypography.body(
                  context.textBodySmall.copyWith(color: colors.onSurfaceVariant),
                ),
                maxLines: 1,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      card = AnimatedInkWell(
        onTap: onTap,
        borderRadius: AppShapes.md,
        child: card,
      );
    }

    return card;
  }
}

class _DestinationImage extends StatelessWidget {
  const _DestinationImage({
    required this.aspectRatio,
    this.imageUrl,
    this.image,
    this.heroTag,
    this.useResponsiveRatio = true,
  });

  final String? imageUrl;
  final Widget? image;
  final double aspectRatio;
  final Object? heroTag;
  final bool useResponsiveRatio;

  @override
  Widget build(BuildContext context) {
    final ratio = useResponsiveRatio
        ? ResponsiveImageFit.cardAspectRatio(context)
        : aspectRatio;
    final fit = ResponsiveImageFit.coverFit(context);

    Widget content;

    if (image != null) {
      content = AspectRatio(aspectRatio: ratio, child: image);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = AspectRatio(
        aspectRatio: ratio,
        child: AppCachedNetworkImage(
          imageUrl: imageUrl!,
          fit: fit,
          width: double.infinity,
          errorIcon: LucideIcons.mountain,
        ),
      );
    } else {
      content = AspectRatio(
        aspectRatio: ratio,
        child: const _ImageFallback(),
      );
    }

    if (heroTag != null) {
      content = AppHero(tag: heroTag!, child: content);
    }

    return content;
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(LucideIcons.mountain, size: 40.sp, color: colors.primary),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: ShapeDecoration(
        color: AppColors.tertiaryContainer,
        shape: RoundedSuperellipseBorder(borderRadius: AppShapes.xxs),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.tertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
