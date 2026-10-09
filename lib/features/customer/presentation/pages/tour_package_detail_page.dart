import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/di.dart';
import '../../../../config/breakpoints.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/layout/detail_booking_card.dart';
import '../../../../core/widgets/layout/detail_page_layout.dart';
import '../../../../core/widgets/layout/detail_photo_gallery.dart';
import '../../../../core/widgets/layout/detail_responsive_scaffold.dart';
import '../../../../core/widgets/layout/sticky_price_bar.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../../../core/widgets/feedback/detail_page_skeleton.dart';
import '../../data/customer_repository.dart';
import '../../data/models/tour_model.dart';
import '../utils/tour_recommendation_utils.dart';
import '../widgets/tour_detail_info_sections.dart';

class TourPackageDetailPage extends StatefulWidget {
  const TourPackageDetailPage({required this.tourId, super.key});

  final String tourId;

  @override
  State<TourPackageDetailPage> createState() => _TourPackageDetailPageState();
}

class _TourPackageDetailPageState extends State<TourPackageDetailPage> {
  late Future<TourPackageModel> _future;
  late Future<List<TourPackageModel>> _recommendedFuture;

  @override
  void initState() {
    super.initState();
    _future = _loadTour();
    _recommendedFuture = _loadRecommended();
  }

  Future<TourPackageModel> _loadTour() async {
    final response = await getIt<CustomerRepository>().getTourPackageById(widget.tourId);
    final tour = response.data;
    if (tour == null) {
      throw Failure(message: 'Paket wisata tidak ditemukan');
    }
    return tour;
  }

  Future<List<TourPackageModel>> _loadRecommended() async {
    final response = await getIt<CustomerRepository>().getTourPackages();
    final tours = response.data ?? const <TourPackageModel>[];
    return pickRecommendedTours(tours, limit: 6, excludeId: widget.tourId);
  }

  void _reload() {
    setState(() {
      _future = _loadTour();
      _recommendedFuture = _loadRecommended();
    });
  }

  void _book(TourPackageModel tour) {
    context.push(AppRoutePaths.tourBook(tour.id), extra: tour);
  }

  void _share(TourPackageModel tour) {
    Share.share(
      'Cek paket wisata: ${tour.title}\n\nhttps://travelindo.com/tours/${tour.id}',
      subject: 'Paket Wisata Travelindo',
    );
  }

  String _leadLine(TourPackageModel tour) {
    if (tour.location != null && tour.location!.isNotEmpty) {
      return 'Paket wisata di ${tour.location}';
    }
    return 'Paket wisata Travelindo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: FutureBuilder<TourPackageModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const DetailPageSkeleton(expandedHeight: 300);
          }

          if (snapshot.hasError || !snapshot.hasData) {
            final error = snapshot.error;
            final message = error is Failure ? error.message : 'Paket wisata tidak ditemukan';
            return AppErrorState(
              title: 'Gagal memuat paket',
              message: message,
              onRetry: _reload,
            );
          }

          final tour = snapshot.data!;
          final metaParts = <String>[
            tour.durationLabel,
            tour.passengersLabel,
            if (tour.location != null) tour.location!,
          ];
          final priceText = MoneyFormatter.rupiah(tour.price);

          return DetailResponsiveScaffold(
            bottomScrollPadding: context.detailUsesSidebar
                ? 0
                : scrollBottomInsetForStickyBar(context),
            titleBar: DetailPageTitleBar(
              title: tour.title,
              actions: [
                DetailTextAction(
                  label: 'Bagikan',
                  icon: LucideIcons.share2,
                  onPressed: () => _share(tour),
                ),
                if (context.detailUsesSidebar)
                  DetailTextAction(
                    label: 'Simpan',
                    icon: LucideIcons.heart,
                    onPressed: () {},
                  ),
              ],
            ),
            gallery: DetailPhotoGallery(
              urls: tour.galleryUrls,
              heroTag: AppHeroTags.tourImage(tour.id),
              emptyIcon: LucideIcons.treePalm,
              onShowAllPhotos: tour.galleryUrls.length > 1
                  ? () => _openGallerySheet(context, tour.galleryUrls)
                  : null,
              toolbar: DetailHeroToolbar(
                actions: [
                  DetailOverlayButton(
                    icon: LucideIcons.share2,
                    tooltip: 'Bagikan',
                    onPressed: () => _share(tour),
                  ),
                ],
              ),
            ),
            lead: DetailLeadBlock(
              lead: _leadLine(tour),
              meta: metaParts.join(' · '),
            ),
            body: TourDetailInfoSections(tour: tour),
            footer: FutureBuilder<List<TourPackageModel>>(
              future: _recommendedFuture,
              builder: (context, recSnapshot) {
                if (!recSnapshot.hasData) return const SizedBox.shrink();
                return TourRecommendedSection(tours: recSnapshot.data!);
              },
            ),
            bookingCard: DetailBookingCard(
              feeBanner: 'Harga sudah termasuk pajak & biaya layanan',
              priceLine: '$priceText per paket',
              buttonLabel: 'Pesan',
              fields: [
                DetailBookingField(label: 'Tanggal', value: 'Pilih tanggal'),
                DetailBookingField(label: 'Tamu', value: tour.passengersLabel),
              ],
              infoBanner: 'Gratis pembatalan hingga 7 hari sebelum berangkat',
              footnote: 'Anda belum dikenakan biaya',
              onPressed: () => _book(tour),
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<TourPackageModel>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final tour = snapshot.data!;
          return DetailMobileBookingBar(
            price: MoneyFormatter.rupiah(tour.price),
            priceSuffix: '/paket',
            buttonLabel: 'Pesan',
            onPressed: () => _book(tour),
          );
        },
      ),
    );
  }

  void _openGallerySheet(BuildContext context, List<String> urls) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(AppSpacing.page),
          itemCount: urls.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(urls[index], fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
