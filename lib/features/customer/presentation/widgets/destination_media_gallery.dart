import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/color.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/motion.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../data/models/tourist_destination_model.dart';

/// Galeri detail destinasi — carousel utama + thumbnail strip horizontal.
class DestinationStaggeredGallery extends StatefulWidget {
  const DestinationStaggeredGallery({
    required this.media,
    super.key,
  });

  final List<DestinationMediaModel> media;

  @override
  State<DestinationStaggeredGallery> createState() => _DestinationStaggeredGalleryState();
}

class _DestinationStaggeredGalleryState extends State<DestinationStaggeredGallery> {
  late final PageController _pageController;
  int _index = 0;

  List<DestinationMediaModel> get _images =>
      widget.media.where((m) => m.isImage && m.url.isNotEmpty).toList();

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

  void _openViewer(BuildContext context, List<DestinationMediaModel> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        transitionDuration: AppMotion.medium,
        reverseTransitionDuration: AppMotion.fast,
        pageBuilder: (ctx, animation, secondaryAnimation) => _DestinationGalleryViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: AppMotion.medium,
      curve: AppMotion.move,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    if (images.isEmpty) {
      return Container(
        height: 260.h,
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
        decoration: BoxDecoration(
          color: context.cs.surfaceContainerHighest,
          borderRadius: AppShapes.lg,
        ),
        child: Icon(LucideIcons.mountain, size: 64.sp, color: AppColors.orange),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: AppShapes.lg,
            child: SizedBox(
              height: 260.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final item = images[index];
                      Widget image = CachedNetworkImage(
                        imageUrl: item.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                      if (index == 0) {
                        image = AppHero(
                          tag: AppHeroTags.destinationPhoto(item.url),
                          child: image,
                        );
                      }
                      return GestureDetector(
                        onTap: () => _openViewer(context, images, index),
                        child: image,
                      );
                    },
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _GalleryBadge(
                      icon: LucideIcons.expand,
                      label: _index == 0 ? 'Utama' : null,
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: _GalleryBadge(label: '${_index + 1}/${images.length}'),
                  ),
                  if (images.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: AppSpacing.md,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => AnimatedContainer(
                            duration: AppMotion.fast,
                            margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                            width: _index == i ? AppSpacing.lg : AppSpacing.xs,
                            height: AppSpacing.xs,
                            decoration: BoxDecoration(
                              color: _index == i
                                  ? AppColors.onDark
                                  : AppColors.onDark.withValues(alpha: 0.45),
                              borderRadius: AppShapes.pill,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (images.length > 1) ...[
            AppGap.sm,
            SizedBox(
              height: 76.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final selected = index == _index;
                  return GestureDetector(
                    onTap: () => _goToPage(index),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 76.w,
                      decoration: BoxDecoration(
                        borderRadius: AppShapes.sm,
                        border: Border.all(
                          color: selected ? AppColors.orange : context.cs.outline.withValues(alpha: 0.35),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: images[index].url,
                            fit: BoxFit.cover,
                          ),
                          if (index == 0)
                            Positioned(
                              left: AppSpacing.xs,
                              bottom: AppSpacing.xs,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.overlayScrim,
                                  borderRadius: AppShapes.xxs,
                                ),
                                child: Text(
                                  'Utama',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.onDark,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GalleryBadge extends StatelessWidget {
  const _GalleryBadge({this.icon, this.label});

  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null && icon == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.overlayScrim,
        borderRadius: AppShapes.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 12.sp, color: AppColors.onDark),
          if (icon != null && label != null) AppGap.h(AppSpacing.xs),
          if (label != null)
            Text(label!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onDark)),
        ],
      ),
    );
  }
}

class _DestinationGalleryViewer extends StatefulWidget {
  const _DestinationGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<DestinationMediaModel> images;
  final int initialIndex;

  @override
  State<_DestinationGalleryViewer> createState() => _DestinationGalleryViewerState();
}

class _DestinationGalleryViewerState extends State<_DestinationGalleryViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediaBackdrop,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0),
        foregroundColor: AppColors.onDark,
        title: Text('${_index + 1} / ${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.9,
            maxScale: 3,
            child: Center(
              child: AppHero(
              tag: AppHeroTags.destinationPhoto(widget.images[index].url),
              child: CachedNetworkImage(
                imageUrl: widget.images[index].url,
                fit: BoxFit.contain,
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}

class DestinationVideoSection extends StatelessWidget {
  const DestinationVideoSection({required this.videos, super.key});

  final List<DestinationMediaModel> videos;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video Wisata', style: context.textTitleMedium),
        AppGap.titleToSubtitle,
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            for (var i = 0; i < videos.length; i++)
              StaggeredGridTile.extent(
                crossAxisCellCount: i == 0 && videos.length > 1 ? 2 : 1,
                mainAxisExtent: i == 0 ? 160.h : 120.h,
                child: _VideoTile(video: videos[i]),
              ),
          ],
        ),
      ],
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video});
  final DestinationMediaModel video;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy,
      borderRadius: AppShapes.md,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(video.url);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.teal.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.circlePlay, size: 40.sp, color: AppColors.onDark),
                AppGap.titleToSubtitle,
                Text('Putar video', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Galeri foto di dalam card — geser horizontal + indikator titik.
class DestinationCardGalleryPreview extends StatefulWidget {
  const DestinationCardGalleryPreview({
    required this.media,
    this.height,
    this.expandToFill = false,
    this.maxPreviewImages = 5,
    super.key,
  });

  final List<DestinationMediaModel> media;
  final double? height;

  /// Isi parent (bento / listing bounded) — tanpa [AspectRatio] tetap.
  final bool expandToFill;

  /// Batas foto yang bisa di-swipe di preview card.
  final int maxPreviewImages;

  @override
  State<DestinationCardGalleryPreview> createState() =>
      _DestinationCardGalleryPreviewState();
}

class _DestinationCardGalleryPreviewState
    extends State<DestinationCardGalleryPreview> {
  late final PageController _controller;
  int _index = 0;

  List<String> get _urls => widget.media
      .where((m) => m.isImage)
      .map((m) => m.url)
      .take(widget.maxPreviewImages)
      .toList();

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wrapGallerySize({required Widget child}) {
    if (widget.height != null) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: child,
      );
    }
    if (widget.expandToFill) {
      return SizedBox(width: double.infinity, height: double.infinity, child: child);
    }

    return AspectRatio(
      aspectRatio: AppShapes.listingCardAspectRatio,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;

    if (urls.isEmpty) {
      return _wrapGallerySize(
        child: ColoredBox(
          color: context.cs.surfaceContainerHighest,
          child: Center(
            child: Icon(LucideIcons.mountain, size: 48.sp, color: AppColors.orange),
          ),
        ),
      );
    }

    if (urls.length == 1) {
      return _wrapGallerySize(
        child: CachedNetworkImage(imageUrl: urls.first, fit: BoxFit.cover),
      );
    }

    return _wrapGallerySize(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: urls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.sm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (i) => AnimatedContainer(
                  duration: AppMotion.fast,
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  width: _index == i ? AppSpacing.md : AppSpacing.xs,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? AppColors.onDark
                        : AppColors.onDark.withValues(alpha: 0.45),
                    borderRadius: AppShapes.pill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kolase foto di dalam card — campuran besar + kecil (bento dalam kolom).
class DestinationCardPhotoCollage extends StatelessWidget {
  const DestinationCardPhotoCollage({
    required this.media,
    this.maxCells = 4,
    this.variantIndex = 0,
    super.key,
  });

  final List<DestinationMediaModel> media;
  final int maxCells;

  /// Variasi layout antar kolom (0 = besar atas, 1 = besar kiri).
  final int variantIndex;

  List<String> get _urls => media
      .where((m) => m.isImage)
      .map((m) => m.url)
      .take(maxCells)
      .toList();

  @override
  Widget build(BuildContext context) {
    final urls = _urls;

    if (urls.isEmpty) {
      return ColoredBox(
        color: context.cs.surfaceContainerHighest,
        child: Center(
          child: Icon(LucideIcons.mountain, size: 40.sp, color: AppColors.orange),
        ),
      );
    }

    if (urls.length == 1) {
      return _cell(urls.first);
    }

    final gap = AppSpacing.xxs;
    return variantIndex.isOdd
        ? _layoutHeroLeft(urls, gap)
        : _layoutHeroTop(urls, gap);
  }

  /// Besar atas + kecil-kecil di bawah.
  Widget _layoutHeroTop(List<String> urls, double gap) {
    final thumbs = urls.skip(1).take(3).toList();

    return Column(
      children: [
        Expanded(
          flex: 12,
          child: _cell(urls.first),
        ),
        if (thumbs.isNotEmpty) ...[
          SizedBox(height: gap),
          Expanded(
            flex: 7,
            child: Row(
              children: [
                for (var i = 0; i < thumbs.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(child: _cell(thumbs[i])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Besar kiri + kecil-kecil menumpuk kanan.
  Widget _layoutHeroLeft(List<String> urls, double gap) {
    final thumbs = urls.skip(1).take(3).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _cell(urls.first),
        ),
        if (thumbs.isNotEmpty) ...[
          SizedBox(width: gap),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                for (var i = 0; i < thumbs.length; i++) ...[
                  if (i > 0) SizedBox(height: gap),
                  Expanded(child: _cell(thumbs[i])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _cell(String url) {
    return ClipRRect(
      borderRadius: AppShapes.xxs,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
