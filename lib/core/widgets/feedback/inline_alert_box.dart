import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

/// Inline success/error alert box for forms and booking flows.
class InlineAlertBox extends StatelessWidget {
  const InlineAlertBox({
    required this.message,
    this.isSuccess = false,
    super.key,
  });

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.critical;
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppShapes.sm,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(message, style: AppTextStyles.bodySmall.copyWith(color: color)),
    );
  }
}
