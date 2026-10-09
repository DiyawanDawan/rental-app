import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/badges/status_badge.dart';
import '../../data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.isSelected = false,
    super.key,
  });

  final AddressModel address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: AppDecorations.floatingCard().copyWith(
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.border, width: 1),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Pin & Badges
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.mapPin,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
                AppGap.h(AppSpacing.sm),
                Expanded(
                  child: Text(
                    address.regencyName ?? address.countryName ?? 'Alamat',
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryDeep),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (address.hasCoordinates) ...[
                  AppGap.h(AppSpacing.xs),
                  StatusBadge(
                    label: 'GPS Aktif',
                    color: AppColors.tertiary,
                  ),
                ],
              ],
            ),
            AppGap.sm,

            // Full Address text
            Text(
              address.fullAddress,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppGap.xs,

            // Administrative hierarchy
            if (address.formattedHierarchy.isNotEmpty) ...[
              Text(
                address.formattedHierarchy,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
              AppGap.xs,
            ],

            // ZipCode
            if (address.zipCode != null && address.zipCode!.isNotEmpty) ...[
              Text(
                'Kode Pos: ${address.zipCode}',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
              ),
            ],

            AppGap.md,
            const Divider(height: 1, color: AppColors.border),
            AppGap.xs,

            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: Icon(LucideIcons.pencil, size: 16.sp, color: AppColors.primary),
                    label: Text(
                      'Ubah',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    ),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(LucideIcons.trash2, size: 16.sp, color: AppColors.error),
                    label: Text(
                      'Hapus',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
