import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({
    this.playStoreUrl = 'https://play.google.com/store/apps/details?id=com.travelindo.app',
    this.appStoreUrl = 'https://apps.apple.com/app/travelindo',
    super.key,
  });

  final String playStoreUrl;
  final String appStoreUrl;

  Future<void> _openStore() async {
    final uri = Uri.parse(
      defaultTargetPlatform == TargetPlatform.iOS ? appStoreUrl : playStoreUrl,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
                Icon(LucideIcons.download, size: 72.sp, color: Theme.of(context).colorScheme.primary),
                AppGap.v(AppSpacing.xxl),
                Text('Update Diperlukan', style: AppTextStyles.headlineSmall),
                AppGap.md,
                Text(
                  'Versi aplikasi Anda sudah terlalu lama. Silakan update ke versi terbaru untuk terus menggunakan Travelindo.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                AppGap.ctaSpacer,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openStore,
                    child: const Text('Update Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
