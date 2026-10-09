import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../core/theme/component_themes.dart';

/// Kolom pencarian modern — filled, tanpa border kaku, radius 12..
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.controller,
    this.hintText = 'Cari destinasi, hotel, atau tiket...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: AppTextStyles.bodyMedium,
      decoration: AppComponentThemes.searchDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(LucideIcons.search, size: 20.sp),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(LucideIcons.x, size: 18.sp),
                onPressed: _clear,
              )
            : null,
      ),
    );
  }
}
