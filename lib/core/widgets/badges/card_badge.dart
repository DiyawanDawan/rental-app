import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

enum CardBadgeVariant { promo, nearest, trust, info }

/// Badge overlay untuk card list — promo, geo, trust.
class CardBadge extends StatelessWidget {
  const CardBadge({
    required this.label,
    this.variant = CardBadgeVariant.promo,
    this.icon,
    super.key,
  });

  const CardBadge.nearest({String label = 'Terdekat', super.key})
      : label = label,
        variant = CardBadgeVariant.nearest,
        icon = LucideIcons.mapPin;

  const CardBadge.promo({required this.label, super.key})
      : variant = CardBadgeVariant.promo,
        icon = null;

  const CardBadge.trust({String label = 'Terverifikasi', super.key})
      : label = label,
        variant = CardBadgeVariant.trust,
        icon = LucideIcons.badgeCheck;

  const CardBadge.info({required this.label, super.key})
      : variant = CardBadgeVariant.info,
        icon = null;

  final String label;
  final CardBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      CardBadgeVariant.promo => (AppColors.orange, AppColors.onDark, null),
      CardBadgeVariant.nearest => (Colors.transparent, AppColors.orange, AppColors.orange),
      CardBadgeVariant.trust => (AppColors.verifiedBadgeBg, AppColors.verifiedBadge, AppColors.sageGreen.withValues(alpha: 0.4)),
      CardBadgeVariant.info => (AppColors.teal.withValues(alpha: 0.12), AppColors.teal, null),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppShapes.md,
        border: border != null ? Border.all(color: border, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.sp, color: fg),
            AppGap.h(AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Threshold jarak untuk badge "Terdekat" (km).
const kNearestBadgeMaxKm = 20.0;

bool showNearestBadge(double? distanceKm) =>
    distanceKm != null && distanceKm <= kNearestBadgeMaxKm;

/// Badge overlay khusus card listing 172px — **fixed px** (selaras [ListingCardTypography]).
class ListingCardBadge extends StatelessWidget {
  const ListingCardBadge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.borderColor,
    super.key,
  });

  factory ListingCardBadge.promo({required String label, Key? key}) {
    return ListingCardBadge(
      key: key,
      label: label,
      background: AppColors.orange,
      foreground: AppColors.onDark,
    );
  }

  factory ListingCardBadge.trust({Key? key}) {
    return ListingCardBadge(
      key: key,
      label: 'Terverifikasi',
      background: AppColors.verifiedBadgeBg,
      foreground: AppColors.verifiedBadge,
      icon: LucideIcons.badgeCheck,
      borderColor: AppColors.sageGreen.withValues(alpha: 0.4),
    );
  }

  factory ListingCardBadge.nearest({Key? key}) {
    return ListingCardBadge(
      key: key,
      label: 'Terdekat',
      background: Colors.transparent,
      foreground: AppColors.orange,
      icon: LucideIcons.mapPin,
      borderColor: AppColors.orange,
    );
  }

  static const double overlayInset = 4;
  static const double fontSize = 9;
  static const double iconSize = 9;
  static const double hPad = 4;
  static const double vPad = 2;

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: foreground),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
