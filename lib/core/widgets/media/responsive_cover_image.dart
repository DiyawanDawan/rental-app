import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';
import '../../../config/shapes.dart';
import 'app_cached_network_image.dart';

/// Strategi [BoxFit] dinamis — mencegah gambar penyet di iPad (4:3) atau terlalu
/// melar di desktop ultrawide.
abstract final class ResponsiveImageFit {
  /// Banner promo: lebih pendek di landscape HP, lebih tinggi di tablet.
  static double bannerAspectRatio(BuildContext context) {
    if (context.isLandscapeNarrow) return 21 / 9;
    if (context.isTablet) return 4 / 3;
    if (context.isDesktop) return 21 / 9;
    return 16 / 9;
  }

  /// Card destinasi/hotel: tablet kotak → rasio 4:3, mobile/desktop → 16:9.
  static double cardAspectRatio(BuildContext context) {
    if (context.isTablet) return AppShapes.heroImageAspectRatio;
    return AppShapes.destinationCardAspectRatio;
  }

  /// Cover untuk foto landscape; contain untuk viewport kotak (iPad portrait).
  static BoxFit coverFit(BuildContext context) {
    if (context.isTablet && !context.isLandscape) {
      return BoxFit.cover;
    }
    return BoxFit.cover;
  }

  /// Hero banner lebar — hindari stretch horizontal berlebihan.
  static BoxFit bannerFit(BuildContext context) {
    if (context.isDesktop || context.isLandscapeNarrow) return BoxFit.cover;
    if (context.isTablet) return BoxFit.cover;
    return BoxFit.cover;
  }
}

/// Gambar dengan [AspectRatio] terkunci + [BoxFit] responsif.
class ResponsiveCoverImage extends StatelessWidget {
  const ResponsiveCoverImage({
    required this.imageUrl,
    super.key,
    this.aspectRatio,
    this.fit,
    this.borderRadius,
    this.errorIcon,
    this.heroTag,
    this.fallback,
  });

  final String imageUrl;
  final double? aspectRatio;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final IconData? errorIcon;
  final Object? heroTag;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final ratio = aspectRatio ?? ResponsiveImageFit.cardAspectRatio(context);
    final resolvedFit = fit ?? ResponsiveImageFit.coverFit(context);

    Widget image = AspectRatio(
      aspectRatio: ratio,
      child: AppCachedNetworkImage(
        imageUrl: imageUrl,
        fit: resolvedFit,
        width: double.infinity,
        errorIcon: errorIcon ?? Icons.image_not_supported_outlined,
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    if (fallback != null && imageUrl.isEmpty) {
      image = AspectRatio(aspectRatio: ratio, child: fallback);
    }

    return image;
  }
}
