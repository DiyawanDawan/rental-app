import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/decorations.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/layout/key_value_row.dart';
import '../../data/models/booking_model.dart';

/// Booking cost estimate breakdown card.
class CostBreakdownCard extends StatelessWidget {
  const CostBreakdownCard({
    required this.estimate,
    required this.isLoading,
    super.key,
  });

  final BookingCostEstimateModel? estimate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        decoration: AppDecorations.floatingCard(),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 120.h,
          child: const AppLoadingView(),
        ),
      );
    }

    return Container(
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimasi biaya', style: AppTextStyles.titleMedium),
            AppGap.md,
            KeyValueRow(label: 'Durasi', value: '${estimate?.days ?? '-'} hari', isBold: true),
            KeyValueRow(label: 'Rental', value: MoneyFormatter.rupiah(estimate?.rentalPrice), isBold: true),
            if (estimate?.deliveryFee != null && estimate!.deliveryFee! > 0)
              KeyValueRow(label: 'Biaya Antar', value: MoneyFormatter.rupiah(estimate?.deliveryFee), isBold: true),
            KeyValueRow(label: 'Asuransi', value: MoneyFormatter.rupiah(estimate?.insuranceAmount), isBold: true),
            KeyValueRow(label: 'Deposit', value: MoneyFormatter.rupiah(estimate?.depositAmount), isBold: true),
            const Divider(),
            KeyValueRow(
              label: 'Total',
              value: MoneyFormatter.rupiah(estimate?.totalPrice),
              isBold: true,
              valueStyle: AppTextStyles.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
