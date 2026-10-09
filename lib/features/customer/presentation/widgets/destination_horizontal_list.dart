import 'package:flutter/material.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/cards/destination_card.dart';
import '../../data/models/tourist_destination_model.dart';
import 'tourist_destination_card.dart';

/// Baris destinasi yang bisa digeser horizontal — home & list page.
class DestinationHorizontalList extends StatelessWidget {
  const DestinationHorizontalList({
    required this.destinations,
    this.maxItems = 8,
    super.key,
  });

  final List<TouristDestinationModel> destinations;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (destinations.length < 2) return const SizedBox.shrink();

    final visible = destinations.take(maxItems).toList();
    final cardWidth = AppBreakpoints.listingCardWidth;
    final rowHeight = DestinationCard.listingTotalHeight(cardWidth);

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) => TouristDestinationCard(
          destination: visible[index],
          layout: DestinationCardLayout.compact,
        ),
      ),
    );
  }
}
