import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';

class HomeQuickAccessCard extends StatelessWidget {
  const HomeQuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      showPressedShadow: false,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.cardPad),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppShapes.md,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }
}
