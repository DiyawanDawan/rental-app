import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/shapes.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../utils/money_formatter.dart';

enum TransactionDirection { credit, debit, payout }

/// Shared transaction list tile for wallet and mitra earnings.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.direction,
    this.categoryLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final double amount;
  final TransactionDirection direction;
  final String? categoryLabel;

  factory TransactionTile.wallet({
    required String title,
    required String subtitle,
    required double amount,
    required bool isCredit,
  }) {
    return TransactionTile(
      title: title,
      subtitle: subtitle,
      amount: amount,
      direction: isCredit ? TransactionDirection.credit : TransactionDirection.debit,
    );
  }

  factory TransactionTile.earning({
    required String title,
    required String subtitle,
    required double amount,
    required bool isPayout,
  }) {
    return TransactionTile(
      title: title,
      subtitle: subtitle,
      amount: amount,
      direction: isPayout ? TransactionDirection.payout : TransactionDirection.credit,
    );
  }

  Color get _color => switch (direction) {
        TransactionDirection.credit => AppColors.success,
        TransactionDirection.debit => AppColors.critical,
        TransactionDirection.payout => AppColors.orange,
      };

  IconData get _icon => switch (direction) {
        TransactionDirection.credit => LucideIcons.arrowDownLeft,
        TransactionDirection.debit => LucideIcons.arrowUpRight,
        TransactionDirection.payout => LucideIcons.arrowUpRight,
      };

  String get _sign => switch (direction) {
        TransactionDirection.credit => '+',
        TransactionDirection.debit => '-',
        TransactionDirection.payout => '-',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: AppDecorations.floatingCard(),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: _color.withValues(alpha: 0.1),
          child: Icon(_icon, color: _color, size: 18.sp),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
            if (categoryLabel != null) ...[
              AppGap.xs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: AppShapes.sm,
                ),
                child: Text(
                  categoryLabel!,
                  style: AppTextStyles.labelSmall.copyWith(color: _color, fontSize: 10.sp),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: Text(
          '$_sign${MoneyFormatter.rupiah(amount)}',
          style: AppTextStyles.titleSmall.copyWith(color: _color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
