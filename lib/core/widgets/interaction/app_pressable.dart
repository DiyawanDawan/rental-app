import 'package:flutter/material.dart';

import '../../../config/motion.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';

/// Tap feedback organik — scale + shadow. Bungkus card, tile, atau custom CTA.
class AppPressable extends StatefulWidget {
  const AppPressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.enabled = true,
    this.scale = AppMotion.cardPressScale,
    this.showShadowOnPress = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final bool enabled;
  final double scale;
  final bool showShadowOnPress;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppShapes.md;

    return AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: AppMotion.fast,
      curve: AppMotion.enter,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        decoration: widget.showShadowOnPress && _pressed
            ? BoxDecoration(
                borderRadius: radius,
                boxShadow: AppShapes.cardShadow(opacity: 0.14),
              )
            : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            onLongPress: widget.enabled ? widget.onLongPress : null,
            onHighlightChanged: widget.enabled ? (v) => setState(() => _pressed = v) : null,
            borderRadius: radius,
            splashColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
            highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
