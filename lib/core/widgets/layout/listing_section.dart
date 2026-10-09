import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/breakpoints.dart';
import '../../../config/motion.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import 'listing_card_metrics.dart';

typedef ListingCarouselItemBuilder = Widget Function(
  BuildContext context,
  int index,
  double cardWidth,
);

/// Section home ala Airbnb — judul + panah + carousel horizontal mengisi lebar baris.
class ListingSection extends StatefulWidget {
  const ListingSection({
    required this.title,
    required this.itemCount,
    required this.textBlockHeight,
    required this.itemBuilder,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.empty,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int itemCount;
  final double textBlockHeight;
  final ListingCarouselItemBuilder itemBuilder;
  final Widget? empty;

  @override
  State<ListingSection> createState() => _ListingSectionState();
}

class _ListingSectionState extends State<ListingSection> {
  final _scrollController = ScrollController();
  bool _canScrollBack = false;
  bool _canScrollForward = false;
  double _cardWidth = AppBreakpoints.listingCardWidth;
  double _spacing = AppSpacing.md;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollButtons());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncScrollButtons() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final back = position.pixels > 4;
    final forward = position.pixels < position.maxScrollExtent - 4;
    if (back != _canScrollBack || forward != _canScrollForward) {
      setState(() {
        _canScrollBack = back;
        _canScrollForward = forward;
      });
    }
  }

  void _scrollByPage() {
    if (!_scrollController.hasClients) return;
    final slots = context.listingCarouselVisibleCount;
    final delta = (_cardWidth + _spacing) * slots;
    final target = (_scrollController.offset + delta)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: AppMotion.medium,
      curve: AppMotion.enter,
    );
  }

  void _scrollBackPage() {
    if (!_scrollController.hasClients) return;
    final slots = context.listingCarouselVisibleCount;
    final delta = (_cardWidth + _spacing) * slots;
    final target = (_scrollController.offset - delta)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: AppMotion.medium,
      curve: AppMotion.enter,
    );
  }

  bool get _canScroll =>
      widget.itemCount > context.listingCarouselVisibleCount;

  @override
  Widget build(BuildContext context) {
    final showControls =
        widget.itemCount > 0 && context.screenWidth >= AppBreakpoints.tablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: widget.onAction != null
                  ? InkWell(
                      onTap: widget.onAction,
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.title,
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
                    )
                  : Text(
                      widget.title,
                      style: context.textTitleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            if (showControls) ...[
              _CarouselArrow(
                icon: LucideIcons.chevronLeft,
                enabled: _canScrollBack,
                onPressed: _scrollBackPage,
              ),
              AppGap.h(AppSpacing.xs),
              _CarouselArrow(
                icon: LucideIcons.chevronRight,
                enabled: _canScrollForward,
                onPressed: _scrollByPage,
              ),
            ],
          ],
        ),
        if (widget.subtitle != null) ...[
          AppGap.sectionTitleToContent,
          Text(widget.subtitle!, style: context.textBodySmall),
        ],
        AppGap.sectionTitleToContent,
        if (widget.itemCount == 0)
          widget.empty ?? const SizedBox.shrink()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              _spacing = AppSpacing.md;
              _cardWidth = AppBreakpoints.listingCellWidthForViewport(
                constraints.maxWidth,
                screenWidth: context.screenWidth,
                itemCount: widget.itemCount,
                spacing: _spacing,
              );
              final rowHeight = ListingCardMetrics.totalHeight(
                _cardWidth,
                textBlockHeight: widget.textBlockHeight,
                includeCarouselBuffer: true,
              );

              return SizedBox(
                height: rowHeight,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  physics: _canScroll
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: widget.itemCount,
                  separatorBuilder: (_, __) => SizedBox(width: _spacing),
                  itemBuilder: (context, index) => SizedBox(
                    width: _cardWidth,
                    height: rowHeight,
                    child: widget.itemBuilder(context, index, _cardWidth),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.cs;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: enabled ? 1 : 0.5),
      shape: const CircleBorder(),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18, color: colors.onSurface),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppShapes.pill),
        ),
      ),
    );
  }
}

/// Carousel horizontal mandiri — dipakai di halaman list non-section.
class ListingCarousel extends StatelessWidget {
  const ListingCarousel({
    required this.itemCount,
    required this.textBlockHeight,
    required this.itemBuilder,
    super.key,
  });

  final int itemCount;
  final double textBlockHeight;
  final ListingCarouselItemBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppSpacing.sm;
        final cardWidth = AppBreakpoints.listingCellWidthForViewport(
          constraints.maxWidth,
          screenWidth: context.screenWidth,
          itemCount: itemCount,
          spacing: spacing,
        );
        final rowHeight = ListingCardMetrics.totalHeight(
          cardWidth,
          textBlockHeight: textBlockHeight,
          includeCarouselBuffer: true,
        );
        final canScroll =
            itemCount > context.listingCarouselVisibleCount;

        return SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 4),
            physics: canScroll
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              height: rowHeight,
              child: itemBuilder(context, index, cardWidth),
            ),
          ),
        );
      },
    );
  }
}
