import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../../../config/text_styles.dart';
import '../../application/customer_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CancellationPolicyPage extends StatelessWidget {
  const CancellationPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kebijakan Pembatalan')),
      body: FutureBuilder(
        future: context.read<CustomerService>().getCancellationPolicies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) return Center(child: Text('Kebijakan belum tersedia.'));

          return ListView.separated(
            padding: AppPadding.screen,
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.listGap),
            itemBuilder: (context, index) {
              final policy = list[index];
              return StaggeredListItem(
                index: index,
                child: Container(
                  decoration: AppDecorations.floatingCard(),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                  padding: AppPadding.list,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.shieldCheck, color: AppColors.orange, size: 20.sp),
                          AppGap.h(AppSpacing.sm),
                          Text(policy['name'] ?? 'Kebijakan', style: AppTextStyles.titleSmall),
                        ],
                      ),
                      AppGap.titleToSubtitle,
                      Text(policy['description'] ?? '', style: AppTextStyles.bodySmall),
                      if (policy['rules'] is List && (policy['rules'] as List).isNotEmpty) ...[
                        AppGap.md,
                        Text(
                          'Ketentuan Pengembalian:',
                          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppGap.xs,
                        ...((policy['rules'] as List).whereType<Map<String, dynamic>>().map((rule) {
                          final hours = rule['hours'] ?? 0;
                          final refund = rule['refundPercent'] ?? 0;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              children: [
                                Icon(LucideIcons.clock, size: 14.sp, color: AppColors.textSecondary),
                                AppGap.h(AppSpacing.xs),
                                Text(
                                  hours > 0 ? '> $hours jam sebelum: ' : 'Kurang dari batas waktu: ',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  '$refund% refund',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: (refund as num) > 0 ? AppColors.teal : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })),
                      ] else if (policy['refundPercentage'] != null) ...[
                        AppGap.md,
                        Text(
                          'Refund: ${policy['refundPercentage']}%',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
