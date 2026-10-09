import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';
import 'page_width_container.dart';

/// Reusable layout wrapper — memilih UI berdasarkan lebar viewport.
///
/// Hanya satu branch yang di-build per frame sehingga state sibling tidak ikut
/// ter-mount. Gunakan [KeyedSubtree] di parent jika perlu mempertahankan state
/// saat resize window.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= AppBreakpoints.desktopLayoutMinWidth) {
          return desktop ?? tablet ?? mobile;
        }
        if (width >= AppBreakpoints.mobile) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Membatasi lebar konten dan menempatkannya di tengah — mencegah UI melar di desktop.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth,
    this.padding,
    super.key,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final inset = context.pageInset;
    final screenWidth = context.screenWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseBox = PageWidthContainer.boxWidthFor(
          screenWidth: screenWidth,
          parentWidth: constraints.maxWidth,
        );
        final boxWidth = maxWidth != null
            ? baseBox.clamp(0.0, maxWidth!)
            : baseBox;
        final margin = PageWidthContainer.sideMargin(
          parentWidth: constraints.maxWidth,
          boxWidth: boxWidth,
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: margin),
          child: SizedBox(
            width: boxWidth,
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: inset),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
