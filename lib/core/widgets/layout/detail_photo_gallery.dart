import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/breakpoints.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'detail_page_layout.dart';

/// Galeri foto detail — carousel mobile, grid Airbnb di desktop.
class DetailPhotoGallery extends StatefulWidget {
  const DetailPhotoGallery({
    required this.urls,
    this.heroTag,
    this.toolbar,
    this.emptyIcon,
    this.onShowAllPhotos,
    super.key,
  });

  final List<String> urls;
  final String? heroTag;
  final Widget? toolbar;
  final IconData? emptyIcon;
  final VoidCallback? onShowAllPhotos;

  @override
  State<DetailPhotoGallery> createState() => _DetailPhotoGalleryState();
}

class _DetailPhotoGalleryState extends State<DetailPhotoGallery> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isDesktopGrid => context.screenWidth >= AppBreakpoints.desktopLayoutMinWidth;

  double get _height => _isDesktopGrid
      ? AppBreakpoints.detailGalleryHeightDesktop
      : AppBreakpoints.detailGalleryHeightMobile;

  Widget _image(String url, {bool hero = false}) {
    final image = CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    if (hero && widget.heroTag != null) {
      return AppHero(tag: widget.heroTag!, child: image);
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    final cs = context.cs;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (urls.isEmpty)
            ColoredBox(
              color: cs.surfaceContainerHighest,
              child: Icon(
                widget.emptyIcon ?? Icons.image_outlined,
                size: 48.sp,
                color: cs.onSurfaceVariant,
              ),
            )
          else if (_isDesktopGrid)
            _DesktopPhotoGrid(urls: urls, heroTag: widget.heroTag)
          else if (urls.length == 1)
            _image(urls.first, hero: true)
          else
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: urls.length,
              itemBuilder: (context, index) => _image(urls[index], hero: index == 0),
            ),
          if (widget.toolbar != null) widget.toolbar!,
          if (_isDesktopGrid && urls.length > 1 && widget.onShowAllPhotos != null)
            Positioned(
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: _ShowAllPhotosButton(onPressed: widget.onShowAllPhotos!),
            ),
          if (!_isDesktopGrid && urls.length > 1)
            DetailGalleryCounter(current: _index + 1, total: urls.length),
        ],
      ),
    );
  }
}

class _ShowAllPhotosButton extends StatelessWidget {
  const _ShowAllPhotosButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Material(
      color: cs.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: AppShapes.sm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppShapes.sm,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.layoutGrid, size: 16.sp, color: cs.onSurface),
              AppGap.h(AppSpacing.sm),
              Text('Lihat semua foto', style: context.textTitleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopPhotoGrid extends StatelessWidget {
  const _DesktopPhotoGrid({required this.urls, this.heroTag});

  final List<String> urls;
  final String? heroTag;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final radius = AppShapes.md.topLeft.x;

    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: AppShapes.md,
        child: _cell(urls.first, hero: true),
      );
    }

    if (urls.length == 2) {
      return Row(
        children: [
          Expanded(child: _roundedCell(urls[0], hero: true, topLeft: radius, bottomLeft: radius)),
          const SizedBox(width: _gap),
          Expanded(child: _roundedCell(urls[1], topRight: radius, bottomRight: radius)),
        ],
      );
    }

    final extras = urls.take(5).toList();
    while (extras.length < 5) {
      extras.add(extras.last);
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _roundedCell(
            extras[0],
            hero: true,
            topLeft: radius,
            bottomLeft: radius,
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _roundedCell(extras[1], topRight: radius)),
                    const SizedBox(width: _gap),
                    Expanded(child: _cell(extras[2])),
                  ],
                ),
              ),
              const SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _cell(extras[3])),
                    const SizedBox(width: _gap),
                    Expanded(child: _roundedCell(extras[4], bottomRight: radius)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String url, {bool hero = false}) {
    final image = CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    if (hero && heroTag != null) {
      return AppHero(tag: heroTag!, child: image);
    }
    return image;
  }

  Widget _roundedCell(
    String url, {
    bool hero = false,
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      ),
      child: _cell(url, hero: hero),
    );
  }
}
