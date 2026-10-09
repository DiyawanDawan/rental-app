import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/motion/animated_filter_switcher.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../application/customer_service.dart';
import '../../data/models/travel_model.dart';
import '../widgets/travel_schedule_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TravelScheduleListPage extends StatefulWidget {
  const TravelScheduleListPage({
    required this.origin,
    required this.destination,
    required this.date,
    this.originRegencyId,
    this.destinationRegencyId,
    super.key,
  });

  final String origin;
  final String destination;
  final String date;
  final String? originRegencyId;
  final String? destinationRegencyId;

  @override
  State<TravelScheduleListPage> createState() => _TravelScheduleListPageState();
}

class _TravelScheduleListPageState extends State<TravelScheduleListPage> {
  late Future<List<TravelScheduleModel>> _future;
  String _sort = 'departure';

  static const _sortLabels = {
    'departure': 'Berangkat paling awal',
    'price_asc': 'Harga termurah',
    'price_desc': 'Harga termahal',
    'seats': 'Kursi tersedia',
  };

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerService>().searchTravel(
          date: widget.date,
          originRegencyId: widget.originRegencyId,
          destinationRegencyId: widget.destinationRegencyId,
        );
  }

  List<TravelScheduleModel> _sorted(List<TravelScheduleModel> schedules) {
    final copy = List<TravelScheduleModel>.from(schedules);
    switch (_sort) {
      case 'price_asc':
        copy.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        copy.sort((a, b) => b.price.compareTo(a.price));
      case 'seats':
        copy.sort((a, b) => (b.availableSeats ?? 0).compareTo(a.availableSeats ?? 0));
      default:
        copy.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }
    return copy;
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Urutkan jadwal', style: AppTextStyles.titleMedium),
              SizedBox(height: AppSpacing.sm),
              ..._sortLabels.entries.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _sort == e.key ? LucideIcons.circleCheck : LucideIcons.circle,
                    color: _sort == e.key ? AppColors.orange : AppColors.lightGray,
                    size: 20.sp,
                  ),
                  title: Text(e.value),
                  onTap: () {
                    setState(() => _sort = e.key);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRoute = widget.origin.isNotEmpty && widget.destination.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasRoute ? '${widget.origin} \u2192 ${widget.destination}' : 'Semua jadwal',
              style: AppTextStyles.titleSmall,
            ),
            Text(widget.date, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onDarkMuted)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _sortLabels[_sort] ?? 'Urutan',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openSortSheet,
                  icon: Icon(LucideIcons.slidersHorizontal, size: 16.sp),
                  label: const Text('Urutkan'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TravelScheduleModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppShimmerLoading(itemCount: 4);
                }

                final schedules = _sorted(snapshot.data ?? []);
                if (schedules.isEmpty) {
                  return const Center(child: Text('Tidak ada jadwal tersedia untuk rute ini.'));
                }

                final cheapestPrice = schedules.map((s) => s.price).reduce((a, b) => a < b ? a : b);

                return AnimatedFilterSwitcher(
                  filterKey: _sort,
                  child: ListView.separated(
                    padding: AppPadding.list,
                    itemCount: schedules.length,
                    separatorBuilder: (context, index) => SizedBox(height: AppSpacing.listGap),
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return StaggeredListItem(
                        index: index,
                        child: TravelScheduleCard(
                          schedule: schedule,
                          showCheapestBadge: _sort == 'price_asc' && schedule.price == cheapestPrice,
                          showEarliestBadge: _sort == 'departure' && index == 0,
                          showSeatsBadge: _sort == 'seats' && index == 0,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
