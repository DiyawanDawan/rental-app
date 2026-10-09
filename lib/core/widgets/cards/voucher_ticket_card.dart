import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/motion.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';

/// Status visual voucher pada tiket.
enum VoucherTicketStatus {
  /// Siap dipakai saat checkout.
  available,

  /// Sudah diklaim / pernah digunakan.
  claimed,

  /// Melewati tanggal kedaluwarsa.
  expired,
}

/// Kartu voucher bentuk tiket sungguhan — notch sisi & garis perforasi tengah.
///
/// Gunakan di halaman daftar voucher atau bottom sheet pemilihan promo.
class VoucherTicketCard extends StatefulWidget {
  const VoucherTicketCard({
    required this.title,
    required this.voucherCode,
    required this.expiryDate,
    required this.status,
    this.discountLabel,
    this.subtitle,
    this.onTap,
    this.onCopy,
    super.key,
  });

  final String title;
  final String voucherCode;
  final String expiryDate;
  final VoucherTicketStatus status;
  final String? discountLabel;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onCopy;

  @override
  State<VoucherTicketCard> createState() => _VoucherTicketCardState();
}

class _VoucherTicketCardState extends State<VoucherTicketCard> {
  bool _pressed = false;

  bool get _isInactive =>
      widget.status == VoucherTicketStatus.claimed ||
      widget.status == VoucherTicketStatus.expired;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isDark = context.isDarkTheme;

    final surfaceColor = isDark ? cs.surfaceContainerHighest : AppColors.surface;
    final borderColor = _isInactive
        ? cs.outline.withValues(alpha: 0.35)
        : AppColors.promoPrimary.withValues(alpha: 0.28);

    return AnimatedScale(
      scale: _pressed ? AppMotion.cardPressScale : 1,
      duration: AppMotion.fast,
      curve: AppMotion.enter,
      child: GestureDetector(
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        onTap: _isInactive ? null : widget.onTap,
        child: Opacity(
          opacity: _isInactive ? 0.62 : 1,
          child: ClipPath(
            clipper: VoucherTicketClipper(
              notchRadius: 10.r,
              cornerRadius: AppShapes.cardRadius,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: borderColor, width: 1),
                boxShadow: _isInactive ? null : AppDecorations.softShadow(opacity: 0.08, blur: 16, offsetY: 4),
              ),
              child: CustomPaint(
                painter: _VoucherPerforationPainter(
                  splitFraction: 0.28,
                  color: cs.outline.withValues(alpha: 0.45),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StubSection(
                        discountLabel: widget.discountLabel,
                        status: widget.status,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTitleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                AppGap.xs,
                                Text(
                                  widget.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textBodySmall,
                                ),
                              ],
                              AppGap.sm,
                              _CodeChip(
                                code: widget.voucherCode,
                                enabled: !_isInactive,
                                onCopy: widget.onCopy,
                              ),
                              AppGap.sm,
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 14.sp,
                                    color: context.cs.onSurfaceVariant,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      'Berlaku hingga ${widget.expiryDate}',
                                      style: context.textBodySmall,
                                    ),
                                  ),
                                  _StatusPill(status: widget.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StubSection extends StatelessWidget {
  const _StubSection({
    required this.discountLabel,
    required this.status,
  });

  final String? discountLabel;
  final VoucherTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final gradient = status == VoucherTicketStatus.expired
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.cs.outline.withValues(alpha: 0.25),
              context.cs.outline.withValues(alpha: 0.15),
            ],
          )
        : AppColors.promoLinearGradient;

    return SizedBox(
      width: 0.28.sw.clamp(88.0, 120.0),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.ticket,
                color: AppColors.promoOnGradient,
                size: 22.sp,
              ),
              AppGap.xs,
              Text(
                discountLabel ?? 'PROMO',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: AppColors.promoOnGradient,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({
    required this.code,
    required this.enabled,
    this.onCopy,
  });

  final String code;
  final bool enabled;
  final VoidCallback? onCopy;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    onCopy?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bg = enabled
        ? AppColors.promoContainer
        : context.cs.surfaceContainerHighest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _copy(context) : null,
        borderRadius: AppShapes.sm,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppShapes.sm,
            border: Border.all(
              color: enabled
                  ? AppColors.promoPrimary.withValues(alpha: 0.22)
                  : context.cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                code,
                style: context.textLabelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: enabled ? AppColors.promoDeep : context.cs.onSurfaceVariant,
                ),
              ),
              if (enabled) ...[
                SizedBox(width: AppSpacing.xs),
                Icon(LucideIcons.copy, size: 14.sp, color: AppColors.promoDeep),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final VoucherTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      VoucherTicketStatus.available => (
          'Siap Pakai',
          AppColors.success,
          AppColors.success.withValues(alpha: 0.12),
        ),
      VoucherTicketStatus.claimed => (
          'Diklaim',
          AppColors.neutral500,
          AppColors.neutral500.withValues(alpha: 0.12),
        ),
      VoucherTicketStatus.expired => (
          'Hangus',
          AppColors.error,
          AppColors.error.withValues(alpha: 0.12),
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppShapes.pill,
      ),
      child: Text(
        label,
        style: context.textBodySmall.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Clipper tiket — lubang setengah lingkaran kiri/kanan pada garis tengah vertikal.
class VoucherTicketClipper extends CustomClipper<Path> {
  VoucherTicketClipper({
    required this.notchRadius,
    required this.cornerRadius,
  });

  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final centerY = size.height / 2;
    final r = notchRadius;
    final cr = cornerRadius;

    path.moveTo(cr, 0);
    path.lineTo(size.width - cr, 0);
    path.arcToPoint(Offset(size.width, cr), radius: Radius.circular(cr));
    path.lineTo(size.width, centerY - r);
    path.arcToPoint(
      Offset(size.width, centerY + r),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - cr);
    path.arcToPoint(Offset(size.width - cr, size.height), radius: Radius.circular(cr));
    path.lineTo(cr, size.height);
    path.arcToPoint(Offset(0, size.height - cr), radius: Radius.circular(cr));
    path.lineTo(0, centerY + r);
    path.arcToPoint(
      Offset(0, centerY - r),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(0, cr);
    path.arcToPoint(Offset(cr, 0), radius: Radius.circular(cr));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant VoucherTicketClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius || oldClipper.cornerRadius != cornerRadius;
}

/// Garis perforasi putus-putus vertikal di zona pemisah stub ↔ detail.
class _VoucherPerforationPainter extends CustomPainter {
  _VoucherPerforationPainter({
    required this.splitFraction,
    required this.color,
  });

  final double splitFraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * splitFraction;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const gap = 4.0;
    var y = AppSpacing.sm;

    while (y < size.height - AppSpacing.sm) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _VoucherPerforationPainter oldDelegate) =>
      oldDelegate.splitFraction != splitFraction || oldDelegate.color != color;
}
