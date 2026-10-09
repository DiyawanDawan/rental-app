import 'package:flutter/material.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/layout/keyboard_aware_scroll_view.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isLandscapeNarrow = MediaQuery.orientationOf(context) == Orientation.landscape &&
        MediaQuery.sizeOf(context).height < 500;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: KeyboardAwareScrollView(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            SizedBox(height: keyboardOpen || isLandscapeNarrow ? AppSpacing.sm : AppSpacing.xxl),
            Text(
              'Travelindo',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.orange),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.displaySmall),
            SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: AppTextStyles.bodyMedium),
            SizedBox(height: keyboardOpen || isLandscapeNarrow ? AppSpacing.md : AppSpacing.section),
            ...children,
          ],
        ),
      ),
    );
  }
}
