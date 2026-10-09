import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/layout/detail_page_layout.dart';
import '../../../../config/routes.dart';
import '../../../../core/widgets/media/app_cached_network_image.dart';
import '../../../../config/theme_context.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/map/map_widget.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_section.dart';
import '../../data/models/tour_model.dart';
import '../widgets/review_list_section.dart';
import '../widgets/tour_package_card.dart';

class TourDetailInfoSections extends StatelessWidget {
  const TourDetailInfoSections({required this.tour, super.key});

  final TourPackageModel tour;

  @override
  Widget build(BuildContext context) {
    final description = tour.description ?? 'Belum ada deskripsi paket wisata.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tour.mitra != null) ...[
          DetailHostRow(
            title: tour.mitra!.displayName,
            subtitle: tour.mitra!.isVerified
                ? 'Mitra terverifikasi'
                : 'Penyedia paket wisata',
            leading: CircleAvatar(
              backgroundImage: tour.mitra!.avatarUrl != null && tour.mitra!.avatarUrl!.isNotEmpty
                  ? NetworkImage(tour.mitra!.avatarUrl!)
                  : null,
              child: tour.mitra!.avatarUrl == null || tour.mitra!.avatarUrl!.isEmpty
                  ? Icon(LucideIcons.store, size: 18.sp)
                  : null,
            ),
            onTap: tour.mitra!.hasProfile
                ? () => context.push(AppRoutePaths.mitraPublicProfile(tour.mitra!.id))
                : null,
          ),
          const DetailSectionDivider(),
        ],
        if (tour.highlights.isNotEmpty)
          DetailSection(
            title: 'Sorotan',
            child: Column(
              children: tour.highlights
                  .map(
                    (h) => DetailHighlightRow(
                      icon: LucideIcons.sparkles,
                      title: h,
                      subtitle: 'Termasuk dalam paket ini',
                    ),
                  )
                  .toList(),
            ),
          ),
        DetailSection(
          title: 'Tentang paket ini',
          child: DetailExpandableText(text: description),
        ),
        if (tour.destinations.isNotEmpty)
          DetailSection(
            title: 'Rute & destinasi',
            child: Column(
              children: tour.destinations.asMap().entries
                  .map((entry) => _DestinationTile(index: entry.key + 1, destination: entry.value))
                  .toList(),
            ),
          ),
        if (tour.addons.isNotEmpty)
          DetailSection(
            title: 'Add-on opsional',
            child: Column(
              children: tour.addons.map((addon) => _AddonTile(addon: addon)).toList(),
            ),
          ),
        if (tour.destinationLat != null && tour.destinationLng != null)
          DetailSection(
            title: 'Lokasi utama',
            child: ClipRRect(
              borderRadius: AppShapes.md,
              child: TravelindoMap(
                initialLocation: LatLng(tour.destinationLat!, tour.destinationLng!),
                height: 180.h,
                zoom: 12,
              ),
            ),
          ),
        if (tour.mitra?.hasProfile == true) ...[
          DetailSection(
            title: 'Ulasan',
            showDivider: false,
            child: MitraReviewListSection(mitraId: tour.mitra!.id),
          ),
        ],
      ],
    );
  }
}

class TourRecommendedSection extends StatelessWidget {
  const TourRecommendedSection({
    required this.tours,
    super.key,
  });

  final List<TourPackageModel> tours;

  @override
  Widget build(BuildContext context) {
    if (tours.isEmpty) return const SizedBox.shrink();

    return ListingSection(
      title: 'Rekomendasi Wisata Lainnya',
      itemCount: tours.length,
      textBlockHeight: ListingCardMetrics.tourTextBlockHeight,
      itemBuilder: (context, index, _) => TourPackageCard(
        tour: tours[index],
        layout: TourPackageCardLayout.listing,
        showRecommendedBadge: true,
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({required this.index, required this.destination});
  final int index;
  final TourDestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text('$index.', style: context.textTitleSmall),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.name, style: context.textTitleSmall),
                if (destination.address != null && destination.address!.isNotEmpty) ...[
                  AppGap.xs,
                  Text(destination.address!, style: context.textBodySmall),
                ],
                if (destination.description != null && destination.description!.isNotEmpty) ...[
                  AppGap.xs,
                  Text(
                    destination.description!,
                    style: context.textBodyMedium.copyWith(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          if (destination.imageUrl != null) ...[
            AppGap.h(AppSpacing.md),
            ClipRRect(
              borderRadius: AppShapes.sm,
              child: SizedBox(
                width: 80,
                height: 80,
                child: AppCachedNetworkImage(
                  imageUrl: destination.imageUrl!,
                  fit: BoxFit.cover,
                  borderRadius: AppShapes.sm,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddonTile extends StatelessWidget {
  const _AddonTile({required this.addon});
  final TourAddonModel addon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(LucideIcons.circlePlus, color: context.cs.tertiary, size: 20.sp),
      title: Text(addon.name, style: context.textBodyMedium),
      subtitle: Text(addon.typeLabel, style: context.textBodySmall),
      trailing: Text(
        '+ ${MoneyFormatter.rupiah(addon.additionalPrice)}',
        style: context.textBodySmall.copyWith(color: context.cs.tertiary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
