import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/decorations.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';

class HomeIntegrationCard extends StatelessWidget {
  const HomeIntegrationCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: onTap,
      enabled: onTap != null,
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCard(),
        clipBehavior: Clip.antiAlias,
        child: Padding(
        padding: AppPadding.list,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: AppShapes.sm,
              ),
              child: Icon(icon, color: AppColors.teal),
            ),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  AppGap.xs,
                  Text(description, style: AppTextStyles.bodySmall),
                  if (actionLabel != null && onTap != null) ...[
                    AppGap.md,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: onTap, child: Text(actionLabel!)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
