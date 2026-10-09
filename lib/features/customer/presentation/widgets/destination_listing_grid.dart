import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../data/models/tourist_destination_model.dart';
import 'destination_bento_gallery.dart';

/// Section destinasi home — 5 kolom sama lebar, grid foto 2×2 per card.
class DestinationListingSection extends StatelessWidget {
  const DestinationListingSection({
    required this.destinations,
    super.key,
  });

  final List<TouristDestinationModel> destinations;

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) {
      return OutlinedButton.icon(
        onPressed: () => context.push(AppRoutePaths.destinations),
        icon: const Icon(LucideIcons.mapPinned),
        label: const Text('Jelajah destinasi wisata'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => context.push(AppRoutePaths.destinations),
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Jelajah Destinasi',
                  style: context.textTitleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppGap.h(AppSpacing.xs),
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: context.cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
        AppGap.sectionTitleToContent,
        DestinationBentoGallery(destinations: destinations),
      ],
    );
  }
}

/// @deprecated Gunakan [DestinationListingSection].
typedef DestinationListingGrid = DestinationListingSection;
