import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/di.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/widgets/layout/sticky_price_bar.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../application/customer_service.dart';
import '../../data/customer_repository.dart';
import '../../data/models/payment_channel_model.dart';
import '../../data/models/tour_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourBookingPage extends StatefulWidget {
  const TourBookingPage({
    required this.tourId,
    this.tour,
    super.key,
  });

  final String tourId;
  final TourPackageModel? tour;

  @override
  State<TourBookingPage> createState() => _TourBookingPageState();
}

class _TourBookingPageState extends State<TourBookingPage> {
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedPaymentChannel;
  late Future<TourPackageModel> _tourFuture;
  late Future<List<PaymentChannelModel>> _paymentChannelsFuture;

  @override
  void initState() {
    super.initState();
    _tourFuture = _loadTour();
    _paymentChannelsFuture = context.read<CustomerService>().getPaymentChannels();
  }

  Future<TourPackageModel> _loadTour() async {
    if (widget.tour != null) return widget.tour!;
    final response = await getIt<CustomerRepository>().getTourPackageById(widget.tourId);
    final tour = response.data;
    if (tour == null) {
      throw Failure(message: 'Paket wisata tidak ditemukan');
    }
    return tour;
  }

  void _reloadTour() => setState(() => _tourFuture = _loadTour());

  Future<void> _submit(TourPackageModel tour) async {
    if (_selectedPaymentChannel == null) return;

    final endDate = _startDate.add(Duration(days: tour.durationDays ?? 1));

    final success = await context.read<CustomerService>().bookTour(
      tourPackageId: tour.id,
      startDate: _startDate.toIso8601String().split('T')[0],
      endDate: endDate.toIso8601String().split('T')[0],
      paymentChannel: _selectedPaymentChannel!,
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Booking paket wisata berhasil!');
      context.go(AppRoutePaths.bookings);
    } else {
      SnackbarUtils.showError(context, 'Gagal melakukan booking wisata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Wisata')),
      body: FutureBuilder<TourPackageModel>(
        future: _tourFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            final error = snapshot.error;
            final message = error is Failure ? error.message : 'Paket wisata tidak ditemukan';
            return AppErrorState(
              title: 'Gagal memuat paket',
              message: message,
              onRetry: _reloadTour,
            );
          }

          final tour = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppPadding.screen,
                  children: [
                    Text(tour.title, style: AppTextStyles.titleLarge),
                    AppGap.lg,
                    ListTile(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 180)),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      leading: Icon(LucideIcons.calendar),
                      title: const Text('Tanggal Mulai'),
                      subtitle: Text(_startDate.toIso8601String().split('T')[0]),
                      trailing: Icon(Icons.edit, size: 16.sp),
                    ),
                    AppGap.v(AppSpacing.xxl),
                    Text('Pilih Metode Pembayaran', style: AppTextStyles.titleMedium),
                    AppGap.md,
                    FutureBuilder<List<PaymentChannelModel>>(
                      future: _paymentChannelsFuture,
                      builder: (context, channelsSnapshot) {
                        if (channelsSnapshot.connectionState == ConnectionState.waiting) {
                          return const AppLoadingView();
                        }
                        final channels = channelsSnapshot.data ?? [];
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
                    SizedBox(height: scrollBottomInsetForStickyBar(context)),
                  ],
                ),
              ),
              StickyPriceBar(
                price: MoneyFormatter.rupiah(tour.price),
                priceSuffix: '/ paket',
                buttonLabel: 'Bayar Sekarang',
                enabled: _selectedPaymentChannel != null,
                onPressed: _selectedPaymentChannel == null ? null : () => _submit(tour),
              ),
            ],
          );
        },
      ),
    );
  }
}
