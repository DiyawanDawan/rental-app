import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/hero_tags.dart';
import '../../../../config/routes.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/cards/destination_card.dart';
import '../../data/models/tourist_destination_model.dart';
import 'destination_media_gallery.dart';

/// Adapter feature → core [DestinationCard] untuk [TouristDestinationModel].
class TouristDestinationCard extends StatelessWidget {
  const TouristDestinationCard({
    required this.destination,
    this.enableHero = false,
    this.layout = DestinationCardLayout.full,
    super.key,
  });

  final TouristDestinationModel destination;
  final bool enableHero;
  final DestinationCardLayout layout;

  Future<void> _openDetail(BuildContext context, String? imageUrl) async {
    await precacheNetworkImageUrl(context, imageUrl);
    if (!context.mounted) return;
    context.push(AppRoutePaths.destinationDetail(destination.id));
  }

  @override
  Widget build(BuildContext context) {
    final urls = destination.galleryUrls;
    final primaryUrl = urls.isNotEmpty ? urls.first : null;
    final imageCount = destination.media.where((m) => m.isImage).length;
    // Card listing/bento: galeri multi-foto di dalam card bila ada >1 gambar.
    final useGallery = imageCount > 1;

    return DestinationCard(
      title: destination.name,
      subtitle: destination.excerpt.isNotEmpty ? destination.excerpt : null,
      location: destination.address,
      imageUrl: useGallery ? null : primaryUrl,
      image: useGallery
          ? DestinationCardGalleryPreview(media: destination.media)
          : null,
      heroTag: enableHero && primaryUrl != null ? AppHeroTags.destinationPhoto(primaryUrl) : null,
      layout: layout,
      onTap: () => _openDetail(context, primaryUrl),
    );
  }
}
