import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/badges/status_badge.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';

/// Display data for a booking list card (customer or mitra).
class BookingCardData {
  const BookingCardData({
    required this.id,
    required this.status,
    required this.vehicleName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.subtitle,
  });

  final String id;
  final String status;
  final String vehicleName;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String? subtitle;

  String get shortId => '#${id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}';
}

/// Shared booking card for customer and mitra booking lists.
class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.data,
    this.onTap,
    this.footer,
    this.idOnLeft = false,
    super.key,
  });

  final BookingCardData data;
  final VoidCallback? onTap;
  final Widget? footer;
  final bool idOnLeft;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.all(AppSpacing.cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: idOnLeft
                ? [
                    Text(
                      data.shortId,
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.orange),
                    ),
                    BookingStatusBadge(status: data.status),
                  ]
                : [
                    BookingStatusBadge(status: data.status),
                    Text(
                      data.shortId,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                    ),
                  ],
          ),
          AppGap.md,
          Text(
            data.vehicleName.isNotEmpty ? data.vehicleName : 'Kendaraan',
            style: AppTextStyles.titleMedium,
          ),
          if (data.subtitle != null) ...[
            AppGap.xs,
            Text(data.subtitle!, style: AppTextStyles.bodySmall),
          ],
          SizedBox(height: data.subtitle != null ? 8.h : 4.h),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14.sp, color: AppColors.navy),
              AppGap.h(AppSpacing.xs),
              Expanded(
                child: Text(
                  '${data.startDate} - ${data.endDate}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Divider(height: idOnLeft ? 24.h : 1.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                idOnLeft ? 'Total Bayar' : 'Total Pembayaran',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                MoneyFormatter.rupiah(data.totalPrice),
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.teal),
              ),
              if (footer != null) ...[
                AppGap.md,
                Align(alignment: Alignment.centerRight, child: footer!),
              ],
            ],
          ),
        ],
      ),
    );

    final card = Container(
      margin: EdgeInsets.zero,
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (onTap == null) return card;

    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: card,
    );
  }
}
