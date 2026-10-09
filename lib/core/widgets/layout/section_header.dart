import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';

/// Section title with optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.titleStyle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TextStyle? titleStyle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: onAction != null
              ? InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: titleStyle ?? context.textTitleMedium,
                        ),
                      ),
                      if (trailing != null) ...[
                        AppGap.h(AppSpacing.xs),
                        trailing!,
                      ],
                    ],
                  ),
                )
              : Text(title, style: titleStyle ?? context.textTitleMedium),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: context.textLabelLarge),
          ),
      ],
    );
  }
}
