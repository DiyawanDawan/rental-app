import 'package:flutter/material.dart';

import '../../../config/spacing.dart';
import '../buttons/app_buttons.dart';

/// Sticky bottom bar dengan dua CTA — destinasi detail (tour + travel).
class StickyDualActionBar extends StatelessWidget {
  const StickyDualActionBar({
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    super.key,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: isDark ? 0 : 6,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0 : 0.14),
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: isDark
          ? RoundedRectangleBorder(
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.35)),
            )
          : null,
      child: SafeArea(
        minimum: EdgeInsets.all(AppSpacing.ctaBar),
        child: Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: secondaryLabel,
                fullWidth: true,
                onPressed: onSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppPrimaryButton(
                label: primaryLabel,
                fullWidth: true,
                onPressed: onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
