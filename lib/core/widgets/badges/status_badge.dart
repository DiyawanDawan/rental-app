import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

/// Generic colored label badge.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppShapes.xxs,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Booking/order status badge using centralized color mapping.
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({required this.status, super.key});

  final String status;

  static String labelFor(String status) => switch (status.toUpperCase()) {
        'PENDING' => 'Pending',
        'AWAITING_PAYMENT' => 'Menunggu Bayar',
        'CONFIRMED' => 'Dikonfirmasi',
        'APPROVED' => 'Disetujui',
        'HANDOVER' || 'HANDED_OVER' || 'ACTIVE' || 'ONGOING' => 'Dalam Pemakaian',
        'COMPLETED' || 'RETURNED' => 'Selesai',
        'CANCELLED' => 'Dibatalkan',
        'REJECTED' => 'Ditolak',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: labelFor(status),
      color: AppColors.bookingStatus(status),
    );
  }
}

/// Active/inactive fleet status badge.
class ActiveStatusBadge extends StatelessWidget {
  const ActiveStatusBadge({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: isActive ? 'Aktif' : 'Nonaktif',
      color: isActive ? AppColors.success : AppColors.darkGray,
    );
  }
}
