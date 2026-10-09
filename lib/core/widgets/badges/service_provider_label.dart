import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import '../layout/listing_card_typography.dart';

/// Baris penyedia layanan — selalu tampil di card listing/detail.
///
/// Mitra terverifikasi: ikon toko + nama + centang biru (dekat nama, bukan pojok).
/// Belum terverifikasi: ikon toko + nama (tanpa centang biru).
class ServiceProviderLabel extends StatelessWidget {
  const ServiceProviderLabel({
    required this.name,
    this.isVerified = false,
    this.compact = false,
    this.maxLines = 1,
    super.key,
  });

  final String name;
  final bool isVerified;
  final bool compact;
  final int maxLines;

  factory ServiceProviderLabel.fromMitra({
    String? storeName,
    String? alternateName,
    bool isVerified = false,
    bool compact = false,
    int maxLines = 1,
  }) {
    final resolved = _resolveName(storeName, alternateName);
    return ServiceProviderLabel(
      name: resolved,
      isVerified: isVerified,
      compact: compact,
      maxLines: maxLines,
    );
  }

  static String _resolveName(String? storeName, String? alternateName) {
    final store = storeName?.trim();
    if (store != null && store.isNotEmpty) return store;
    final alt = alternateName?.trim();
    if (alt != null && alt.isNotEmpty) return alt;
    return 'Mitra Travelindo';
  }

  double get _gap =>
      compact ? ListingCardTypography.providerIconGap : AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? ListingCardTypography.metaIconSize : 14.0;
    final muted = context.cs.onSurfaceVariant;
    final textStyle = compact
        ? ListingCardTypography.body(
            context.textCardMeta.copyWith(color: muted),
          )
        : context.textCardMeta.copyWith(color: muted);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.store,
          size: iconSize,
          color: muted,
        ),
        SizedBox(width: _gap),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: textStyle,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerified) ...[
                  SizedBox(width: _gap),
                  Icon(
                    LucideIcons.badgeCheck,
                    size: iconSize,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
