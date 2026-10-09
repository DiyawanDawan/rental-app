import 'package:flutter/material.dart';

import '../../../config/decorations.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../interaction/animated_inkwell.dart';

enum AppTravelCardDensity { compact, standard }

/// Shell card seragam untuk list destinasi, hotel, tour, kendaraan.
class AppTravelCard extends StatelessWidget {
  const AppTravelCard({
    required this.child,
    this.onTap,
    this.image,
    this.imageAspectRatio = AppShapes.listImageAspectRatio,
    this.density = AppTravelCardDensity.standard,
    this.margin,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Widget? image;
  final double imageAspectRatio;
  final AppTravelCardDensity density;
  final EdgeInsetsGeometry? margin;

  double get _padding =>
      density == AppTravelCardDensity.compact ? AppSpacing.cardPadCompact : AppSpacing.cardPad;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null)
            AspectRatio(
              aspectRatio: imageAspectRatio,
              child: image,
            ),
          Padding(
            padding: EdgeInsets.all(_padding),
            child: child,
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: content,
    );
  }
}
