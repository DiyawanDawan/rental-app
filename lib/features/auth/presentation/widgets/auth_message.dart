import 'package:flutter/material.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';

class AuthMessage extends StatelessWidget {
  const AuthMessage({
    required this.message,
    this.isError = true,
    super.key,
  });

  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return SizedBox.shrink();
    }

    final color = isError ? AppColors.critical : AppColors.statusAvailable;

    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: AppShapes.sm,
      ),
      child: Text(
        message!,
        style: AppTextStyles.bodySmall.copyWith(color: color),
      ),
    );
  }
}
