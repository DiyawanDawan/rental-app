import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/breakpoints.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';

/// Tombol teks + ikon ala Airbnb (Share / Simpan).
class DetailTextAction extends StatelessWidget {
  const DetailTextAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: cs.onSurface,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: context.textTitleSmall.copyWith(decoration: TextDecoration.underline),
      ),
    );
  }
}

/// Judul besar + aksi kanan — **di atas** galeri foto (Airbnb desktop).
class DetailPageTitleBar extends StatelessWidget {
  const DetailPageTitleBar({
    required this.title,
    this.actions = const [],
    super.key,
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.detailUsesSidebar ? AppSpacing.lg : AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!context.detailUsesSidebar) ...[
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(LucideIcons.arrowLeft, size: 22.sp),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            AppGap.h(AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: context.detailUsesSidebar
                  ? context.textHeadlineLarge.copyWith(fontWeight: FontWeight.w700, height: 1.15)
                  : context.textHeadlineMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (actions.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xs,
              children: actions,
            ),
        ],
      ),
    );
  }
}

/// Blok pembuka konten di bawah galeri — lead + meta (Airbnb: "Entire home in…").
class DetailLeadBlock extends StatelessWidget {
  const DetailLeadBlock({
    required this.lead,
    required this.meta,
    this.rating,
    this.reviewCount,
    super.key,
  });

  final String lead;
  final String meta;
  final double? rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final hasRating = rating != null && (rating! > 0 || (reviewCount ?? 0) > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lead, style: context.textTitleLarge.copyWith(fontWeight: FontWeight.w600)),
        if (meta.isNotEmpty) ...[
          AppGap.titleToSubtitle,
          Text(meta, style: context.textBodyMedium),
        ],
        if (hasRating) ...[
          AppGap.titleToSubtitle,
          Row(
            children: [
              Icon(LucideIcons.star, size: 14.sp, color: cs.onSurface),
              AppGap.h(AppSpacing.xs),
              Text(rating!.toStringAsFixed(1), style: context.textTitleSmall),
              if ((reviewCount ?? 0) > 0) ...[
                Text(' · ', style: context.textBodySmall),
                Text(
                  '${reviewCount!} ulasan',
                  style: context.textBodySmall.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        ],
        const DetailSectionDivider(),
      ],
    );
  }
}

/// Satu baris highlight dengan ikon (Airbnb "Top 5% of homes").
class DetailHighlightRow extends StatelessWidget {
  const DetailHighlightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.sp, color: context.cs.onSurface),
          AppGap.h(AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTitleSmall.copyWith(fontWeight: FontWeight.w600)),
                AppGap.xs,
                Text(subtitle, style: context.textBodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol bulat di atas hero image (mobile).
class DetailOverlayButton extends StatelessWidget {
  const DetailOverlayButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isDark = context.isDarkTheme;

    return Material(
      color: isDark ? cs.surface.withValues(alpha: 0.92) : cs.surface.withValues(alpha: 0.95),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 20.sp, color: iconColor ?? cs.onSurface),
        visualDensity: VisualDensity.compact,
        constraints: BoxConstraints.tightFor(width: 40.w, height: 40.w),
      ),
    );
  }
}

/// Toolbar mengambang di hero (mobile): back kiri.
class DetailHeroToolbar extends StatelessWidget {
  const DetailHeroToolbar({
    this.actions = const [],
    super.key,
  });

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (context.detailUsesSidebar) return const SizedBox.shrink();

    final top = MediaQuery.paddingOf(context).top + AppSpacing.sm;

    return Stack(
      children: [
        Positioned(
          top: top,
          left: AppSpacing.page,
          child: DetailOverlayButton(
            icon: LucideIcons.arrowLeft,
            tooltip: 'Kembali',
            onPressed: () => context.pop(),
          ),
        ),
        if (actions.isNotEmpty)
          Positioned(
            top: top,
            right: AppSpacing.page,
            child: Row(mainAxisSize: MainAxisSize.min, children: actions),
          ),
      ],
    );
  }
}

/// Badge "1 / 5" (mobile carousel).
class DetailGalleryCounter extends StatelessWidget {
  const DetailGalleryCounter({
    required this.current,
    required this.total,
    super.key,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();

    final cs = context.cs;

    return Positioned(
      right: AppSpacing.page,
      bottom: AppSpacing.lg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: 0.72),
          borderRadius: AppShapes.pill,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Text(
            '$current / $total',
            style: context.textBodySmall.copyWith(
              color: cs.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class DetailSectionDivider extends StatelessWidget {
  const DetailSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
      child: Divider(
        height: 1,
        thickness: 1,
        color: context.cs.outline.withValues(alpha: context.isDarkTheme ? 0.35 : 0.28),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  const DetailSection({
    required this.title,
    required this.child,
    this.showDivider = true,
    super.key,
  });

  final String title;
  final Widget child;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTitleMedium.copyWith(fontWeight: FontWeight.w600)),
        AppGap.sectionTitleToContent,
        child,
        if (showDivider) const DetailSectionDivider(),
      ],
    );
  }
}

class DetailHostRow extends StatelessWidget {
  const DetailHostRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            leading ??
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Icon(LucideIcons.store, size: 20.sp, color: cs.onSurfaceVariant),
                ),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Disediakan $title', style: context.textTitleSmall.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    AppGap.xxs,
                    Text(subtitle!, style: context.textBodySmall),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(LucideIcons.chevronRight, size: 18.sp, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class DetailExpandableText extends StatefulWidget {
  const DetailExpandableText({
    required this.text,
    this.maxLines = 5,
    super.key,
  });

  final String text;
  final int maxLines;

  @override
  State<DetailExpandableText> createState() => _DetailExpandableTextState();
}

class _DetailExpandableTextState extends State<DetailExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final showToggle = widget.text.length > 160;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: context.textBodyMedium.copyWith(height: 1.55),
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (showToggle) ...[
          AppGap.md,
          OutlinedButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurface,
              side: BorderSide(color: cs.onSurface),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            ),
            child: Text(
              _expanded ? 'Sembunyikan' : 'Tampilkan lebih banyak',
              style: context.textTitleSmall,
            ),
          ),
        ],
      ],
    );
  }
}

/// Judul section di bawah galeri (kompatibilitas).
class DetailTitleHeader extends StatelessWidget {
  const DetailTitleHeader({
    required this.title,
    this.subtitle,
    this.rating,
    this.reviewCount,
    super.key,
  });

  final String title;
  final String? subtitle;
  final double? rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return DetailLeadBlock(
      lead: title,
      meta: subtitle ?? '',
      rating: rating,
      reviewCount: reviewCount,
    );
  }
}
