import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/motion.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';

/// Badge diskon pill dengan micro-interaction glow — untuk sudut foto produk.
///
/// ```dart
/// Stack(
///   children: [
///     Image.network(...),
///     Positioned(
///       top: AppSpacing.sm,
///       left: AppSpacing.sm,
///       child: AnimatedBadgeDiscount(label: 'Diskon 20%'),
///     ),
///   ],
/// )
/// ```
class AnimatedBadgeDiscount extends StatefulWidget {
  const AnimatedBadgeDiscount({
    required this.label,
    this.compact = false,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool compact;
  final bool enabled;

  @override
  State<AnimatedBadgeDiscount> createState() => _AnimatedBadgeDiscountState();
}

class _AnimatedBadgeDiscountState extends State<AnimatedBadgeDiscount>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppMotion.leisurely,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.18, end: 0.42).animate(
      CurvedAnimation(parent: _pulseController, curve: AppMotion.move),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _BadgeBody(label: widget.label, compact: widget.compact, glowOpacity: 0);
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => _BadgeBody(
        label: widget.label,
        compact: widget.compact,
        glowOpacity: _glowAnimation.value,
      ),
    );
  }
}

class _BadgeBody extends StatelessWidget {
  const _BadgeBody({
    required this.label,
    required this.compact,
    required this.glowOpacity,
  });

  final String label;
  final bool compact;
  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    final horizontal = compact ? AppSpacing.sm : AppSpacing.md;
    final vertical = compact ? AppSpacing.xxs : AppSpacing.xs;

    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.enter,
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        gradient: AppColors.promoLinearGradient,
        borderRadius: AppShapes.pill,
        border: Border.all(
          color: AppColors.promoOnGradient.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.promoGlow.withValues(alpha: glowOpacity),
            blurRadius: 14.r,
            spreadRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
          BoxShadow(
            color: AppColors.promoDeep.withValues(alpha: glowOpacity * 0.35),
            blurRadius: 6.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.promoOnGradient,
          fontSize: compact ? 10.sp : 11.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          height: 1.1,
        ),
      ),
    );
  }
}
