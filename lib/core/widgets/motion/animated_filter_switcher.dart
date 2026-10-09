import 'package:flutter/material.dart';

import '../../../config/motion.dart';

/// Fade konten saat filter berubah — 200ms easeOutCubic.
class AnimatedFilterSwitcher extends StatelessWidget {
  const AnimatedFilterSwitcher({
    required this.filterKey,
    required this.child,
    super.key,
  });

  final Object filterKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey(filterKey),
        child: child,
      ),
    );
  }
}
