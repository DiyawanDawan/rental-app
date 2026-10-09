import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';
import '../../../config/decorations.dart';
import '../../../config/motion.dart';

/// Wrapper hover desktop — lift halus + shadow saat kursor melintas.
///
/// Di mobile/touch, widget ini transparan (tidak mengubah perilaku tap).
class HoverContainer extends StatefulWidget {
  const HoverContainer({
    required this.child,
    super.key,
    this.onTap,
    this.onHover,
    this.enabled = true,
    this.borderRadius,
    this.hoverLift = 3,
    this.hoverShadowOpacity = 0.12,
    this.hoverBackgroundColor,
    this.duration = AppMotion.fast,
    this.curve = AppMotion.enter,
    this.enableHover,
  });

  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final bool enabled;
  final BorderRadius? borderRadius;
  final double hoverLift;
  final double hoverShadowOpacity;
  final Color? hoverBackgroundColor;
  final Duration duration;
  final Curve curve;

  /// `null` = otomatis aktif di tablet/desktop & web.
  final bool? enableHover;

  @override
  State<HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  bool _hovered = false;

  bool _resolveHover(BuildContext context) {
    if (widget.enableHover != null) return widget.enableHover!;
    if (kIsWeb) return true;
    return context.isTablet || context.isDesktop;
  }

  void _setHovered(bool value) {
    if (!_resolveHover(context) || !widget.enabled) return;
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHover?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final hoverEnabled = _resolveHover(context) && widget.enabled;
    final radius = widget.borderRadius;

    Widget result = AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      transform: Matrix4.translationValues(0, _hovered ? -widget.hoverLift : 0, 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: _hovered ? widget.hoverBackgroundColor : null,
        boxShadow: _hovered
            ? AppDecorations.softShadowElevated(opacity: widget.hoverShadowOpacity)
            : null,
      ),
      child: widget.child,
    );

    if (hoverEnabled) {
      result = MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: result,
      );
    }

    if (widget.onTap != null) {
      result = GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    return result;
  }
}
