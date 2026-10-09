import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/customer_service.dart';
import '../../data/models/vehicle_blocked_date_model.dart';

/// Monthly availability calendar for a vehicle — gaya Airbnb (mobile-first).
class VehicleAvailabilityCalendar extends StatefulWidget {
  const VehicleAvailabilityCalendar({
    required this.vehicleId,
    this.embedded = false,
    super.key,
  });

  final String vehicleId;
  final bool embedded;

  @override
  State<VehicleAvailabilityCalendar> createState() => _VehicleAvailabilityCalendarState();
}

class _VehicleAvailabilityCalendarState extends State<VehicleAvailabilityCalendar> {
  late Future<List<VehicleBlockedDateModel>> _availabilityFuture;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _reloadAvailability();
  }

  void _reloadAvailability() {
    _availabilityFuture = context.read<CustomerService>().getVehicleAvailability(widget.vehicleId);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _reloadAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.embedded)
          Text('Ketersediaan unit', style: context.textTitleMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.embedded)
              Text(
                '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: context.textTitleSmall,
              )
            else
              const SizedBox.shrink(),
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: Icon(Icons.chevron_left, size: 22.sp, color: context.cs.onSurface),
                  visualDensity: VisualDensity.compact,
                ),
                if (!widget.embedded)
                  Text(
                    '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                    style: context.textTitleSmall,
                  ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: Icon(Icons.chevron_right, size: 22.sp, color: context.cs.onSurface),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        AppGap.sm,
        const _WeekdayHeader(),
        AppGap.xs,
        FutureBuilder<List<VehicleBlockedDateModel>>(
          future: _availabilityFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingView();
            }
            return _CalendarGrid(
              focusedMonth: _focusedMonth,
              unavailableDates: snapshot.data ?? [],
            );
          },
        ),
        AppGap.md,
        Row(
          children: [
            _Legend(
              color: context.cs.onSurface.withValues(alpha: 0.12),
              label: 'Tidak tersedia',
            ),
            AppGap.h(AppSpacing.lg),
            _Legend(
              color: context.cs.surface,
              label: 'Tersedia',
              border: true,
            ),
          ],
        ),
      ],
    );
  }

  static String _monthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[month - 1];
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _labels = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: context.textBodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.border = false});

  final Color color;
  final String label;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border ? Border.all(color: cs.outline.withValues(alpha: 0.5)) : null,
          ),
        ),
        AppGap.h(AppSpacing.xs),
        Text(label, style: context.textBodySmall),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.focusedMonth, required this.unavailableDates});

  final DateTime focusedMonth;
  final List<VehicleBlockedDateModel> unavailableDates;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final daysInMonth = DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final weekdayOfFirstDay = DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;
    final offset = weekdayOfFirstDay % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: 0,
        childAspectRatio: 1.1,
      ),
      itemCount: daysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();

        final day = index - offset + 1;
        final date = DateTime(focusedMonth.year, focusedMonth.month, day);
        final dateStr = date.toIso8601String().split('T')[0];
        final isUnavailable = unavailableDates.any((b) => b.dateString == dateStr);
        final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
        final isDisabled = isUnavailable || isPast;

        return Center(
          child: GestureDetector(
            onTap: isUnavailable
                ? () {
                    final entry = unavailableDates.firstWhere((b) => b.dateString == dateStr);
                    if (entry.reason != null && entry.reason!.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tidak tersedia: ${entry.reason}')),
                      );
                    }
                  }
                : null,
            child: Text(
              day.toString(),
              style: context.textBodySmall.copyWith(
                color: isDisabled
                    ? cs.onSurfaceVariant.withValues(alpha: 0.45)
                    : cs.onSurface,
                fontWeight: isDisabled ? FontWeight.normal : FontWeight.w600,
                decoration: isUnavailable && !isPast ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
