import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';
import '../../../config/spacing.dart';
import 'listing_card_metrics.dart';

/// Grid halaman list — slot kolom 2/4/6/7 (sama carousel home), card mengisi lebar sel.
class ListingGrid extends StatelessWidget {
  const ListingGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.textBlockHeight,
    this.controller,
    this.padding,
    this.scrollable = false,
    this.mobileBuilder,
    super.key,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double textBlockHeight;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final WidgetBuilder? mobileBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < AppBreakpoints.mobile && mobileBuilder != null) {
          return mobileBuilder!(context);
        }

        final spacing = AppSpacing.md;
        final columns = AppBreakpoints.listingGridColumns(width, spacing: spacing);
        final cellWidth = AppBreakpoints.listingGridCellWidth(width, spacing: spacing);
        final rowHeight = ListingCardMetrics.totalHeight(
          cellWidth,
          textBlockHeight: textBlockHeight,
          includeCarouselBuffer: false,
        );

        return GridView.builder(
          controller: controller,
          shrinkWrap: !scrollable,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: rowHeight,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) => SizedBox(
            width: cellWidth,
            height: rowHeight,
            child: itemBuilder(context, index),
          ),
        );
      },
    );
  }
}
