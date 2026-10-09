import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../config/breakpoints.dart';
import '../../../config/theme_context.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import 'page_width_container.dart';

/// Layout detail Airbnb — judul di atas galeri, konten kiri, booking sticky kanan.
class DetailResponsiveScaffold extends StatefulWidget {
  const DetailResponsiveScaffold({
    required this.titleBar,
    required this.gallery,
    required this.lead,
    required this.body,
    required this.bookingCard,
    this.footer,
    this.bottomScrollPadding = 0,
    this.sidebarAnchorExtra = 0,
    super.key,
  });

  final Widget titleBar;
  final Widget gallery;
  final Widget lead;
  final Widget body;
  final Widget bookingCard;
  final Widget? footer;
  final double bottomScrollPadding;
  final double sidebarAnchorExtra;

  @override
  State<DetailResponsiveScaffold> createState() => _DetailResponsiveScaffoldState();
}

class _DetailResponsiveScaffoldState extends State<DetailResponsiveScaffold> {
  final _scrollController = ScrollController();
  double _sidebarTop = AppSpacing.lg;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateSidebarPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSidebarPosition());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateSidebarPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSidebarPosition() {
    if (!context.detailUsesSidebar) return;

    final anchor = _sidebarAnchor(context);
    final offset = _scrollController.offset;
    setState(() {
      _sidebarTop = math.max(AppSpacing.lg, anchor - offset);
    });
  }

  double _sidebarAnchor(BuildContext context) {
    final galleryHeight = context.detailUsesSidebar
        ? AppBreakpoints.detailGalleryHeightDesktop
        : AppBreakpoints.detailGalleryHeightMobile;
    // Perkiraan tinggi title bar + jarak ke konten split.
    return galleryHeight + 88 + widget.sidebarAnchorExtra;
  }

  @override
  Widget build(BuildContext context) {
    final useSidebar = context.detailUsesSidebar;

    if (!useSidebar) {
      return PageWidthContainer(
        applyPageInset: false,
        padding: EdgeInsets.symmetric(horizontal: context.pageInset),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: _buildSlivers(useSidebar: false),
        ),
      );
    }

    return PageWidthContainer(
      applyPageInset: false,
      padding: EdgeInsets.symmetric(horizontal: context.pageInset),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: _buildSlivers(useSidebar: true),
          ),
          Positioned(
            top: _sidebarTop,
            right: 0,
            width: AppBreakpoints.detailBookingCardWidth,
            child: widget.bookingCard,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlivers({required bool useSidebar}) {
    final sidebarGap = useSidebar
        ? AppBreakpoints.detailBookingCardWidth + AppSpacing.xxl + AppSpacing.sm
        : 0.0;

    return [
      SliverToBoxAdapter(child: widget.titleBar),
      SliverToBoxAdapter(child: widget.gallery),
      SliverPadding(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: widget.bottomScrollPadding + AppSpacing.xxl,
        ),
        sliver: SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.lead,
                    widget.body,
                    if (widget.footer != null) ...[
                      AppGap.section,
                      widget.footer!,
                    ],
                  ],
                ),
              ),
              if (useSidebar) SizedBox(width: sidebarGap),
            ],
          ),
        ),
      ),
    ];
  }
}
