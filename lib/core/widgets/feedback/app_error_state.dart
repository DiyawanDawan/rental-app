import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';

/// Reusable error/empty-with-retry state.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
    this.icon = LucideIcons.circleAlert,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42.sp, color: AppColors.mediumGray),
            AppGap.md,
            Text(title, style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            AppGap.xs,
            Text(message, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            AppGap.lg,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(LucideIcons.refreshCw),
              label: Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
