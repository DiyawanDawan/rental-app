import '../../../../core/widgets/media/app_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/motion.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../core/widgets/media/responsive_cover_image.dart';
import '../../../customer/data/models/banner_model.dart';

/// Card promo premium di Home — gradient, soft shadow, bounce tap.
class PromoCard extends StatelessWidget {
  const PromoCard({
    required this.title,
    this.subtitle,
    this.badgeLabel = 'Promo Spesial',
    this.ctaLabel = 'Lihat detail',
    this.imageUrl,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String badgeLabel;
  final String ctaLabel;
  final String? imageUrl;
  final VoidCallback? onTap;

  factory PromoCard.fromBanner(BannerModel banner, {VoidCallback? onTap}) {
    return PromoCard(
      title: banner.title,
      subtitle: banner.subtitle,
      imageUrl: banner.imageUrl,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.lg,
      scale: AppMotion.cardPressScale,
      splashColor: AppColors.onDark.withValues(alpha: 0.2),
      highlightColor: AppColors.onDark.withValues(alpha: 0.1),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
          final card = _PromoCardBody(
            title: title,
            subtitle: subtitle,
            badgeLabel: badgeLabel,
            ctaLabel: ctaLabel,
            imageUrl: imageUrl,
          );
          if (hasBoundedHeight) {
            return SizedBox(height: constraints.maxHeight, child: card);
          }
          return AspectRatio(
            aspectRatio: ResponsiveImageFit.bannerAspectRatio(context),
            child: card,
          );
        },
      ),
    );
  }
}

class _PromoCardBody extends StatelessWidget {
  const _PromoCardBody({
    required this.title,
    required this.badgeLabel,
    required this.ctaLabel,
    this.subtitle,
    this.imageUrl,
  });

  final String title;
  final String? subtitle;
  final String badgeLabel;
  final String ctaLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.promoCard(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Positioned.fill(
              child: AppCachedNetworkImage(
                imageUrl: imageUrl!,
                fit: ResponsiveImageFit.bannerFit(context),
                color: AppColors.overlay.withValues(alpha: 0.35),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(gradient: AppDecorations.imageScrimGradient),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromoBadge(label: badgeLabel),
                const Spacer(),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onDark,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onDarkMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: AppSpacing.sm),
                _PromoCtaChip(label: ctaLabel),
              ],
            ),
          ),
          Positioned(
            right: -24.w,
            top: -24.h,
            child: _DecorativeOrb(
              size: 120.w,
              color: AppColors.onDark.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            right: 32.w,
            bottom: -40.h,
            child: _DecorativeOrb(
              size: 80.w,
              color: AppColors.accentWarm.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBadge extends StatelessWidget {
  const _PromoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.onDark.withValues(alpha: 0.18),
        borderRadius: AppShapes.pill,
        border: Border.all(color: AppColors.onDark.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 12.sp, color: AppColors.onDark),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(color: AppColors.onDark),
          ),
        ],
      ),
    );
  }
}

class _PromoCtaChip extends StatelessWidget {
  const _PromoCtaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.onDark.withValues(alpha: 0.2),
        borderRadius: AppShapes.pill,
        border: AppDecorations.borderGlow(color: AppColors.onDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Icon(LucideIcons.arrowRight, size: 14.sp, color: AppColors.onDark),
        ],
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
