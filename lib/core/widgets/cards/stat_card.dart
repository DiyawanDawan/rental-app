import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/decorations.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

/// Icon stat card for dashboard grids.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.floatingCard(),
      child: Padding(
        padding: AppPadding.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            AppGap.sm,
            Text(value, style: AppTextStyles.titleLarge),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Bordered stat box for admin reports.
class StatBox extends StatelessWidget {
  const StatBox({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.screen,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppShapes.md,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          AppGap.xs,
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
