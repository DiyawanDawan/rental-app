import 'package:flutter/material.dart';

/// Custom TextScaler that applies an additional scale factor on top of
/// the system's text scaling preference.
///
/// Usage in [ScreenUtilInit] builder:
/// ```dart
/// builder: (context, child) {
///   final mediaQueryData = MediaQuery.of(context);
///   return MediaQuery(
///     data: mediaQueryData.copyWith(
///       textScaler: CustomTextScaler(mediaQueryData.textScaler, 1.08),
///     ),
///     child: child!,
///   );
/// }
/// ```
class CustomTextScaler extends TextScaler {
  final TextScaler parent;
  final double scaleFactor;

  const CustomTextScaler(this.parent, this.scaleFactor);

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => parent.textScaleFactor * scaleFactor;

  @override
  double scale(double fontSize) {
    return parent.scale(fontSize) * scaleFactor;
  }
}
