import 'package:flutter/material.dart';

import '../../../config/spacing.dart';

/// Consistent scroll padding for FAB overlap and system insets.
class ScrollSafePadding {
  const ScrollSafePadding._();

  /// Extra bottom padding when a [FloatingActionButton] is present.
  static EdgeInsets withFab({double? horizontal, double? top, double extra = 0}) {
    final h = horizontal ?? AppSpacing.page;
    return EdgeInsets.fromLTRB(h, top ?? 0, h, AppSpacing.fabListClearance + extra);
  }

  /// Bottom inset for sticky bars (maps, onboarding controls).
  static double bottomInset(BuildContext context, {double? extra}) {
    return MediaQuery.paddingOf(context).bottom + (extra ?? AppSpacing.page);
  }

  /// Padding for modal bottom sheets (keyboard + home indicator).
  static EdgeInsets sheetPadding(BuildContext context, {double? horizontal, double? vertical}) {
    final h = horizontal ?? AppSpacing.xl;
    final v = vertical ?? AppSpacing.xl;
    final mq = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(h, v, h, mq.viewInsets.bottom + mq.padding.bottom + v);
  }
}
