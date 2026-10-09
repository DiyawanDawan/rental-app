import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';

/// Reusable empty state: icon, title, message, optional CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.sp, color: AppColors.lightGray),
            AppGap.lg,
            Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
            AppGap.sm,
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              AppGap.v(AppSpacing.xxl),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
