import 'package:flutter/material.dart';

import '../../../config/decorations.dart';
import '../../../config/motion.dart';
import '../../../config/shapes.dart';

/// Ink splash + elastic scale — micro-interaction premium (Traveloka/Airbnb tier).
///
/// Gabungan [InkWell] meresap + [AnimatedScale] bounce halus saat ditekan.
class AnimatedInkWell extends StatefulWidget {
  const AnimatedInkWell({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.borderRadius,
    this.enabled = true,
    this.scale = AppMotion.pressScale,
    this.duration = AppMotion.fast,
    this.curve = AppMotion.curveOrganic,
    this.splashColor,
    this.highlightColor,
    this.showPressedShadow = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;
  final BorderRadius? borderRadius;
  final bool enabled;
  final double scale;
  final Duration duration;
  final Curve curve;
  final Color? splashColor;
  final Color? highlightColor;
  final bool showPressedShadow;

  @override
  State<AnimatedInkWell> createState() => _AnimatedInkWellState();
}

class _AnimatedInkWellState extends State<AnimatedInkWell> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppShapes.md;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        decoration: widget.showPressedShadow && _pressed
            ? BoxDecoration(
                borderRadius: radius,
                boxShadow: AppDecorations.softShadowElevated(opacity: 0.1),
              )
            : null,
        child: Material(
          type: MaterialType.transparency,
          clipBehavior: Clip.none,
          surfaceTintColor: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            onLongPress: widget.enabled ? widget.onLongPress : null,
            onTapDown: widget.enabled
                ? (d) {
                    _setPressed(true);
                    widget.onTapDown?.call(d);
                  }
                : null,
            onTapUp: widget.enabled
                ? (d) {
                    _setPressed(false);
                    widget.onTapUp?.call(d);
                  }
                : null,
            onTapCancel: widget.enabled
                ? () {
                    _setPressed(false);
                    widget.onTapCancel?.call();
                  }
                : null,
            onHighlightChanged: widget.enabled ? _setPressed : null,
            borderRadius: radius,
            splashColor: widget.splashColor ?? scheme.secondary.withValues(alpha: 0.16),
            highlightColor: widget.highlightColor ?? scheme.primary.withValues(alpha: 0.08),
            hoverColor: Colors.transparent,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
