import 'package:flutter/material.dart';

import '../../../config/spacing.dart';
import '../../../config/text_styles.dart';

/// Teks aman di dalam [Row] — selalu dibungkus [Flexible] + ellipsis.
class SafeText extends StatelessWidget {
  const SafeText(
    this.data, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.semanticsLabel,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
    );
  }
}

/// Teks di [Row] yang WAJIB dibungkus [Flexible]/[Expanded].
class FlexibleText extends StatelessWidget {
  const FlexibleText(
    this.data, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.flex = 1,
    this.fit = FlexFit.loose,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final int flex;
  final FlexFit fit;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: fit,
      child: SafeText(
        data,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      ),
    );
  }
}

/// Baris label–nilai (harga tiket, subtotal) — anti RenderFlex overflow.
class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    required this.label,
    required this.value,
    super.key,
    this.labelStyle,
    this.valueStyle,
    this.labelFlex = 2,
    this.valueFlex = 3,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final int labelFlex;
  final int valueFlex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: labelFlex,
            child: SafeText(
              label,
              style: labelStyle ?? AppTextStyles.bodySmall,
              maxLines: 2,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: valueFlex,
            child: SafeText(
              value,
              style: valueStyle ?? AppTextStyles.bodyMedium,
              maxLines: 2,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Harga di card — shrink font otomatis jika ruang sempit (aksesibilitas).
class AdaptivePriceText extends StatelessWidget {
  const AdaptivePriceText(
    this.price, {
    super.key,
    this.style,
    this.maxLines = 1,
  });

  final String price;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? AppTextStyles.cardPrice;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useFitted = constraints.maxWidth.isFinite && constraints.maxWidth < 120;
        final text = SafeText(
          price,
          style: resolved,
          maxLines: maxLines,
          textAlign: TextAlign.end,
        );
        if (!useFitted) return text;
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: text,
        );
      },
    );
  }
}
