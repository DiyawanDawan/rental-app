import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/customer_service.dart';
import '../../data/models/payment_channel_model.dart';
import '../../data/models/travel_model.dart';
import '../utils/travel_seat_utils.dart';
import '../widgets/travel_journey_summary.dart';
import '../../../../core/widgets/layout/sticky_price_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TravelBookingCheckoutPage extends StatefulWidget {
  const TravelBookingCheckoutPage({
    required this.scheduleId,
    required this.selectedSeats,
    super.key,
  });

  final String scheduleId;
  final List<String> selectedSeats;

  @override
  State<TravelBookingCheckoutPage> createState() => _TravelBookingCheckoutPageState();
}

class _TravelBookingCheckoutPageState extends State<TravelBookingCheckoutPage> {
  late Future<List<PaymentChannelModel>> _paymentChannelsFuture;
  late Future<TravelScheduleModel?> _scheduleFuture;
  late Future<TravelSeatAvailabilityModel?> _seatsFuture;
  String? _selectedPaymentChannel;

  @override
  void initState() {
    super.initState();
    final service = context.read<CustomerService>();
    _paymentChannelsFuture = service.getPaymentChannels();
    _scheduleFuture = service.getTravelScheduleById(widget.scheduleId);
    _seatsFuture = service.getTravelSeats(widget.scheduleId);
  }

  Future<void> _submit() async {
    if (_selectedPaymentChannel == null) return;

    final service = context.read<CustomerService>();
    final success = await service.bookTravel(
      scheduleId: widget.scheduleId,
      seats: widget.selectedSeats,
      paymentChannel: _selectedPaymentChannel!,
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Booking travel berhasil!');
      context.go(AppRoutePaths.bookings);
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal melakukan booking travel');
    }
  }

  List<SeatModel> _resolveSelectedSeats(TravelSeatAvailabilityModel? availability) {
    if (availability == null) return [];
    final all = TravelSeatUtils.resolveSeats(availability);
    return all.where((s) => widget.selectedSeats.contains(s.code)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Travel')),
      body: FutureBuilder(
        future: Future.wait([_scheduleFuture, _seatsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final schedule = (snapshot.data?[0] as TravelScheduleModel?);
          final availability = snapshot.data?[1] as TravelSeatAvailabilityModel?;
          final selectedSeatModels = _resolveSelectedSeats(availability);
          final pricePerSeat = availability?.pricePerSeat ?? schedule?.price ?? 0;
          final subtotal = selectedSeatModels.isNotEmpty
              ? TravelSeatUtils.totalPrice(selectedSeatModels, pricePerSeat)
              : pricePerSeat * widget.selectedSeats.length;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppPadding.screen,
                  children: [
                Text('Ringkasan Pesanan', style: AppTextStyles.titleMedium),
                AppGap.sectionTitleToContent,
                if (schedule != null)
                  TravelJourneySummary(
                    schedule: schedule,
                    seats: widget.selectedSeats,
                    showProgress: false,
                    compact: true,
                  )
                else
                  Card(
                    child: Padding(
                      padding: AppPadding.list,
                      child: Column(
                        children: [
                          _buildRow('Jumlah Kursi', '${widget.selectedSeats.length} Kursi'),
                          _buildRow('Kursi Terpilih', widget.selectedSeats.join(', ')),
                        ],
                      ),
                    ),
                  ),
                if (schedule != null && selectedSeatModels.length > 1) ...[
                  SizedBox(height: AppSpacing.listGap),
                  Card(
                    child: Padding(
                      padding: AppPadding.list,
                      child: Column(
                        children: [
                          ...selectedSeatModels.map(
                            (s) => _buildRow(
                              'Kursi ${s.code} (${s.tier.label})',
                              MoneyFormatter.rupiah(s.effectivePrice(pricePerSeat)),
                            ),
                          ),
                          const Divider(height: 24),
                          _buildRow('Subtotal', MoneyFormatter.rupiah(subtotal), bold: true),
                        ],
                      ),
                    ),
                  ),
                ] else if (schedule != null) ...[
                  SizedBox(height: AppSpacing.listGap),
                  Card(
                    child: Padding(
                      padding: AppPadding.list,
                      child: _buildRow('Subtotal', MoneyFormatter.rupiah(subtotal), bold: true),
                    ),
                  ),
                ],
                    AppGap.section,
                    Text('Pilih Metode Pembayaran', style: AppTextStyles.titleMedium),
                    AppGap.sectionTitleToContent,
                    FutureBuilder<List<PaymentChannelModel>>(
                      future: _paymentChannelsFuture,
                      builder: (context, channelSnapshot) {
                        if (channelSnapshot.connectionState == ConnectionState.waiting) {
                          return const AppLoadingView();
                        }
                        final channels = channelSnapshot.data ?? [];
                        return Column(
                          children: channels.map((channel) {
                            return RadioListTile<String>(
                              title: Text(channel.name),
                              value: channel.code,
                              groupValue: _selectedPaymentChannel,
                              onChanged: (val) => setState(() => _selectedPaymentChannel = val),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              StickyPriceBar(
                priceLabel: 'Total bayar',
                price: MoneyFormatter.rupiah(subtotal),
                buttonLabel: 'Bayar sekarang',
                enabled: _selectedPaymentChannel != null,
                onPressed: _selectedPaymentChannel == null ? null : _submit,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          AppGap.h(AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: bold ? AppColors.teal : null,
              ),
              textAlign: TextAlign.end,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
