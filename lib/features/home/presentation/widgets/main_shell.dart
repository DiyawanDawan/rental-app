import 'package:flutter/material.dart';

import '../../../../core/widgets/layout/adaptive_navigation_scaffold.dart';

/// Backward-compatible alias — gunakan [AdaptiveNavigationScaffold] untuk kode baru.
class MainShell extends StatelessWidget {
  const MainShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(child: child);
  }
}
