import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';

/// Membatasi lebar konten + margin kiri/kanan sama besar (Airbnb-style).
///
/// Margin luar = [AppBreakpoints.shellSideMargin] (≥600px).
/// Padding dalam = [AppBreakpoints.pageInset] — ringan di tablet, 40px di monitor lebar.
class PageWidthContainer extends StatelessWidget {
  const PageWidthContainer({
    required this.child,
    this.padding,
    this.applyPageInset = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Padding horizontal dalam kotak shell ([pageInset]).
  final bool applyPageInset;

  static double maxContentBoxWidth(double screenWidth) {
    return AppBreakpoints.shellContentBoxWidth(screenWidth);
  }

  static double listingRowWidthInsideShell(double screenWidth) {
    return AppBreakpoints.shellListingRowWidth(screenWidth);
  }

  static double boxWidthFor({
    required double screenWidth,
    required double parentWidth,
  }) {
    if (screenWidth < AppBreakpoints.mobile) {
      return parentWidth;
    }
    return math.min(parentWidth, maxContentBoxWidth(screenWidth));
  }

  static double sideMargin({
    required double parentWidth,
    required double boxWidth,
  }) {
    return math.max(0.0, (parentWidth - boxWidth) / 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth;
        if (!parentWidth.isFinite || parentWidth <= 0) {
          return child;
        }

        final screenWidth = MediaQuery.sizeOf(context).width;
        final boxWidth = boxWidthFor(
          screenWidth: screenWidth,
          parentWidth: parentWidth,
        );
        final margin = sideMargin(
          parentWidth: parentWidth,
          boxWidth: boxWidth,
        );

        final inset = AppBreakpoints.pageInset(screenWidth);
        final innerPadding = padding ??
            (applyPageInset && screenWidth >= AppBreakpoints.mobile
                ? EdgeInsets.symmetric(horizontal: inset)
                : EdgeInsets.zero);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: margin),
          child: SizedBox(
            width: boxWidth,
            child: Padding(
              padding: innerPadding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Padding horizontal standar halaman list/detail — ikut [AppBreakpoints.pageInset].
class PageHorizontalInsets extends StatelessWidget {
  const PageHorizontalInsets({
    required this.child,
    this.vertical,
    super.key,
  });

  final Widget child;
  final double? vertical;

  @override
  Widget build(BuildContext context) {
    final inset = context.pageInset;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: inset,
        vertical: vertical ?? 0,
      ),
      child: child,
    );
  }
}
