import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../application/customer_service.dart';
import '../../data/models/travel_model.dart';
import '../utils/travel_seat_utils.dart';
import '../widgets/bus_seat_map_view.dart';
import '../widgets/travel_journey_summary.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeatPickerPage extends StatefulWidget {
  const SeatPickerPage({required this.scheduleId, super.key});

  final String scheduleId;

  @override
  State<SeatPickerPage> createState() => _SeatPickerPageState();
}

class _SeatPickerPageState extends State<SeatPickerPage> {
  late Future<TravelSeatAvailabilityModel?> _future;
  late Future<TravelScheduleModel?> _scheduleFuture;
  final Set<String> _selectedSeats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  void _loadSeats() {
    final service = context.read<CustomerService>();
    setState(() {
      _errorMessage = null;
      _future = service.getTravelSeats(widget.scheduleId);
      _scheduleFuture = service.getTravelScheduleById(widget.scheduleId);
    });
  }

  void _toggleSeat(SeatModel seat) {
    setState(() {
      if (_selectedSeats.contains(seat.code)) {
        _selectedSeats.remove(seat.code);
      } else {
        _selectedSeats.add(seat.code);
      }
    });
  }

  void _goToCheckout(TravelSeatAvailabilityModel availability) {
    final seatsQuery = _selectedSeats.map((s) => 'seats=${Uri.encodeComponent(s)}').join('&');
    context.push('/travel/checkout?scheduleId=${widget.scheduleId}&$seatsQuery');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kursi')),
      body: FutureBuilder<TravelSeatAvailabilityModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final availability = snapshot.data;
          if (availability == null) {
            return _ErrorState(
              message: _errorMessage ?? context.read<CustomerService>().message ?? 'Gagal memuat data kursi.',
              onRetry: _loadSeats,
            );
          }

          final seatMap = TravelSeatUtils.resolveSeatMap(availability);
          final allSeats = TravelSeatUtils.resolveSeats(availability);

          if (allSeats.isEmpty) {
            return _EmptyState(onRetry: _loadSeats);
          }

          final selectedModels = allSeats.where((s) => _selectedSeats.contains(s.code)).toList();
          final subtotal = TravelSeatUtils.totalPrice(selectedModels, availability.pricePerSeat);

          return Column(
            children: [
              FutureBuilder<TravelScheduleModel?>(
                future: _scheduleFuture,
                builder: (context, scheduleSnapshot) {
                  final schedule = scheduleSnapshot.data;
                  if (schedule == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
                    child: TravelJourneySummary(
                      schedule: schedule,
                      showMap: true,
                      showProgress: false,
                      compact: true,
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.page, AppSpacing.page, AppSpacing.sm),
                child: const BusSeatLegend(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
                  child: BusSeatMapView(
                    seatMap: seatMap,
                    selectedCodes: _selectedSeats,
                    defaultPrice: availability.pricePerSeat,
                    onSeatTap: _toggleSeat,
                  ),
                ),
              ),
              if (_selectedSeats.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
                  color: AppColors.navy.withValues(alpha: 0.05),
                  child: Text(
                    '${_selectedSeats.length} kursi · ${MoneyFormatter.rupiah(subtotal)}',
                    style: AppTextStyles.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<TravelSeatAvailabilityModel?>(
        future: _future,
        builder: (context, snapshot) {
          final availability = snapshot.data;
          return SafeArea(
            child: Padding(
              padding: AppPadding.list,
              child: ElevatedButton(
                onPressed: _selectedSeats.isEmpty || availability == null
                    ? null
                    : () => _goToCheckout(availability),
                child: Text('Booking ${_selectedSeats.length} Kursi'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.bus, size: 48.sp, color: AppColors.lightGray),
            AppGap.lg,
            Text(
              'Denah kursi belum tersedia',
              style: AppTextStyles.titleSmall,
              textAlign: TextAlign.center,
            ),
            AppGap.titleToSubtitle,
            Text(
              'Mitra belum mengatur layout kursi untuk armada ini.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
              textAlign: TextAlign.center,
            ),
            AppGap.section,
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 48.sp, color: AppColors.orange),
            AppGap.lg,
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            AppGap.section,
            ElevatedButton(onPressed: onRetry, child: const Text('Muat Ulang')),
          ],
        ),
      ),
    );
  }
}
