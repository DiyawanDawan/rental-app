import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

enum VerifiedBadgeStyle { chip, banner }

/// Verified / eco badge in chip or full-width banner style.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    this.label = 'Terverifikasi',
    this.style = VerifiedBadgeStyle.chip,
    super.key,
  });

  const VerifiedBadge.banner({
    this.label = 'Toko Terverifikasi',
    super.key,
  }) : style = VerifiedBadgeStyle.banner;

  final String label;
  final VerifiedBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    if (style == VerifiedBadgeStyle.banner) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.verifiedBadgeBg,
          borderRadius: AppShapes.sm,
          border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.badgeCheck, color: AppColors.verifiedBadge, size: 20.sp),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.verifiedBadge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.verifiedBadgeBg,
        borderRadius: AppShapes.xxs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.badgeCheck, size: 12.sp, color: AppColors.verifiedBadge),
          AppGap.h(AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.verifiedBadge,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar with verified check or KYC prompt overlay.
class VerifiedAvatar extends StatelessWidget {
  const VerifiedAvatar({
    required this.isVerified,
    required this.child,
    this.radius = 50,
    this.onUnverifiedTap,
    super.key,
  });

  final bool isVerified;
  final Widget child;
  final double radius;
  final VoidCallback? onUnverifiedTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          right: 0,
          child: isVerified
              ? Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: const BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.check, size: 16.sp, color: AppColors.onDark),
                )
              : GestureDetector(
                  onTap: onUnverifiedTap,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.camera, size: 16.sp, color: AppColors.onDark),
                  ),
                ),
        ),
      ],
    );
  }
}
