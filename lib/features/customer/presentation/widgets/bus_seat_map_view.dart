import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/motion.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../data/models/travel_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusSeatMapView extends StatelessWidget {
  const BusSeatMapView({
    required this.seatMap,
    required this.selectedCodes,
    required this.onSeatTap,
    this.defaultPrice = 0,
    super.key,
  });

  final BusSeatMapModel seatMap;
  final Set<String> selectedCodes;
  final ValueChanged<SeatModel> onSeatTap;
  final double defaultPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DriverIndicator(),
        AppGap.lg,
        ...seatMap.rows.map((row) => _SeatRow(
              row: row,
              selectedCodes: selectedCodes,
              onSeatTap: onSeatTap,
              defaultPrice: defaultPrice,
            )),
      ],
    );
  }
}

class BusSeatLegend extends StatelessWidget {
  const BusSeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: const [
        _LegendItem(color: AppColors.lightGray, label: 'Tersedia'),
        _LegendItem(color: AppColors.orange, label: 'Dipilih'),
        _LegendItem(color: AppColors.seatOccupied, label: 'Terisi'),
        _LegendItem(color: AppColors.teal, label: 'VIP'),
        _LegendItem(color: AppColors.navyAlt, label: 'Jendela'),
      ],
    );
  }
}

class _DriverIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: AppShapes.sm,
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.circleUser, size: 20.sp, color: AppColors.navy),
          AppGap.xs,
          Text('Sopir', style: AppTextStyles.bodySmall.copyWith(color: AppColors.navy)),
        ],
      ),
    );
  }
}

class _SeatRow extends StatelessWidget {
  const _SeatRow({
    required this.row,
    required this.selectedCodes,
    required this.onSeatTap,
    required this.defaultPrice,
  });

  final BusSeatMapRowModel row;
  final Set<String> selectedCodes;
  final ValueChanged<SeatModel> onSeatTap;
  final double defaultPrice;

  @override
  Widget build(BuildContext context) {
    final seats = row.seats;
    if (seats.isEmpty) return const SizedBox.shrink();

    final leftCount = (seats.length / 2).ceil();
    final left = seats.take(leftCount).toList();
    final right = seats.skip(leftCount).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 28.w,
            child: Text(row.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: left.map((s) => _SeatTile(
                    seat: s,
                    isSelected: selectedCodes.contains(s.code),
                    onTap: () => onSeatTap(s),
                    defaultPrice: defaultPrice,
                  )).toList(),
            ),
          ),
          AppGap.h(AppSpacing.xxl),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: right.map((s) => _SeatTile(
                    seat: s,
                    isSelected: selectedCodes.contains(s.code),
                    onTap: () => onSeatTap(s),
                    defaultPrice: defaultPrice,
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.seat,
    required this.isSelected,
    required this.onTap,
    required this.defaultPrice,
  });

  final SeatModel seat;
  final bool isSelected;
  final VoidCallback onTap;
  final double defaultPrice;

  Color get _baseColor {
    if (!seat.isAvailable) return AppColors.seatOccupied;
    if (isSelected) return AppColors.orange;
    switch (seat.tier) {
      case SeatTier.vip:
        return AppColors.teal.withValues(alpha: 0.35);
      case SeatTier.window:
        return AppColors.navyAlt.withValues(alpha: 0.25);
      case SeatTier.regular:
        return AppColors.lightGray.withValues(alpha: 0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: GestureDetector(
        onTap: seat.isAvailable ? onTap : null,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.enter,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.enter,
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _baseColor,
              borderRadius: AppShapes.sm,
              border: Border.all(
                color: isSelected ? AppColors.orange : AppColors.lightGray,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                seat.code,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.onDark : AppColors.navy,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(color: color, borderRadius: AppShapes.xxs),
        ),
        AppGap.h(AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
