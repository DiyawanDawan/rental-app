import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';
import '../../../config/spacing.dart';

/// Scroll view aman untuk form auth/booking di landscape + keyboard terbuka.
///
/// **Mengapa bukan [IntrinsicHeight]:** di dalam scroll view, intrinsic height
/// memaksa layout penuh dan memicu overflow. Gunakan [CustomScrollView] + sliver.
class KeyboardAwareScrollView extends StatelessWidget {
  const KeyboardAwareScrollView({
    required this.children,
    super.key,
    this.padding,
    this.physics,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.landscapeMaxWidth = 520,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final double landscapeMaxWidth;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final safePadding = MediaQuery.paddingOf(context);
    final keyboardOpen = viewInsets.bottom > 0;
    final isLandscapeNarrow = context.isLandscapeNarrow;

    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(
          AppSpacing.xl,
          keyboardOpen || isLandscapeNarrow ? AppSpacing.sm : AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl + viewInsets.bottom + safePadding.bottom,
        );

    Widget content = CustomScrollView(
      physics: physics,
      keyboardDismissBehavior: keyboardDismissBehavior,
      slivers: [
        SliverPadding(
          padding: resolvedPadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
      ],
    );

    if (isLandscapeNarrow) {
      content = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: landscapeMaxWidth),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Inset bawah untuk form dengan sticky bar + keyboard (booking checkout).
double keyboardAwareBottomInset(
  BuildContext context, {
  double extra = 0,
  double stickyBarHeight = 72,
}) {
  final mq = MediaQuery.of(context);
  return mq.viewInsets.bottom + mq.padding.bottom + stickyBarHeight + extra;
}
