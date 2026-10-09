import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../data/models/tour_model.dart';
import 'tour_package_card.dart';

/// Baris paket wisata geser horizontal — mobile.
class TourHorizontalList extends StatelessWidget {
  const TourHorizontalList({
    required this.tours,
    this.showRecommendedBadge = false,
    super.key,
  });

  final List<TourPackageModel> tours;
  final bool showRecommendedBadge;

  @override
  Widget build(BuildContext context) {
    if (tours.isEmpty) return const SizedBox.shrink();

    const cardWidth = AppBreakpoints.listingCardWidth;
    final rowHeight = ListingCardMetrics.totalHeight(
      cardWidth,
      textBlockHeight: ListingCardMetrics.tourTextBlockHeight,
    );

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tours.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) => TourPackageCard(
          tour: tours[index],
          layout: TourPackageCardLayout.compact,
          showRecommendedBadge: showRecommendedBadge,
        ),
      ),
    );
  }
}
