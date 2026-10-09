import 'package:flutter/material.dart';

/// Hero wrapper — Material transparan mencegah flash putih saat flight.
class AppHero extends StatelessWidget {
  const AppHero({
    required this.tag,
    required this.child,
    super.key,
  });

  final Object tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
