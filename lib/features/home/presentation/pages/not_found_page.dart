import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.mapPinOff, size: 64.sp, color: AppColors.mediumGray),
              AppGap.lg,
              Text('404', style: AppTextStyles.headlineLarge),
              AppGap.sm,
              Text(
                'Halaman yang Anda cari tidak ditemukan.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null && message!.isNotEmpty) ...[
                AppGap.sm,
                Text(message!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              ],
              AppGap.v(AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutePaths.home),
                icon: Icon(LucideIcons.house),
                label: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
