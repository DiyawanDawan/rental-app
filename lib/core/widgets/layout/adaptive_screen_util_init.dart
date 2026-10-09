import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/screen_scale.dart';

/// [ScreenUtilInit] dengan skala aman di layar lebar — font/spacing tidak meledak di desktop.
class AdaptiveScreenUtilInit extends StatelessWidget {
  const AdaptiveScreenUtilInit({
    required this.builder,
    required this.child,
    super.key,
  });

  final ScreenUtilInitBuilder builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final physicalSize = view.physicalSize / view.devicePixelRatio;

    return ScreenUtilInit(
      designSize: AppScreenScale.designSizeFor(physicalSize.width, physicalSize.height),
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: AppScreenScale.fontSize,
      builder: builder,
      child: child,
    );
  }
}
