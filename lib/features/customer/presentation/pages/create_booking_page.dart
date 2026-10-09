import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/di.dart';
import '../../../../config/routes.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/feedback/inline_alert_box.dart';
import '../../../../core/widgets/map/location_picker_page.dart';
import '../../data/customer_repository.dart';
import '../../data/models/address_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/payment_channel_model.dart';
import '../../data/models/voucher_model.dart';
import 'address_form_page.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/layout/sticky_price_bar.dart';
import '../widgets/cost_breakdown_card.dart';
import '../widgets/date_range_picker_button.dart';
import '../widgets/voucher_selector.dart';

class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  late final CustomerRepository _repository;
  late Future<List<PaymentChannelModel>> _channelsFuture;

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  String _packageType = 'BASIC';
  bool _isInsured = false;
  bool _useDelivery = false;
  AddressModel? _selectedAddress;
  LatLng? _deliveryLocation;
  String? _deliveryAddress;
  VoucherModel? _selectedVoucher;
  PaymentChannelModel? _selectedChannel;
  BookingCostEstimateModel? _estimate;
  BookingModel? _createdBooking;
  String? _message;
  bool _isLoadingEstimate = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<CustomerRepository>();
    _channelsFuture = _loadChannels();
    _calculate();
  }

  Future<List<PaymentChannelModel>> _loadChannels() async {
    final response = await _repository.getPaymentChannels();
    final channels = response.data ?? const <PaymentChannelModel>[];
    if (channels.isNotEmpty && mounted) {
      setState(() => _selectedChannel = channels.first);
    }
    return channels;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orange,
              onPrimary: AppColors.onDark,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _calculate();
    }
  }

  Future<void> _calculate() async {
    setState(() {
      _isLoadingEstimate = true;
      _message = null;
    });

    try {
      final response = _useDelivery && _selectedAddress?.id != null
          ? await _repository.calculateDelivery(
              vehicleId: widget.vehicleId,
              deliveryAddressId: _selectedAddress!.id,
              startDate: _formatDate(_startDate),
              endDate: _formatDate(_endDate),
              isInsured: _isInsured,
              packageType: _packageType,
              voucherCode: _selectedVoucher?.code,
            )
          : await _repository.calculateBooking(
              vehicleId: widget.vehicleId,
              startDate: _formatDate(_startDate),
              endDate: _formatDate(_endDate),
              withDelivery: _useDelivery,
              deliveryAddressId: _useDelivery ? _selectedAddress?.id : null,
              isInsured: _isInsured,
              packageType: _packageType,
              voucherCode: _selectedVoucher?.code,
              destinationLat: _useDelivery
                  ? (_selectedAddress?.latitude ?? _deliveryLocation?.latitude)
                  : null,
              destinationLng: _useDelivery
                  ? (_selectedAddress?.longitude ??
                        _deliveryLocation?.longitude)
                  : null,
            );
      setState(() => _estimate = response.data);
    } catch (error) {
      setState(
        () => _message = error is Failure ? error.message : error.toString(),
      );
    } finally {
      if (mounted) setState(() => _isLoadingEstimate = false);
    }
  }

  Future<void> _pickDeliveryLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );
    if (result != null) {
      setState(() {
        _deliveryLocation = result['latlng'] as LatLng;
        _deliveryAddress = result['address'] as String;
      });
      await _calculate();
    }
  }

  Future<void> _submit() async {
    final channel = _selectedChannel;
    if (channel == null) {
      setState(() => _message = 'Pilih metode pembayaran terlebih dahulu');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
      _createdBooking = null;
    });

    try {
      final response = await _repository.createBooking(
        vehicleId: widget.vehicleId,
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        paymentChannel: channel.code,
        withDelivery: _useDelivery,
        deliveryAddressId: _useDelivery ? _selectedAddress?.id : null,
        isInsured: _isInsured,
        packageType: _packageType,
        voucherCode: _selectedVoucher?.code,
        destinationLat: _useDelivery
            ? (_selectedAddress?.latitude ?? _deliveryLocation?.latitude)
            : null,
        destinationLng: _useDelivery
            ? (_selectedAddress?.longitude ?? _deliveryLocation?.longitude)
            : null,
        deliveryAddress: _useDelivery
            ? (_selectedAddress?.fullAddress ?? _deliveryAddress)
            : null,
      );
      setState(() {
        _createdBooking = response.data;
        _message = response.message;
      });
      final bookingId = response.data?.id;
      if (bookingId != null && bookingId.isNotEmpty) {
        AnalyticsService.instance.logPaymentInitiated(bookingId);
        if (!mounted) return;
        SnackbarUtils.showSuccess(context, 'Booking berhasil dibuat');
        context.push(AppRoutePaths.bookingDetail(bookingId));
      }
    } catch (error) {
      setState(
        () => _message = error is Failure ? error.message : error.toString(),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openPaymentUrl() async {
    final url = _createdBooking?.payment?.paymentUrl;
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _showVoucherSelector() async {
    final vouchers = await _repository.getAvailableVouchers();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VoucherSelector(
        vouchers: vouchers.data ?? [],
        selectedVoucher: _selectedVoucher,
        orderAmount: _estimate?.totalPrice ?? _estimate?.dailyPrice,
        onSelected: (voucher) async {
          setState(() => _selectedVoucher = voucher);
          await _calculate();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentUrl = _createdBooking?.payment?.paymentUrl;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: Text('Buat Booking')),
      resizeToAvoidBottomInset: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.page,
          AppSpacing.page,
          AppSpacing.page +
              bottomInset +
              (_createdBooking == null
                  ? scrollBottomInsetForStickyBar(context)
                  : 0),
        ),
        children: [
          Text('Tanggal sewa', style: AppTextStyles.titleMedium),
          AppGap.sectionTitleToContent,
          DateRangePickerButton(
            start: _formatDate(_startDate),
            end: _formatDate(_endDate),
            onTap: _pickDateRange,
          ),
          AppGap.section,
          Text('Paket', style: AppTextStyles.titleMedium),
          AppGap.sectionTitleToContent,
          SegmentedButton<String>(
            selected: {_packageType},
            segments: const [
              ButtonSegment(value: 'BASIC', label: Text('Basic')),
              ButtonSegment(value: 'WITH_DRIVER', label: Text('Driver')),
              ButtonSegment(value: 'ALL_IN', label: Text('All-in')),
            ],
            onSelectionChanged: (value) async {
              setState(() => _packageType = value.first);
              await _calculate();
            },
          ),
          SizedBox(height: AppSpacing.formGap),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Tambahkan asuransi', style: AppTextStyles.titleSmall),
            value: _isInsured,
            onChanged: (value) async {
              setState(() => _isInsured = value);
              await _calculate();
            },
          ),
          SizedBox(height: AppSpacing.formGap),
          _buildDeliveryOption(),
          SizedBox(height: AppSpacing.formGap),
          _buildVoucherSelector(),
          AppGap.lg,
          CostBreakdownCard(estimate: _estimate, isLoading: _isLoadingEstimate),
          AppGap.section,
          Text('Metode pembayaran', style: AppTextStyles.titleMedium),
          AppGap.sectionTitleToContent,
          FutureBuilder<List<PaymentChannelModel>>(
            future: _channelsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoadingView();
              }

              final channels = snapshot.data ?? const <PaymentChannelModel>[];
              if (channels.isEmpty) {
                return Text(
                  'Metode pembayaran belum tersedia',
                  style: AppTextStyles.bodySmall,
                );
              }

              return Column(
                children: channels
                    .map(
                      (channel) => RadioListTile<PaymentChannelModel>(
                        contentPadding: EdgeInsets.zero,
                        value: channel,
                        groupValue: _selectedChannel,
                        onChanged: (value) =>
                            setState(() => _selectedChannel = value),
                        title: Text(channel.name),
                        subtitle: Text(
                          '${channel.method} \u00b7 ${channel.code}',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          if (_message != null) ...[
            AppGap.lg,
            InlineAlertBox(
              message: _message!,
              isSuccess: _createdBooking != null,
            ),
          ],
          if (paymentUrl != null && paymentUrl.isNotEmpty) ...[
            AppGap.lg,
            OutlinedButton.icon(
              onPressed: _openPaymentUrl,
              icon: Icon(LucideIcons.externalLink),
              label: Text('Buka pembayaran'),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _createdBooking != null
          ? null
          : StickyPriceBar(
              priceLabel: 'Estimasi total',
              price: _estimate?.totalPrice != null
                  ? MoneyFormatter.rupiah(_estimate!.totalPrice!)
                  : '—',
              buttonLabel: _isSubmitting ? 'Memproses...' : 'Buat booking',
              isLoading: _isSubmitting,
              enabled: _selectedChannel != null && !_isSubmitting,
              onPressed: _selectedChannel == null || _isSubmitting
                  ? null
                  : _submit,
            ),
    );
  }

  Widget _buildDeliveryOption() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Antar ke Lokasi Saya', style: AppTextStyles.titleSmall),
          subtitle: const Text('Biaya pengantaran akan otomatis dihitung'),
          value: _useDelivery,
          onChanged: (value) async {
            setState(() {
              _useDelivery = value;
              if (!value) {
                _deliveryLocation = null;
                _deliveryAddress = null;
                _selectedAddress = null;
              }
            });
            if (value && _selectedAddress == null) {
              // Try to auto-select primary address
              final addrs = await _repository.getMyAddresses();
              final list = addrs.data ?? [];
              if (list.isNotEmpty && mounted) {
                final primary = list.firstWhere(
                  (a) => a.isPrimary,
                  orElse: () => list.first,
                );
                setState(() {
                  _selectedAddress = primary;
                  _deliveryAddress = primary.fullAddress;
                  if (primary.hasCoordinates) {
                    _deliveryLocation = LatLng(
                      primary.latitude!,
                      primary.longitude!,
                    );
                  }
                });
              }
            }
            await _calculate();
          },
        ),
        if (_useDelivery) ...[
          AppGap.titleToSubtitle,
          if (_selectedAddress != null)
            Container(
              padding: AppPadding.card,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.06),
                borderRadius: AppShapes.md,
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.mapPin, color: AppColors.teal, size: 20.sp),
                  AppGap.h(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAddress!.name,
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          _selectedAddress!.fullAddress,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!_selectedAddress!.hasCoordinates)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'Peringatan: Alamat ini belum memiliki titik GPS',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.critical,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _showAddressPickerBottomSheet,
                    child: const Text('Ganti'),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAddressPickerBottomSheet,
                    icon: const Icon(LucideIcons.mapPin),
                    label: const Text('Pilih Alamat'),
                  ),
                ),
                AppGap.h(AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDeliveryLocation,
                    icon: const Icon(LucideIcons.map),
                    label: Text(
                      _deliveryLocation == null ? 'Peta' : 'Ubah Peta',
                    ),
                  ),
                ),
              ],
            ),
            if (_deliveryAddress != null)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  _deliveryAddress!,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ],
    );
  }

  Future<void> _showAddressPickerBottomSheet() async {
    final addressesResponse = await _repository.getMyAddresses();
    final addresses = addressesResponse.data ?? [];

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.cardRadius),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, color: AppColors.primaryDeep),
                    AppGap.h(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Pilih Alamat Pengantaran',
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                if (addresses.isEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      'Belum ada alamat tersimpan. Silakan tambah alamat baru atau pilih dari peta.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ] else ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 280.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final addr = addresses[index];
                        final isSelected = _selectedAddress?.id == addr.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            isSelected
                                ? LucideIcons.circleDot
                                : LucideIcons.circle,
                            color: isSelected
                                ? AppColors.orange
                                : AppColors.textSecondary,
                          ),
                          title: Text(
                            addr.name,
                            style: AppTextStyles.titleSmall,
                          ),
                          subtitle: Text(
                            addr.fullAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: !addr.hasCoordinates
                              ? Tooltip(
                                  message: 'Perlu titik koordinat',
                                  child: Icon(
                                    LucideIcons.triangleAlert,
                                    color: AppColors.critical,
                                    size: 16.sp,
                                  ),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedAddress = addr;
                              _deliveryAddress = addr.fullAddress;
                              if (addr.hasCoordinates) {
                                _deliveryLocation = LatLng(
                                  addr.latitude!,
                                  addr.longitude!,
                                );
                              }
                            });
                            Navigator.pop(context);
                            _calculate();
                          },
                        );
                      },
                    ),
                  ),
                ],
                AppGap.sm,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final created = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressFormPage(),
                            ),
                          );
                          if (created == true) {
                            final updated = await _repository.getMyAddresses();
                            final list = updated.data ?? [];
                            if (list.isNotEmpty && mounted) {
                              final latest = list.last;
                              setState(() {
                                _selectedAddress = latest;
                                _deliveryAddress = latest.fullAddress;
                                if (latest.hasCoordinates) {
                                  _deliveryLocation = LatLng(
                                    latest.latitude!,
                                    latest.longitude!,
                                  );
                                }
                              });
                              await _calculate();
                            }
                          }
                        },
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Tambah Alamat'),
                      ),
                    ),
                    AppGap.h(AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickDeliveryLocation();
                        },
                        icon: const Icon(LucideIcons.map, size: 16),
                        label: const Text('Pilih di Peta'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoucherSelector() {
    return InkWell(
      onTap: _showVoucherSelector,
      child: Container(
        padding: AppPadding.list,
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.05),
          borderRadius: AppShapes.md,
          border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.ticket, color: AppColors.orange),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedVoucher != null
                        ? 'Voucher Terpasang'
                        : 'Gunakan Voucher',
                    style: AppTextStyles.titleSmall,
                  ),
                  Text(
                    _selectedVoucher != null
                        ? '${_selectedVoucher!.code} - ${_selectedVoucher!.name ?? ''}'
                        : 'Makin hemat dengan promo Travelindo',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16.sp,
              color: AppColors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
