import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';
import '../../utils/money_formatter.dart';

enum BalanceCardStyle { navy, tealGradient, tealOutline }

/// Hero balance card used in wallet, mitra dashboard, and earnings.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.title,
    required this.balance,
    this.style = BalanceCardStyle.navy,
    this.actions,
    this.footer,
    this.onWithdraw,
    super.key,
  });

  final String title;
  final double balance;
  final BalanceCardStyle style;
  final List<BalanceCardAction>? actions;
  final Widget? footer;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case BalanceCardStyle.navy:
        return _NavyCard(
          title: title,
          balance: balance,
          actions: actions ?? const [],
        );
      case BalanceCardStyle.tealGradient:
        return _TealGradientCard(
          title: title,
          balance: balance,
          footer: footer,
        );
      case BalanceCardStyle.tealOutline:
        return _TealOutlineCard(
          title: title,
          balance: balance,
          onWithdraw: onWithdraw,
        );
    }
  }
}

class BalanceCardAction {
  const BalanceCardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _NavyCard extends StatelessWidget {
  const _NavyCard({
    required this.title,
    required this.balance,
    required this.actions,
  });

  final String title;
  final double balance;
  final List<BalanceCardAction> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: AppShapes.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted)),
          AppGap.sm,
          Text(
            MoneyFormatter.rupiah(balance),
            style: AppTextStyles.displayMedium.copyWith(color: AppColors.onDark),
          ),
          if (actions.isNotEmpty) ...[
            AppGap.section,
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) AppGap.h(AppSpacing.lg),
                  Expanded(child: _ActionButton(action: actions[i])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final BalanceCardAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.onDarkSubtle,
          borderRadius: AppShapes.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: AppColors.onDark, size: 18.sp),
            AppGap.h(AppSpacing.sm),
            Flexible(
              child: Text(
                action.label,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.onDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TealGradientCard extends StatelessWidget {
  const _TealGradientCard({
    required this.title,
    required this.balance,
    this.footer,
  });

  final String title;
  final double balance;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: AppShapes.lg,
        boxShadow: AppDecorations.softShadow(tint: AppColors.teal, opacity: 0.3, blur: 10, offsetY: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted)),
          AppGap.xs,
          Text(
            MoneyFormatter.rupiah(balance),
            style: AppTextStyles.displayMedium.copyWith(color: AppColors.onDark),
          ),
          if (footer != null) ...[
            Divider(color: AppColors.onDarkSubtle, height: 32.h),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _TealOutlineCard extends StatelessWidget {
  const _TealOutlineCard({
    required this.title,
    required this.balance,
    this.onWithdraw,
  });

  final String title;
  final double balance;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.teal.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.teal, width: 0.5.w),
        borderRadius: AppShapes.md,
      ),
      child: Padding(
        padding: AppPadding.list,
        child: Row(
          children: [
            Icon(LucideIcons.wallet, color: AppColors.teal, size: 32.sp),
            AppGap.h(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySmall),
                  Text(
                    MoneyFormatter.rupiah(balance),
                    style: AppTextStyles.headlineSmall.copyWith(color: AppColors.teal),
                  ),
                ],
              ),
            ),
            if (onWithdraw != null)
              TextButton(onPressed: onWithdraw, child: Text('Withdraw')),
          ],
        ),
      ),
    );
  }
}
