import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../data/models/travel_model.dart';
import '../utils/travel_journey_utils.dart';
import 'travel_route_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TravelJourneySummary extends StatelessWidget {
  const TravelJourneySummary({
    required this.schedule,
    this.seats = const [],
    this.showMap = true,
    this.showProgress = true,
    this.compact = false,
    super.key,
  });

  final TravelScheduleModel schedule;
  final List<String> seats;
  final bool showMap;
  final bool showProgress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final route = schedule.route;
    final phase = TravelJourneyUtils.resolvePhase(
      scheduleStatus: schedule.status,
      departureAt: schedule.departureAt,
      arrivalAt: schedule.arrivalAt,
    );

    return Container(
      margin: compact ? EdgeInsets.zero : null,
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: compact ? AppPadding.card : AppPadding.list,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact)
              Text('Ringkasan Perjalanan', style: AppTextStyles.titleSmall),
            if (!compact) AppGap.md,
            if (route != null) _RouteHeader(route: route) else _FallbackRoute(schedule: schedule),
            AppGap.md,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (route != null) _InfoChip(icon: LucideIcons.route, label: route.distanceText),
                if (route != null) _InfoChip(icon: LucideIcons.clock, label: route.durationText),
                _InfoChip(icon: LucideIcons.bus, label: schedule.vehicleName ?? 'Bus Travel'),
                if (seats.isNotEmpty)
                  _InfoChip(icon: LucideIcons.armchair, label: 'Kursi ${seats.join(', ')}'),
              ],
            ),
            AppGap.md,
            Row(
              children: [
                Expanded(child: _TimeBlock(label: 'Berangkat', time: schedule.departureTime)),
                Icon(LucideIcons.chevronRight, size: 16.sp, color: AppColors.lightGray),
                Expanded(child: _TimeBlock(label: 'Tiba', time: schedule.arrivalTime, alignEnd: true)),
              ],
            ),
            if (showProgress) ...[
              AppGap.lg,
              _JourneyProgress(phase: phase),
            ],
            if (showMap && route != null) ...[
              AppGap.lg,
              TravelRouteMap(route: route),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({required this.route});
  final TravelRouteModel route;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.circle, size: 10.sp, color: AppColors.orange),
                  AppGap.h(AppSpacing.sm),
                  Expanded(child: Text(route.origin, style: AppTextStyles.titleSmall)),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs, top: AppSpacing.xs, bottom: AppSpacing.xs),
                child: Container(width: 2.w, height: 20.h, color: AppColors.lightGray),
              ),
              Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 12.sp, color: AppColors.teal),
                  AppGap.h(AppSpacing.sm),
                  Expanded(child: Text(route.destination, style: AppTextStyles.titleSmall)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FallbackRoute extends StatelessWidget {
  const _FallbackRoute({required this.schedule});
  final TravelScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${schedule.departureTime} \u2013 ${schedule.arrivalTime}',
      style: AppTextStyles.titleSmall,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: AppShapes.lg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.navy),
          AppGap.h(AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    this.alignEnd = false,
  });

  final String label;
  final String time;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
        Text(time, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

class _JourneyProgress extends StatelessWidget {
  const _JourneyProgress({required this.phase});
  final TravelJourneyPhase phase;

  @override
  Widget build(BuildContext context) {
    if (phase == TravelJourneyPhase.cancelled) {
      return Text(
        TravelJourneyUtils.phaseLabel(phase),
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.critical),
      );
    }

    final activeIndex = TravelJourneyUtils.phaseIndex(phase);
    const steps = ['Menunggu', 'Dalam Perjalanan', 'Tiba'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TravelJourneyUtils.phaseLabel(phase),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppGap.md,
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIndex = i ~/ 2;
              return Expanded(
                child: Container(
                  height: AppSpacing.xxs,
                  color: stepIndex < activeIndex ? AppColors.teal : AppColors.lightGray.withValues(alpha: 0.4),
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final isActive = stepIndex <= activeIndex;
            return Column(
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.teal : AppColors.lightGray.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    stepIndex == 0
                        ? LucideIcons.clock
                        : stepIndex == 1
                            ? LucideIcons.bus
                            : LucideIcons.flag,
                    size: 12.sp,
                    color: isActive ? AppColors.onDark : AppColors.navy,
                  ),
                ),
                AppGap.xs,
                Text(
                  steps[stepIndex],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 9.sp,
                    color: isActive ? AppColors.navy : AppColors.lightGray,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
