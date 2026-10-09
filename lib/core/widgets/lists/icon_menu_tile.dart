import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/decorations.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import '../../../config/shapes.dart';
import '../interaction/animated_inkwell.dart';

/// Menu list tile with icon in colored container.
class IconMenuTile extends StatelessWidget {
  const IconMenuTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.cs;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedInkWell(
        onTap: onTap,
        borderRadius: AppShapes.md,
        child: Container(
          decoration: AppDecorations.floatingCardOf(context),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppShapes.sm,
                ),
                child: Icon(icon, color: colors.primary, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTitleSmall),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(subtitle!, style: context.textBodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20.sp, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
