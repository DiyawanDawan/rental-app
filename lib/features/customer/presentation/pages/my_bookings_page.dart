import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/feedback/shimmer_loading.dart';

import '../../../../app/di.dart';
import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/services/rental_location_share_service.dart';
import '../../application/customer_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/motion/animated_filter_switcher.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../data/models/booking_model.dart';
import '../widgets/booking_card.dart';
import '../../../../core/router/router_query_mixin.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with RouterQueryMixin {
  String? _statusFilter;
  Timer? _locationRefreshTimer;

  static const _filters = <String?, String>{
    null: 'Semua',
    'active': 'Aktif',
    'completed': 'Selesai',
    'cancelled': 'Batal',
  };

  static const _activeStatuses = {'PENDING', 'APPROVED', 'PAID', 'CONFIRMED', 'HANDOVER', 'RETURNED'};
  static const _cancelledStatuses = {'CANCELLED', 'REJECTED'};

  static const _filterKeys = {'active', 'completed', 'cancelled'};

  @override
  void initState() {
    super.initState();
    _locationRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerService>().loadMyBookings();
    });
  }

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    final status = queryParameters['status'];
    if (status != null && _filterKeys.contains(status)) {
      _statusFilter = status;
    }
  }

  @override
  void dispose() {
    _locationRefreshTimer?.cancel();
    super.dispose();
  }

  Widget? _buildLocationShareWarning(List<BookingModel> bookings) {
    final hasHandover = bookings.any((b) => !b.isShuttle && b.status == 'HANDOVER');
    final error = getIt<RentalLocationShareService>().lastError;
    if (!hasHandover || error == null || error.isEmpty) return null;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: 0.08),
        borderRadius: AppShapes.sm,
        border: Border.all(color: AppColors.critical.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.triangleAlert, color: AppColors.critical, size: 18.sp),
          AppGap.h(AppSpacing.sm),
          Expanded(child: Text(error, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  List<BookingModel> _filtered(List<BookingModel> bookings) {
    return bookings.where((b) {
      final status = b.status ?? '';
      switch (_statusFilter) {
        case 'active':
          return _activeStatuses.contains(status);
        case 'completed':
          return status == 'COMPLETED';
        case 'cancelled':
          return _cancelledStatuses.contains(status);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Column(
        children: [
          SizedBox(
            height: 48.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
              children: _filters.entries
                  .map(
                    (e) => Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(e.value),
                        selected: _statusFilter == e.key,
                        onSelected: (_) => setState(() => _statusFilter = e.key),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Consumer<CustomerService>(
            builder: (context, service, _) => _buildLocationShareWarning(service.myBookings) ?? const SizedBox.shrink(),
          ),
          Expanded(
            child: Consumer<CustomerService>(
              builder: (context, service, child) {
                if (service.status == CustomerStatus.loading && service.myBookings.isEmpty) {
                  return const AppShimmerLoading(itemCount: 4);
                }

                if (service.myBookings.isEmpty) {
                  return AppEmptyState(
                    icon: LucideIcons.calendarX,
                    title: 'Belum ada pesanan',
                    message: 'Anda belum melakukan pemesanan kendaraan apa pun.',
                    actionLabel: 'Cari Kendaraan Sekarang',
                    onAction: () => context.go(AppRoutePaths.vehicles),
                  );
                }

                final bookings = _filtered(service.myBookings);
                if (bookings.isEmpty) {
                  return AppEmptyState(
                    icon: LucideIcons.slidersHorizontal,
                    title: 'Tidak ada pesanan',
                    message: 'Tidak ada pesanan dengan filter ini.',
                    actionLabel: 'Tampilkan Semua',
                    onAction: () => setState(() => _statusFilter = null),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => service.loadMyBookings(),
                  child: AnimatedFilterSwitcher(
                    filterKey: _statusFilter ?? 'all',
                    child: ListView.separated(
                      padding: AppPadding.list,
                      itemCount: bookings.length,
                      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.listGap),
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return StaggeredListItem(
                          index: index,
                          child: BookingCard(
                        data: BookingCardData(
                          id: booking.id,
                          status: booking.status ?? '-',
                          vehicleName: booking.isShuttle
                              ? (booking.schedule?.vehicleName ?? booking.vehicle?.name ?? 'Travel Bus')
                              : (booking.vehicle?.name ?? 'Kendaraan'),
                          startDate: booking.isShuttle
                              ? (booking.schedule?.departureTime ?? booking.startDate ?? '-')
                              : (booking.startDate ?? '-'),
                          endDate: booking.isShuttle
                              ? (booking.schedule?.arrivalTime ?? booking.endDate ?? '-')
                              : (booking.endDate ?? '-'),
                          totalPrice: booking.totalPrice ?? 0,
                          subtitle: booking.isShuttle && booking.schedule?.route != null
                              ? '${booking.schedule!.route!.origin} \u2192 ${booking.schedule!.route!.destination}'
                              : null,
                        ),
                        onTap: () => context.push(AppRoutePaths.bookingDetail(booking.id)),
                        footer: ['PENDING', 'APPROVED', 'PAID', 'CONFIRMED'].contains(booking.status)
                            ? OutlinedButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Batalkan Pesanan'),
                                      content: const Text('Yakin ingin membatalkan pesanan ini?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Ya, Batalkan'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && context.mounted) {
                                    final ok = await service.cancelBooking(booking.id);
                                    if (context.mounted) {
                                      SnackbarUtils.showSuccess(
                                        context,
                                        ok ? 'Pesanan dibatalkan' : 'Gagal membatalkan pesanan',
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.critical),
                                child: const Text('Batal'),
                              )
                            : null,
                        ),
                      );
                    },
                    ),
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
