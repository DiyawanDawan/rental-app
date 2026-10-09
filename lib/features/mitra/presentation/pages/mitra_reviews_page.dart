import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';

class MitraReviewsPage extends StatefulWidget {
  const MitraReviewsPage({super.key});

  @override
  State<MitraReviewsPage> createState() => _MitraReviewsPageState();
}

class _MitraReviewsPageState extends State<MitraReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadReviewsSummary();
    });
  }

  Future<void> _replyToReview(String reviewId) async {
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balas Review'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Tulis balasan...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reply == null || reply.isEmpty || !mounted) return;

    final success = await context.read<MitraService>().replyReview(
      reviewId,
      reply,
    );
    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Balasan terkirim');
      context.read<MitraService>().loadReviewsSummary();
    } else {
      SnackbarUtils.showError(context, 'Gagal mengirim balasan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Pelanggan')),
      body: Consumer<MitraService>(
        builder: (context, service, child) {
          if (service.status == MitraStatus.loading &&
              service.reviews.isEmpty) {
            return const AppLoadingView();
          }

          if (service.reviews.isEmpty) {
            return const AppEmptyState(
              icon: LucideIcons.star,
              title: 'Belum ada review',
              message: 'Review dari pelanggan akan muncul di sini.',
            );
          }

          return ListView.separated(
            padding: AppPadding.list,
            itemCount: service.reviews.length,
            separatorBuilder: (_, __) => AppGap.v(AppSpacing.listGap),
            itemBuilder: (context, index) {
              final review = service.reviews[index];
              final id = review.id;
              final reply = review.mitraReply;
              final hasReply = reply != null && reply.isNotEmpty;

              return StaggeredListItem(
                index: index,
                child: Container(
                  decoration: AppDecorations.floatingCard(),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: AppPadding.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (review.customerAvatarUrl != null) ...[
                              CircleAvatar(
                                backgroundImage: NetworkImage(review.customerAvatarUrl!),
                                radius: 12.sp,
                              ),
                              AppGap.sm,
                            ],
                            Expanded(
                              child: Text(
                                review.customerName ?? 'Pelanggan',
                                style: AppTextStyles.titleSmall,
                              ),
                            ),
                            Icon(
                              LucideIcons.star,
                              color: AppColors.rating,
                              size: 16.sp,
                            ),
                            AppGap.h(AppSpacing.xs),
                            Text(
                              '${review.rating}',
                              style: AppTextStyles.titleSmall,
                            ),
                          ],
                        ),
                        AppGap.xs,
                        Text(
                          'Kendaraan: ${review.vehicleName ?? '-'}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusUnavailable),
                        ),
                        AppGap.sm,
                        Text(
                          review.comment ?? '-',
                          style: AppTextStyles.bodySmall,
                        ),
                        if (hasReply) ...[
                          AppGap.sm,
                          Container(
                            padding: AppPadding.card,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Balasan Anda: $reply',
                              style: AppTextStyles.labelSmall,
                            ),
                          ),
                        ],
                        if (!hasReply && id.isNotEmpty) ...[
                          AppGap.sm,
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _replyToReview(id),
                              child: const Text('Balas'),
                            ),
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
