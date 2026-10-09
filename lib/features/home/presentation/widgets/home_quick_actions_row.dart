import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';

class HomeQuickActionsRow extends StatelessWidget {
  const HomeQuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _ActionItem(icon: LucideIcons.car, label: 'Rental', onTap: () => context.push(AppRoutePaths.vehicles)),
          AppGap.h(AppSpacing.md),
          _ActionItem(icon: LucideIcons.bus, label: 'Travel', onTap: () => context.push(AppRoutePaths.travelSearch)),
          AppGap.h(AppSpacing.md),
          _ActionItem(icon: LucideIcons.mapPinned, label: 'Destinasi', onTap: () => context.push(AppRoutePaths.destinations)),
          AppGap.h(AppSpacing.md),
          _ActionItem(icon: LucideIcons.treePalm, label: 'Paket', onTap: () => context.push(AppRoutePaths.tourPackages)),
          AppGap.h(AppSpacing.md),
          _ActionItem(icon: LucideIcons.layoutGrid, label: 'Blog', onTap: () => context.push(AppRoutePaths.blogs)),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.orange, size: 22),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textCaption.copyWith(fontSize: 11, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
