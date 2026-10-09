import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/breakpoints.dart';
import '../../../config/decorations.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../layout/listing_card_layout.dart';
import '../layout/listing_card_metrics.dart';
import '../layout/listing_card_typography.dart';

/// Shimmer kilauan kiri→kanan — placeholder premium (bukan CircularProgressIndicator).
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    required this.child,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => AppDecorations.shimmerGradient(_controller.value).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Kotak shimmer — building block untuk skeleton list/card.
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    this.width,
    this.height,
    this.borderRadius,
    super.key,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppDecorations.shimmerBase,
          borderRadius: borderRadius ?? AppShapes.sm,
        ),
      ),
    );
  }
}

/// Skeleton card listing grid — proporsi sama [ListingCardLayout].
class AppShimmerListingCard extends StatelessWidget {
  const AppShimmerListingCard({
    required this.textBlockHeight,
    this.textLines = 3,
    super.key,
  });

  final double textBlockHeight;

  /// 2 = destinasi · 3 = kendaraan / paket wisata.
  final int textLines;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListingCardLayout.roundedImage(
            AspectRatio(
              aspectRatio: AppShapes.listingCardAspectRatio,
              child: ColoredBox(color: AppDecorations.shimmerMid),
            ),
          ),
          SizedBox(
            height: textBlockHeight,
            child: Padding(
              padding: ListingCardTypography.textPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textLine(ListingCardTypography.titleLineAllocated, 1),
                  SizedBox(height: ListingCardTypography.lineGap),
                  _textLine(ListingCardTypography.bodyLineAllocated, 0.88),
                  if (textLines >= 3) ...[
                    SizedBox(height: ListingCardTypography.lineGap),
                    _textLine(ListingCardTypography.actionRowAllocated, 0.62),
                  ],
                  if (textLines >= 4) ...[
                    SizedBox(height: ListingCardTypography.providerLeadGap),
                    _textLine(ListingCardTypography.providerLineAllocated, 0.75),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textLine(double height, double widthFactor) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          heightFactor: 0.72,
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppDecorations.shimmerBase,
              borderRadius: AppShapes.xxs,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer grid — kolom & tinggi sel sama [ListingGrid].
class AppShimmerListingGrid extends StatelessWidget {
  const AppShimmerListingGrid({
    required this.textBlockHeight,
    this.textLines = 3,
    this.itemCount = 12,
    this.padding,
    this.scrollable = true,
    super.key,
  });

  final double textBlockHeight;
  final int textLines;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final spacing = AppSpacing.md;
        final columns = AppBreakpoints.listingGridColumns(width, spacing: spacing);
        final cellWidth = AppBreakpoints.listingGridCellWidth(width, spacing: spacing);
        final rowHeight = ListingCardMetrics.totalHeight(
          cellWidth,
          textBlockHeight: textBlockHeight,
          includeCarouselBuffer: false,
        );

        return GridView.builder(
          padding: padding ?? AppPadding.list,
          shrinkWrap: !scrollable,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: rowHeight,
          ),
          itemCount: itemCount,
          itemBuilder: (_, __) => AppShimmerListingCard(
            textBlockHeight: textBlockHeight,
            textLines: textLines,
          ),
        );
      },
    );
  }
}

/// Skeleton card destinasi / hotel — proporsi full-width list (bukan grid).
class AppShimmerDestinationCard extends StatelessWidget {
  const AppShimmerDestinationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: AppDecorations.floatingCard(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160.h,
              width: double.infinity,
              color: AppDecorations.shimmerMid,
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: 88.w, height: 20.h, borderRadius: AppShapes.xxs),
                  SizedBox(height: AppSpacing.sm),
                  AppShimmerBox(width: double.infinity, height: 14.h),
                  SizedBox(height: AppSpacing.xs),
                  AppShimmerBox(width: 200.w, height: 14.h),
                  SizedBox(height: AppSpacing.md),
                  AppShimmerBox(width: 120.w, height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton baris horizontal — list tile, menu.
class AppShimmerListTile extends StatelessWidget {
  const AppShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppDecorations.shimmerMid,
                borderRadius: AppShapes.sm,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: double.infinity, height: 14.h),
                  SizedBox(height: AppSpacing.xs),
                  AppShimmerBox(width: 140.w, height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer untuk hasil search / list tile.
class AppShimmerResultList extends StatelessWidget {
  const AppShimmerResultList({this.itemCount = 6, this.padding, super.key});

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? AppPadding.list,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const AppShimmerListTile(),
    );
  }
}

/// Shimmer kotak untuk masonry grid (kendaraan).
class AppShimmerGridTile extends StatelessWidget {
  const AppShimmerGridTile({this.height, super.key});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: height ?? 180.h,
        decoration: AppDecorations.floatingCardOf(context, shadows: const []),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppDecorations.shimmerMid,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: double.infinity, height: 12.h),
                  SizedBox(height: AppSpacing.xs),
                  AppShimmerBox(width: 80.w, height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-page shimmer loading — list vertikal (blog, booking, jadwal travel).
class AppShimmerLoading extends StatelessWidget {
  const AppShimmerLoading({
    this.itemCount = 4,
    this.padding,
    super.key,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? AppPadding.list,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.listGap),
      itemBuilder: (_, __) => const AppShimmerDestinationCard(),
    );
  }
}
