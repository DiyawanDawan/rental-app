import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';

/// Welcome banner on mitra dashboard.
class MitraWelcomeCard extends StatelessWidget {
  const MitraWelcomeCard({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.screen,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: AppShapes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selamat Datang,', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted)),
          AppGap.xs,
          Text(name, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.onDark)),
        ],
      ),
    );
  }
}
