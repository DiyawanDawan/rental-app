import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/breakpoints.dart';

/// Skala [ScreenUtil] yang aman di tablet/desktop — cegah font 120px di monitor lebar.
abstract final class AppScreenScale {
  /// [designSize] dinamis: desktop = 1:1 logical pixel, mobile = 375×812.
  static Size designSizeFor(double width, double height) {
    if (width >= AppBreakpoints.tablet) {
      return Size(width, height);
    }
    if (width >= AppBreakpoints.mobile) {
      return const Size(600, 800);
    }
    return const Size(375, 812);
  }

  static double fontSize(num fontSize, ScreenUtil util) {
    if (util.screenWidth >= AppBreakpoints.tablet) {
      return fontSize.toDouble();
    }
    if (util.screenWidth >= AppBreakpoints.mobile) {
      final scale = (util.screenWidth / 375).clamp(1.0, 1.12);
      return fontSize * scale;
    }
    return FontSizeResolvers.width(fontSize, util);
  }
}
