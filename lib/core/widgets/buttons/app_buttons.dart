import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/spacing.dart';
import '../../../core/theme/component_themes.dart';

/// Primary CTA — orange, full-width default, loading state bawaan. default, loading state bawaan.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: AppComponentThemes.primaryButton(fullWidth: fullWidth),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: AppColors.surface,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18.sp),
                      AppGap.h(AppSpacing.sm),
                      Text(label),
                    ],
                  )
                : Text(label),
      ),
    );
  }
}

/// Secondary — outline orange..
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AppComponentThemes.secondaryButton(fullWidth: fullWidth),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 18.sp), AppGap.h(AppSpacing.sm), Text(label)],
              )
            : Text(label),
      ),
    );
  }
}

/// Icon button konsisten — favorite, share, back overlay..
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.filled = true,
    this.color,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      style: filled
          ? AppComponentThemes.iconButtonFilled()
          : IconButton.styleFrom(
              foregroundColor: color ?? AppColors.navy,
              minimumSize: Size(44.w, 44.h),
            ),
      tooltip: tooltip,
    );
  }
}
