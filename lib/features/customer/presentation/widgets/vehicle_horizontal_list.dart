import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../data/models/vehicle_model.dart';
import 'vehicle_card.dart';

/// Baris kendaraan geser horizontal — mobile.
class VehicleHorizontalList extends StatelessWidget {
  const VehicleHorizontalList({
    required this.vehicles,
    super.key,
  });

  final List<VehicleModel> vehicles;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) return const SizedBox.shrink();

    const cardWidth = AppBreakpoints.listingCardWidth;
    final rowHeight = ListingCardMetrics.totalHeight(
      cardWidth,
      textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
    );

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            layout: VehicleCardLayout.compact,
            onTap: () => context.push(AppRoutePaths.vehicleDetail(vehicle.id)),
          );
        },
      ),
    );
  }
}
