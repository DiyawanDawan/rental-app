import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';

enum HomeSearchBarVariant { standard, header }

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    HomeSearchBarVariant variant = HomeSearchBarVariant.standard,
  }) : _variant = variant;

  final HomeSearchBarVariant _variant;

  @override
  Widget build(BuildContext context) {
    if (_variant == HomeSearchBarVariant.header) {
      return _HeaderSearchBar(onTap: () => context.push(AppRoutePaths.search));
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppShapes.md,
        onTap: () => context.push(AppRoutePaths.search),
        child: IgnorePointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari mobil, wisata, travel, artikel...',
              prefixIcon: const Icon(LucideIcons.search),
              filled: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// Search ringkas di header desktop — satu baris, tanpa efek "expanded search".
class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.cs;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: AppShapes.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.pill,
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppShapes.pill,
            border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.search, size: 20, color: colors.onSurfaceVariant),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Cari kendaraan, wisata, travel...',
                  style: context.textBodyMedium.copyWith(color: colors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
