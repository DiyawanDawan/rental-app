import 'package:flutter/material.dart';

import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/text_styles.dart';
import '../../../config/theme_context.dart';

/// Filter chip yang warnanya mengikuti [ColorScheme] aktif.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.onSelected,
    this.selected = false,
    super.key,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return FilterChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: cs.onPrimary,
      backgroundColor: cs.surfaceContainerHighest,
      selectedColor: cs.primary,
      labelStyle: AppTextStyles.badge.copyWith(
        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
      ),
      side: BorderSide(
        color: selected ? cs.primary : cs.outline.withValues(alpha: 0.65),
        width: 0.5,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
    );
  }
}
