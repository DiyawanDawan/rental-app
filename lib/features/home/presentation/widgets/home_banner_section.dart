import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/motion.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/media/responsive_cover_image.dart';
import '../../../customer/data/models/banner_model.dart';
import 'promo_card.dart';

class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({required this.banners, super.key});

  final List<BannerModel> banners;

  static double _viewportFractionFor(double width) {
    if (width >= AppBreakpoints.tablet) return 0.48;
    if (width >= AppBreakpoints.mobile) return 0.88;
    return 1.0;
  }

  void _openBanner(BuildContext context, BannerModel banner) {
    if (banner.linkUrl == null || banner.linkUrl!.isEmpty) return;
    if (banner.linkUrl!.startsWith('http')) {
      launchUrl(Uri.parse(banner.linkUrl!), mode: LaunchMode.externalApplication);
    } else {
      context.push(banner.linkUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return Container(
        padding: AppPadding.list,
        decoration: AppDecorations.promoCard(),
        child: Text(
          'Promo dan rekomendasi perjalanan akan tampil di sini.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDark),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportFraction = _viewportFractionFor(constraints.maxWidth);
        final bannerHeight = constraints.maxWidth >= AppBreakpoints.tablet ? 220.0 : null;

        return _BannerCarousel(
          key: ValueKey(viewportFraction),
          banners: banners,
          viewportFraction: viewportFraction,
          fixedHeight: bannerHeight,
          onOpenBanner: (b) => _openBanner(context, b),
        );
      },
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({
    required this.banners,
    required this.viewportFraction,
    required this.onOpenBanner,
    this.fixedHeight,
    super.key,
  });

  final List<BannerModel> banners;
  final double viewportFraction;
  final double? fixedHeight;
  final ValueChanged<BannerModel> onOpenBanner;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _controller;
  Timer? _autoScroll;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScroll?.cancel();
    if (widget.banners.length <= 1) return;
    _autoScroll = Timer.periodic(AppMotion.bannerCarouselInterval, (_) => _nextBanner());
  }

  void _nextBanner() {
    if (!mounted || widget.banners.length <= 1) return;
    final next = (_current + 1) % widget.banners.length;
    _controller.animateToPage(
      next,
      duration: AppMotion.medium,
      curve: AppMotion.move,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageView = PageView.builder(
      controller: _controller,
      itemCount: widget.banners.length,
      onPageChanged: (i) {
        setState(() => _current = i);
        _startAutoScroll();
      },
      itemBuilder: (context, index) {
        final banner = widget.banners[index];
        return Padding(
          padding: EdgeInsets.only(right: AppSpacing.sm),
          child: PromoCard.fromBanner(
            banner,
            onTap: () => widget.onOpenBanner(banner),
          ),
        );
      },
    );

    return Column(
      children: [
        if (widget.fixedHeight != null)
          SizedBox(height: widget.fixedHeight, child: pageView)
        else
          AspectRatio(
            aspectRatio: ResponsiveImageFit.bannerAspectRatio(context),
            child: pageView,
          ),
        if (widget.banners.length > 1) ...[
          AppGap.sm,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (i) => AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.enter,
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                width: _current == i ? AppSpacing.lg : AppSpacing.xs,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: _current == i ? AppColors.accentWarm : AppColors.lightGray,
                  borderRadius: AppShapes.xxs,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
