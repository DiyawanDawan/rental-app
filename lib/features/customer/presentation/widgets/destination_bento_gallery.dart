import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/decorations.dart';
import '../../../../core/widgets/layout/listing_card_layout.dart';
import '../../../../core/widgets/layout/listing_card_typography.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../data/models/tourist_destination_model.dart';
import 'destination_media_gallery.dart';

/// Galeri destinasi home — 5 kolom sama lebar, tiap kolom = card + grid foto 2×2.
class DestinationBentoGallery extends StatelessWidget {
  const DestinationBentoGallery({
    required this.destinations,
    super.key,
  });

  static const int maxTiles = 5;

  final List<TouristDestinationModel> destinations;

  @override
  Widget build(BuildContext context) {
    final items = destinations.take(maxTiles).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final gap = AppSpacing.md;
    final galleryHeight = context.screenWidth >= AppBreakpoints.tablet ? 280.0 : 240.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = context.screenWidth >= AppBreakpoints.tablet;

        if (!isWide) {
          final cardWidth = width * 0.44;
          return SizedBox(
            height: galleryHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: gap),
              itemBuilder: (context, index) => SizedBox(
                width: cardWidth,
                child: _DestinationGalleryCard(
                  destination: items[index],
                  variantIndex: index,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: galleryHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  child: _DestinationGalleryCard(
                    destination: items[i],
                    variantIndex: i,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Tile destinasi — kolase foto + judul (tanpa shell card; teks di background halaman).
class _DestinationGalleryCard extends StatelessWidget {
  const _DestinationGalleryCard({
    required this.destination,
    required this.variantIndex,
  });

  final TouristDestinationModel destination;
  final int variantIndex;

  Future<void> _open(BuildContext context) async {
    final url = destination.galleryUrls.isNotEmpty
        ? destination.galleryUrls.first
        : null;
    await precacheNetworkImageUrl(context, url);
    if (!context.mounted) return;
    context.push(AppRoutePaths.destinationDetail(destination.id));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: () => _open(context),
      borderRadius: AppDecorations.listingCardRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      showPressedShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListingCardLayout.roundedImage(
              DestinationCardPhotoCollage(
                media: destination.media,
                maxCells: 4,
                variantIndex: variantIndex,
              ),
            ),
          ),
          SizedBox(
            height: 32,
            child: Padding(
              padding: ListingCardTypography.textPadding.copyWith(bottom: 0),
              child: Text(
                destination.name,
                style: context.textLabelLarge.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
