import 'package:flutter/material.dart';

import '../../../config/decorations.dart';
import '../../../config/shapes.dart';
import 'listing_card_typography.dart';

/// Layout listing — foto rounded + teks (tanpa shadow card).
class ListingCardLayout extends StatelessWidget {
  const ListingCardLayout({
    required this.textBlockHeight,
    required this.image,
    required this.text,
    this.aspectRatio = AppShapes.listingCardAspectRatio,
    super.key,
  });

  final double textBlockHeight;
  final Widget image;
  final Widget text;
  final double aspectRatio;

  static Widget roundedImage(Widget child) {
    return ClipRRect(
      borderRadius: AppDecorations.listingCardRadius,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;

        if (!boundedHeight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              roundedImage(AspectRatio(aspectRatio: aspectRatio, child: image)),
              Padding(
                padding: ListingCardTypography.textPadding,
                child: text,
              ),
            ],
          );
        }

        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: roundedImage(image)),
              SizedBox(
                height: textBlockHeight,
                child: Padding(
                  padding: ListingCardTypography.textPadding,
                  child: text,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// @deprecated Padding teks sudah di [ListingCardLayout].
@Deprecated('Padding handled by ListingCardLayout')
EdgeInsets get listingCardTextPadding => EdgeInsets.zero;
