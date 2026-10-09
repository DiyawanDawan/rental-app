import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';

/// Review summary with star distribution bars for mitra dashboard.
class MitraReviewSummaryCard extends StatelessWidget {
  const MitraReviewSummaryCard({required this.summary, super.key});

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final avgRating = (summary['averageRating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (summary['totalReviews'] as num?)?.toInt() ?? 0;
    final distribution = (summary['distribution'] as Map<String, dynamic>?) ?? {};

    return Container(
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppPadding.list,
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.rating, fontSize: 48.sp),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      LucideIcons.star,
                      size: 16.sp,
                      color: index < avgRating.floor() ? AppColors.rating : AppColors.statusUnavailable,
                    ),
                  ),
                ),
                AppGap.xs,
                Text('$totalReviews Review', style: AppTextStyles.bodySmall),
              ],
            ),
            AppGap.h(AppSpacing.xxl),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final count = (distribution[star.toString()] as num?)?.toInt() ?? 0;
                  final percent = totalReviews > 0 ? count / totalReviews : 0.0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        Text(star.toString(), style: AppTextStyles.bodySmall),
                        AppGap.h(AppSpacing.sm),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: AppColors.lightGray,
                            color: AppColors.rating,
                            minHeight: AppSpacing.xs,
                            borderRadius: AppShapes.xxs,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
