import 'package:flutter/material.dart';

import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import '../buttons/app_buttons.dart';

/// Sticky bottom bar — harga + CTA (pasar ID: "Mulai dari" + tombol bold).
class StickyPriceBar extends StatelessWidget {
  const StickyPriceBar({
    required this.price,
    required this.buttonLabel,
    required this.onPressed,
    this.priceLabel = 'Mulai dari',
    this.priceSuffix,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  final String priceLabel;
  final String price;
  final String? priceSuffix;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading && onPressed != null;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: cs.outline.withValues(alpha: isDark ? 0.4 : 0.22),
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: SafeArea(
          minimum: EdgeInsets.all(AppSpacing.ctaBar),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(priceLabel, style: context.textTertiary),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: context.textTitleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: cs.onSurface,
                            ),
                          ),
                          if (priceSuffix != null) ...[
                            SizedBox(width: AppSpacing.xs),
                            Text(priceSuffix!, style: context.textCardMeta),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 4,
                child: AppPrimaryButton(
                  label: buttonLabel,
                  onPressed: canTap ? onPressed : null,
                  isLoading: isLoading,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Padding bawah scroll agar konten tidak tertutup sticky bar.
double scrollBottomInsetForStickyBar(BuildContext context) {
  return AppSpacing.ctaBar * 2 + AppSpacing.buttonMinHeight + MediaQuery.paddingOf(context).bottom;
}
