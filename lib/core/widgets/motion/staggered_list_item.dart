import 'package:flutter/material.dart';

import '../../../config/motion.dart';

/// Fade + slide masuk untuk item list (max 6 item pertama).
class StaggeredListItem extends StatelessWidget {
  const StaggeredListItem({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  static const _maxStagger = 6;
  static const _staggerStepMs = 40;

  @override
  Widget build(BuildContext context) {
    if (index >= _maxStagger) return RepaintBoundary(child: child);

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: AppMotion.medium + Duration(milliseconds: index * _staggerStepMs),
        curve: AppMotion.enter,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 12 * value),
          child: Opacity(opacity: 1 - value, child: child),
        ),
        child: child,
      ),
    );
  }
}
