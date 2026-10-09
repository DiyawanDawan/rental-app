import 'package:flutter/material.dart';

import '../../../config/text_styles.dart';
import '../text/overflow_safe.dart';

/// Label/value row used in booking cost breakdowns and detail sections.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.isBold = false,
    super.key,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return LabelValueRow(
      label: label,
      value: value,
      labelStyle: AppTextStyles.bodySmall,
      valueStyle: valueStyle ??
          (isBold ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium),
    );
  }
}
