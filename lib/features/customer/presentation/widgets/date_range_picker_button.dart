import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';

/// Outlined button showing selected rental date range.
class DateRangePickerButton extends StatelessWidget {
  const DateRangePickerButton({
    required this.start,
    required this.end,
    required this.onTap,
    super.key,
  });

  final String start;
  final String end;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
        side: const BorderSide(color: AppColors.borderColor),
        shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.calendarDays, color: AppColors.orange),
          AppGap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Durasi Sewa', style: AppTextStyles.labelSmall),
                Text('$start  \u2192  $end', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 16.sp, color: AppColors.mediumGray),
        ],
      ),
    );
  }
}
