import 'package:flutter/material.dart';

import '../../../config/spacing.dart';

/// Garis pemisah full-width antara toolbar filter dan konten listing.
class ListingToolbarDivider extends StatelessWidget {
  const ListingToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm),
      child: const Divider(height: 1, thickness: 1),
    );
  }
}
