import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.wrench, size: 72.sp, color: Theme.of(context).colorScheme.primary),
                AppGap.v(AppSpacing.xxl),
                Text('Sedang Pemeliharaan', style: AppTextStyles.headlineSmall),
                AppGap.md,
                Text(
                  message,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
