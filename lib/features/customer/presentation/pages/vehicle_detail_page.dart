import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../chat/application/chat_service.dart';
import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../config/breakpoints.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/image_cache_url.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/layout/detail_booking_card.dart';
import '../../../../core/widgets/layout/detail_page_layout.dart';
import '../../../../core/widgets/layout/detail_photo_gallery.dart';
import '../../../../core/widgets/layout/detail_responsive_scaffold.dart';
import '../../../../core/widgets/layout/sticky_price_bar.dart';
import '../../../../core/widgets/feedback/detail_page_skeleton.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../../../core/widgets/map/map_widget.dart';
import '../../data/customer_repository.dart';
import '../../data/models/vehicle_model.dart';
import '../widgets/review_list_section.dart';
import '../widgets/vehicle_availability_calendar.dart';

class VehicleDetailPage extends StatefulWidget {
  const VehicleDetailPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late Future<VehicleModel> _future;
  bool? _localFavorite;
  bool _favoriteLoading = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logViewVehicle(widget.vehicleId);
    _future = _loadVehicle();
  }

  Future<VehicleModel> _loadVehicle() async {
    final response = await getIt<CustomerRepository>().getVehicleById(widget.vehicleId);
    return response.data!;
  }

  void _reload() => setState(() {
        _localFavorite = null;
        _future = _loadVehicle();
      });

  Future<void> _toggleFavorite() async {
    setState(() => _favoriteLoading = true);
    final response = await getIt<CustomerRepository>().toggleVehicleFavorite(widget.vehicleId);
    if (!mounted) return;
    setState(() {
      _favoriteLoading = false;
      _localFavorite = response.data?['favorited'] == true;
    });
  }

  void _book(VehicleModel vehicle) {
    AnalyticsService.instance.logStartBooking(widget.vehicleId);
    context.push(AppRoutePaths.createBooking(widget.vehicleId));
  }

  Future<void> _contactMitra(MitraSummaryModel? mitra) async {
    if (mitra == null) return;
    final mitraUserId = mitra.userId;
    final mitraProfileId = mitra.id;
    final storeName = mitra.displayName;

    if ((mitraUserId == null || mitraUserId.isEmpty) && mitraProfileId.isEmpty) {
      SnackbarUtils.showError(context, 'Data mitra tidak tersedia');
      return;
    }

    final room = await context.read<ChatService>().createRoom(
      mitraUserId: (mitraUserId != null && mitraUserId.isNotEmpty) ? mitraUserId : null,
      mitraId: (mitraUserId == null || mitraUserId.isEmpty) ? mitraProfileId : null,
    );

    if (!mounted) return;
    if (room != null) {
      final nameParam = Uri.encodeComponent(room.name ?? storeName);
      context.push('/chat/${room.id}?name=$nameParam');
    } else {
      SnackbarUtils.showError(context, 'Gagal membuka chat');
    }
  }

  List<String> _galleryUrls(VehicleModel vehicle) {
    if (vehicle.primaryPhotoUrl == null) return const [];
    return [cacheBustImageUrl(vehicle.primaryPhotoUrl!, version: vehicle.id)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: FutureBuilder<VehicleModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const DetailPageSkeleton(expandedHeight: 300);
          }

          if (snapshot.hasError || !snapshot.hasData) {
            final error = snapshot.error;
            final message = error is Failure ? error.message : 'Detail kendaraan tidak tersedia';
            return AppErrorState(title: 'Gagal memuat', message: message, onRetry: _reload);
          }

          final vehicle = snapshot.data!;
          final isFavorite = _localFavorite ?? vehicle.isFavorited;
          final meta = [vehicle.brand, vehicle.model, vehicle.type, vehicle.transmission]
              .whereType<String>()
              .join(' · ');
          final description = vehicle.description?.isNotEmpty == true
              ? vehicle.description!
              : 'Deskripsi kendaraan belum tersedia.';

          final priceText = MoneyFormatter.rupiah(vehicle.pricePerDay);

          return DetailResponsiveScaffold(
            bottomScrollPadding: context.detailUsesSidebar
                ? 0
                : scrollBottomInsetForStickyBar(context),
            titleBar: DetailPageTitleBar(
              title: vehicle.name,
              actions: [
                DetailTextAction(
                  label: 'Bagikan',
                  icon: LucideIcons.share2,
                  onPressed: () {
                    Share.share(
                      'Cek kendaraan ini di Travelindo: ${vehicle.name}\n\nhttps://travelindo.com/vehicles/${vehicle.id}',
                      subject: 'Rental Kendaraan Travelindo',
                    );
                  },
                ),
                DetailTextAction(
                  label: isFavorite ? 'Tersimpan' : 'Simpan',
                  icon: LucideIcons.heart,
                  onPressed: _favoriteLoading ? null : _toggleFavorite,
                ),
              ],
            ),
            gallery: DetailPhotoGallery(
              urls: _galleryUrls(vehicle),
              heroTag: AppHeroTags.vehiclePhoto(vehicle.id),
              emptyIcon: LucideIcons.car,
              toolbar: DetailHeroToolbar(
                actions: [
                  DetailOverlayButton(
                    icon: LucideIcons.heart,
                    tooltip: 'Favorit',
                    iconColor: isFavorite ? context.cs.error : null,
                    onPressed: _favoriteLoading ? null : _toggleFavorite,
                  ),
                  AppGap.h(AppSpacing.sm),
                  DetailOverlayButton(
                    icon: LucideIcons.share2,
                    tooltip: 'Bagikan',
                    onPressed: () {
                      Share.share(
                        'Cek kendaraan ini di Travelindo: ${vehicle.name}\n\nhttps://travelindo.com/vehicles/${vehicle.id}',
                        subject: 'Rental Kendaraan Travelindo',
                      );
                    },
                  ),
                ],
              ),
            ),
            lead: DetailLeadBlock(
              lead: 'Rental kendaraan ${vehicle.type ?? ''}'.trim(),
              meta: meta,
              rating: vehicle.ratingAvg,
              reviewCount: vehicle.reviewCount,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vehicle.mitra != null) ...[
                  const DetailSectionDivider(),
                  DetailHostRow(
                    title: vehicle.mitra!.storeName ?? 'Mitra Travelindo',
                    subtitle: vehicle.mitra!.isVerified
                        ? 'Mitra terverifikasi · Ketuk untuk profil'
                        : 'Ketuk untuk lihat profil mitra',
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: context.cs.surfaceContainerHighest,
                      child: Icon(LucideIcons.store, color: context.cs.onSurfaceVariant),
                    ),
                    onTap: vehicle.mitra!.id.isNotEmpty
                        ? () => context.push(AppRoutePaths.mitraPublicProfile(vehicle.mitra!.id))
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _contactMitra(vehicle.mitra),
                      icon: const Icon(LucideIcons.messageCircle, size: 16, color: AppColors.orange),
                      label: Text('Chat Mitra', style: AppTextStyles.labelMedium.copyWith(color: AppColors.orange)),
                    ),
                  ),
                ],
                DetailSection(
                  title: 'Tentang kendaraan ini',
                  child: DetailExpandableText(text: description),
                ),
                if (vehicle.mitra?.latitude != null && vehicle.mitra?.longitude != null)
                  DetailSection(
                    title: 'Lokasi kantor mitra',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: TravelindoMap(
                            initialLocation: LatLng(
                              vehicle.mitra!.latitude!,
                              vehicle.mitra!.longitude!,
                            ),
                            height: 180.h,
                            markers: [
                              Marker(
                                point: LatLng(
                                  vehicle.mitra!.latitude!,
                                  vehicle.mitra!.longitude!,
                                ),
                                child: Icon(
                                  LucideIcons.mapPin,
                                  color: context.cs.error,
                                  size: 30.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (vehicle.mitra?.address != null) ...[
                          AppGap.titleToSubtitle,
                          Text(vehicle.mitra!.address!, style: context.textBodySmall),
                        ],
                      ],
                    ),
                  ),
                DetailSection(
                  title: 'Ketersediaan',
                  child: VehicleAvailabilityCalendar(
                    vehicleId: widget.vehicleId,
                    embedded: true,
                  ),
                ),
                DetailSection(
                  title: 'Ulasan',
                  showDivider: false,
                  child: ReviewListSection(vehicleId: widget.vehicleId, embedded: true),
                ),
              ],
            ),
            bookingCard: DetailBookingCard(
              feeBanner: 'Harga sudah termasuk pajak & biaya layanan',
              priceLine: '$priceText per hari',
              buttonLabel: 'Pesan',
              fields: const [
                DetailBookingField(label: 'Mulai', value: 'Pilih tanggal'),
                DetailBookingField(label: 'Selesai', value: 'Pilih tanggal'),
              ],
              infoBanner: 'Gratis pembatalan hingga 24 jam sebelum mulai sewa',
              onPressed: () => _book(vehicle),
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<VehicleModel>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final vehicle = snapshot.data!;
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppDecorations.softShadow(opacity: 0.1, blur: 6, offsetY: -2),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mulai dari', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(MoneyFormatter.rupiah(vehicle.pricePerDay), style: AppTextStyles.titleMedium.copyWith(color: AppColors.orange, fontWeight: FontWeight.bold)),
                          Text('/hari', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _contactMitra(vehicle.mitra),
                    icon: const Icon(LucideIcons.messageSquare, color: AppColors.orange),
                    tooltip: 'Chat Mitra',
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () => _book(vehicle),
                    child: const Text('Pesan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
