import 'package:flutter/material.dart';

import '../../../config/breakpoints.dart';
import '../../../config/theme_context.dart';
import '../../../config/decorations.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../buttons/app_buttons.dart';
import 'sticky_price_bar.dart';

/// Kartu booking kanan desktop — pola Airbnb.
class DetailBookingCard extends StatelessWidget {
  const DetailBookingCard({
    this.price = '',
    required this.buttonLabel,
    required this.onPressed,
    this.priceLine,
    this.priceLabel = 'Mulai dari',
    this.priceSuffix,
    this.footnote = 'Anda belum dikenakan biaya',
    this.feeBanner,
    this.fields,
    this.infoBanner,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  final String priceLabel;
  final String price;
  final String? priceSuffix;
  /// Satu baris harga ala "Rp X for 2 nights" — override price+suffix jika diisi.
  final String? priceLine;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final String? footnote;
  final String? feeBanner;
  final List<DetailBookingField>? fields;
  final String? infoBanner;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final canTap = enabled && !isLoading && onPressed != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (feeBanner != null) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: AppShapes.md,
              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 16, color: cs.secondary),
                  AppGap.h(AppSpacing.sm),
                  Expanded(child: Text(feeBanner!, style: context.textBodySmall)),
                ],
              ),
            ),
          ),
          AppGap.sm,
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppShapes.lg,
            border: Border.all(color: cs.outline.withValues(alpha: context.isDarkTheme ? 0.35 : 0.22)),
            boxShadow: AppDecorations.cardShadowForTheme(context),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (priceLine != null)
                  Text(
                    priceLine!,
                    style: context.textTitleMedium.copyWith(fontWeight: FontWeight.w700),
                  )
                else ...[
                  Text(priceLabel, style: context.textTertiary),
                  AppGap.xs,
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: AppSpacing.xs,
                    children: [
                      Text(
                        price,
                        style: context.textTitleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.onSurface,
                        ),
                      ),
                      if (priceSuffix != null)
                        Text(priceSuffix!, style: context.textBodyMedium),
                    ],
                  ),
                ],
                if (fields != null && fields!.isNotEmpty) ...[
                  AppGap.lg,
                  _FieldsBox(fields: fields!),
                ],
                if (infoBanner != null) ...[
                  AppGap.md,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: AppShapes.sm,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text(infoBanner!, style: context.textBodySmall),
                    ),
                  ),
                ],
                AppGap.lg,
                AppPrimaryButton(
                  label: buttonLabel,
                  onPressed: canTap ? onPressed : null,
                  isLoading: isLoading,
                  fullWidth: true,
                ),
                if (footnote != null) ...[
                  AppGap.sm,
                  Text(footnote!, style: context.textBodySmall, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DetailBookingField {
  const DetailBookingField({required this.label, required this.value});

  final String label;
  final String value;
}

class _FieldsBox extends StatelessWidget {
  const _FieldsBox({required this.fields});

  final List<DetailBookingField> fields;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final border = BorderSide(color: cs.outline.withValues(alpha: 0.45));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppShapes.sm,
        border: Border.fromBorderSide(border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: cs.outline.withValues(alpha: 0.35)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fields[i].label.toUpperCase(),
                          style: context.textBodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.4,
                          ),
                        ),
                        AppGap.xxs,
                        Text(fields[i].value, style: context.textBodyMedium),
                      ],
                    ),
                  ),
                  if (i == fields.length - 1)
                    Icon(Icons.expand_more, size: 20, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DetailMobileBookingBar extends StatelessWidget {
  const DetailMobileBookingBar({
    required this.price,
    required this.buttonLabel,
    required this.onPressed,
    this.priceLabel = 'Mulai dari',
    this.priceSuffix,
    super.key,
  });

  final String priceLabel;
  final String price;
  final String? priceSuffix;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (context.detailUsesSidebar) return const SizedBox.shrink();

    final bar = StickyPriceBar(
      priceLabel: priceLabel,
      price: price,
      priceSuffix: priceSuffix,
      buttonLabel: buttonLabel,
      onPressed: onPressed,
    );

    if (context.screenWidth >= AppBreakpoints.mobile) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.detailShellMaxWidth),
          child: bar,
        ),
      );
    }

    return bar;
  }
}
