import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/badges/card_badge.dart';
import '../../../../core/widgets/badges/service_provider_label.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../data/models/travel_model.dart';

/// Kartu jadwal travel — dipakai di halaman list & preview home search.
class TravelScheduleCard extends StatelessWidget {
  const TravelScheduleCard({
    required this.schedule,
    this.showCheapestBadge = false,
    this.showEarliestBadge = false,
    this.showSeatsBadge = false,
    super.key,
  });

  final TravelScheduleModel schedule;
  final bool showCheapestBadge;
  final bool showEarliestBadge;
  final bool showSeatsBadge;

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: () => context.push(AppRoutePaths.travelScheduleSeats(schedule.id)),
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCardOf(context),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.vehicleName ?? 'Bus Travel',
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      if (showCheapestBadge) const CardBadge.promo(label: 'Termurah'),
                      if (showEarliestBadge) const CardBadge.nearest(label: 'Terawal'),
                      if (showSeatsBadge) const CardBadge.info(label: 'Kursi banyak'),
                      const CardBadge.info(label: 'Share'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              ServiceProviderLabel.fromMitra(
                storeName: schedule.mitraStoreName,
                alternateName: schedule.mitraAlternateName,
                isVerified: schedule.mitraIsVerified,
              ),
              SizedBox(height: AppSpacing.sm),
              if (schedule.route != null)
                Text(
                  '${schedule.route!.origin} \u2192 ${schedule.route!.destination}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.navy),
                ),
              if (schedule.route != null) AppGap.xs,
              if (schedule.route != null)
                Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    Text(
                      schedule.route!.durationText,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                    ),
                    Text(
                      schedule.route!.distanceText,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                    ),
                  ],
                ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${MoneyFormatter.rupiah(schedule.price)}/kursi',
                    style: AppTextStyles.cardPrice.copyWith(color: AppColors.teal),
                  ),
                  Text(
                    'Sisa ${schedule.availableSeats ?? schedule.seatingCapacity ?? 0} kursi',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.orange),
                  ),
                ],
              ),
              AppGap.md,
              Row(
                children: [
                  TravelScheduleTimePoint(time: schedule.departureTime, label: 'Berangkat'),
                  Expanded(child: Divider(indent: 12, endIndent: 12)),
                  Icon(LucideIcons.bus, size: 16.sp, color: AppColors.navy),
                  Expanded(child: Divider(indent: 12, endIndent: 12)),
                  TravelScheduleTimePoint(time: schedule.arrivalTime, label: 'Tiba'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelScheduleTimePoint extends StatelessWidget {
  const TravelScheduleTimePoint({
    required this.time,
    required this.label,
    super.key,
  });

  final String time;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(time, style: AppTextStyles.titleSmall),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
      ],
    );
  }
}
