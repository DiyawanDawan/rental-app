import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/motion.dart';
import '../../../config/shapes.dart';
import '../feedback/shimmer_loading.dart';

/// Network image with shimmer placeholder, fade-in, and standardized error widget.
class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.colorBlendMode,
    this.errorIcon = LucideIcons.imageOff,
    super.key,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final BlendMode? colorBlendMode;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: AppMotion.medium,
      fadeOutDuration: AppMotion.fast,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: (_, __) => AppShimmerBox(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      errorWidget: (_, __, ___) => ColoredBox(
        color: AppColors.surfaceMuted,
        child: Center(
          child: Icon(errorIcon, size: 32.sp, color: AppColors.textTertiary),
        ),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

/// Placeholder for list thumbnails (vehicle, tour, destination).
Widget appCachedImagePlaceholder({double? width, double? height}) => AppShimmerBox(
      width: width,
      height: height,
      borderRadius: AppShapes.sm,
    );
