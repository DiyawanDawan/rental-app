import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/di.dart';
import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/network/multipart_upload_helper.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/services/rental_location_share_service.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/layout/key_value_row.dart';
import '../../../../config/decorations.dart';
import '../../../../core/widgets/motion/content_reveal.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../../../chat/application/chat_service.dart';
import '../../application/customer_service.dart';
import '../../data/models/booking_model.dart';
import '../widgets/travel_journey_summary.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({required this.bookingId, super.key});

  final String bookingId;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  BookingModel? _booking;
  bool _isLoading = true;
  Timer? _locationRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBooking();
    _locationRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _booking?.status == 'HANDOVER') setState(() {});
    });
  }

  @override
  void dispose() {
    _locationRefreshTimer?.cancel();
    super.dispose();
  }

  void _syncLocationSharing(BookingModel booking) {
    getIt<RentalLocationShareService>().syncHandoverBookings([
      (id: booking.id, status: booking.status ?? '', isShuttle: booking.isShuttle),
    ]);
  }

  Future<void> _loadBooking() async {
    setState(() => _isLoading = true);
    final service = context.read<CustomerService>();

    BookingModel? booking;
    try {
      booking = service.myBookings.firstWhere((b) => b.id == widget.bookingId);
    } catch (_) {}

    booking ??= await service.getBookingById(widget.bookingId);

    if (!mounted) return;
    setState(() {
      _booking = booking;
      _isLoading = false;
    });
    if (booking != null) _syncLocationSharing(booking);
  }

  Future<void> _uploadDoc() async {
    final docType = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Jenis Dokumen'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, BookingDocField.ktp),
            child: const Text('Foto KTP'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, BookingDocField.sim),
            child: const Text('Foto SIM'),
          ),
        ],
      ),
    );

    if (docType == null || !mounted) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null || !mounted) return;

    final success = await context.read<CustomerService>().uploadBookingDocs(
      widget.bookingId,
      {docType: picked.path},
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Dokumen berhasil diunggah');
      _loadBooking();
    }
  }

  Future<void> _cancelBooking() async {
    final reasonController = TextEditingController(text: 'Dibatalkan oleh pelanggan');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Pembatalan',
                  hintText: 'Minimal 5 karakter',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return 'Alasan pembatalan minimal 5 karakter';
                  }
                  return null;
                },
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final reason = reasonController.text.trim();
    reasonController.dispose();

    final success = await context.read<CustomerService>().cancelBooking(
      widget.bookingId,
      reason: reason,
    );
    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Pesanan berhasil dibatalkan');
      context.pop();
    } else {
      final msg = context.read<CustomerService>().message;
      SnackbarUtils.showError(context, msg ?? 'Gagal membatalkan pesanan');
    }
  }

  Future<void> _extendBooking() async {
    final daysController = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perpanjang Sewa'),
        content: TextField(
          controller: daysController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Tambah hari'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Perpanjang')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final days = int.tryParse(daysController.text.trim()) ?? 1;
    daysController.dispose();

    final success = await context.read<CustomerService>().extendBooking(
      widget.bookingId,
      days,
    );
    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Sewa berhasil diperpanjang');
      _loadBooking();
    } else {
      SnackbarUtils.showError(context, 'Gagal memperpanjang sewa');
    }
  }

  Future<void> _contactMitra() async {
    final mitraUserId = _booking?.vehicle?.mitra?.userId;
    final mitraProfileId = _booking?.vehicle?.mitra?.id ?? _booking?.vehicle?.mitraId;
    final storeName = _booking?.vehicle?.mitra?.storeName ?? _booking?.vehicle?.mitra?.displayName ?? 'Mitra';

    if ((mitraUserId == null || mitraUserId.isEmpty) && (mitraProfileId == null || mitraProfileId.isEmpty)) {
      SnackbarUtils.showError(context, 'Data mitra tidak tersedia');
      return;
    }

    final room = await context.read<ChatService>().createRoom(
      mitraUserId: (mitraUserId != null && mitraUserId.isNotEmpty) ? mitraUserId : null,
      mitraId: (mitraUserId == null || mitraUserId.isEmpty) ? mitraProfileId : null,
      bookingId: widget.bookingId,
    );

    if (!mounted) return;
    if (room != null) {
      final nameParam = Uri.encodeComponent(room.name ?? storeName);
      context.push('/chat/${room.id}?name=$nameParam');
    } else {
      SnackbarUtils.showError(context, 'Gagal membuka chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: AppLoadingView());
    if (_booking == null) return const Scaffold(body: Center(child: Text('Pesanan tidak ditemukan')));

    final booking = _booking!;
    final canCancel = ['PENDING', 'APPROVED', 'PAID', 'CONFIRMED'].contains(booking.status);
    final canExtend = ['PAID', 'HANDOVER', 'CONFIRMED', 'HANDED_OVER'].contains(booking.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: ContentReveal(
        child: ListView(
        padding: AppPadding.list,
        children: [
          _buildStatusCard(booking),
          SizedBox(height: AppSpacing.section),
          if (!booking.isShuttle && booking.status == 'HANDOVER') ...[
            _buildLocationSharingBanner(),
            SizedBox(height: AppSpacing.section),
          ],
          if (booking.isShuttle && booking.schedule != null) ...[
            TravelJourneySummary(
              schedule: booking.schedule!,
              seats: booking.seats,
              showProgress: true,
            ),
            SizedBox(height: AppSpacing.section),
          ],
          _buildSectionHeader(booking.isShuttle ? 'Informasi Bus' : 'Informasi Kendaraan'),
          _buildVehicleInfo(booking),
          SizedBox(height: AppSpacing.section),
          _buildSectionHeader(booking.isShuttle ? 'Rincian Travel' : 'Rincian Sewa'),
          _buildRentInfo(booking),
          if (!booking.isShuttle) ...[
            SizedBox(height: AppSpacing.section),
            _buildSectionHeader('Dokumen Persyaratan'),
            _buildDocSection(booking),
          ],
          SizedBox(height: AppSpacing.section),
          OutlinedButton.icon(
            onPressed: _contactMitra,
            icon: Icon(LucideIcons.messageSquare),
            label: const Text('Hubungi Mitra'),
          ),
          SizedBox(height: AppSpacing.listGap),
          if (booking.status == 'PENDING' && booking.payment?.id.isNotEmpty == true)
            ElevatedButton.icon(
              onPressed: () async {
                final status = await context.read<CustomerService>().checkPaymentStatus(booking.payment!.id);
                if (status != null && mounted) {
                  final paid = status['status'] == 'PAID' || status['status'] == 'SUCCESS';
                  final msg = paid ? 'Pembayaran Terverifikasi!' : 'Pembayaran belum diterima.';
                  if (paid) AnalyticsService.instance.logPaymentSuccess(booking.id);
                  SnackbarUtils.showInfo(context, msg);
                  _loadBooking();
                }
              },
              icon: Icon(LucideIcons.refreshCw),
              label: const Text('Cek Status Pembayaran'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            ),
          SizedBox(height: AppSpacing.listGap),
          if (['RETURNED', 'COMPLETED'].contains(booking.status))
            ElevatedButton.icon(
              onPressed: () => context.push(
                '/bookings/${booking.id}/review?vehicleName=${booking.vehicle?.name ?? 'Kendaraan'}',
              ),
              icon: Icon(LucideIcons.star),
              label: const Text('Beri Review & Rating'),
            ),
          if (canExtend) ...[
            SizedBox(height: AppSpacing.listGap),
            OutlinedButton.icon(
              onPressed: _extendBooking,
              icon: Icon(LucideIcons.calendarPlus),
              label: const Text('Perpanjang Sewa'),
            ),
          ],
          if (canCancel) ...[
            SizedBox(height: AppSpacing.listGap),
            TextButton.icon(
              onPressed: () => context.push(AppRoutePaths.cancellationPolicy),
              icon: Icon(LucideIcons.fileText, size: 18.sp),
              label: const Text('Lihat Kebijakan Pembatalan'),
            ),
            AppGap.sm,
            OutlinedButton(
              onPressed: _cancelBooking,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.critical),
              child: const Text('Batalkan Pesanan'),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BookingModel booking) {
    return Container(
      padding: AppPadding.list,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: AppShapes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.receipt, color: AppColors.onDark, size: 32.sp),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${booking.status}',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.onDark),
                    ),
                    Text(
                      'ID: #${booking.id.substring(0, 8).toUpperCase()}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onDarkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (booking.cancelReason != null && booking.cancelReason!.isNotEmpty) ...[
            AppGap.sm,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.critical.withValues(alpha: 0.15),
                borderRadius: AppShapes.sm,
                border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: AppColors.critical, size: 16.sp),
                  AppGap.h(AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Alasan: ${booking.cancelReason}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSharingBanner() {
    final shareService = getIt<RentalLocationShareService>();
    final error = shareService.lastError;
    final hasError = error != null && error.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.critical.withValues(alpha: 0.08)
            : AppColors.teal.withValues(alpha: 0.08),
        borderRadius: AppShapes.md,
        border: Border.all(
          color: hasError
              ? AppColors.critical.withValues(alpha: 0.3)
              : AppColors.teal.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasError ? LucideIcons.triangleAlert : LucideIcons.mapPin,
            color: hasError ? AppColors.critical : AppColors.teal,
            size: 22.sp,
          ),
          AppGap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasError ? 'Lokasi belum terkirim' : 'Lokasi dibagikan ke mitra',
                  style: AppTextStyles.titleSmall,
                ),
                AppGap.xs,
                Text(
                  hasError
                      ? error
                      : 'Selama masa sewa aktif, app mengirim lokasi HP Anda ke mitra untuk keamanan unit. Aktif otomatis saat handover.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: SectionHeader(title: title),
    );
  }

  Widget _buildVehicleInfo(BookingModel booking) {
    return Container(
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(booking.vehicle?.name ?? 'Kendaraan', style: AppTextStyles.titleSmall),
        subtitle: Text(booking.vehicle?.brand ?? '-'),
        trailing: Text(
          MoneyFormatter.rupiah(booking.totalPrice),
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.teal),
        ),
      ),
    );
  }

  Widget _buildRentInfo(BookingModel booking) {
    return Container(
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppPadding.card,
        child: Column(
          children: [
            if (booking.isShuttle) ...[
              if (booking.seats.isNotEmpty)
                KeyValueRow(label: 'Kursi', value: booking.seats.join(', '), isBold: true),
              KeyValueRow(label: 'Keberangkatan', value: booking.schedule?.departureTime ?? booking.startDate ?? '-', isBold: true),
              KeyValueRow(label: 'Estimasi Tiba', value: booking.schedule?.arrivalTime ?? booking.endDate ?? '-', isBold: true),
            ] else ...[
              KeyValueRow(label: 'Tanggal Mulai', value: booking.startDate ?? '-', isBold: true),
              KeyValueRow(label: 'Tanggal Selesai', value: booking.endDate ?? '-', isBold: true),
              KeyValueRow(label: 'Tipe Paket', value: booking.packageType ?? 'BASIC', isBold: true),
              KeyValueRow(label: 'Asuransi', value: booking.isInsured ? 'Ya' : 'Tidak', isBold: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocSection(BookingModel booking) {
    final docs = booking.documents ?? [];

    return Column(
      children: [
        if (docs.isEmpty)
          Container(
            width: double.infinity,
            padding: AppPadding.screen,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.05),
              borderRadius: AppShapes.md,
              border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.circleAlert, color: AppColors.orange),
                AppGap.titleToSubtitle,
                Text(
                  'Silakan unggah foto SIM & KTP Anda agar pesanan dapat segera diproses oleh mitra.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: AppSpacing.listGap),
                ElevatedButton.icon(
                  onPressed: _uploadDoc,
                  icon: Icon(LucideIcons.upload, size: 16.sp),
                  label: const Text('Unggah Dokumen'),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ...docs.map(_buildDocPreview),
              IconButton(
                onPressed: _uploadDoc,
                icon: Icon(LucideIcons.circlePlus, color: AppColors.navy),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDocPreview(dynamic doc) {
    final url = doc is Map ? doc['url'] : doc.toString();
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: AppShapes.sm,
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
