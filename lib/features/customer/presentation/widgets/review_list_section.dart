import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/customer_service.dart';
import '../../data/models/review_model.dart';

/// Vehicle reviews list section with loading and empty states.
class ReviewListSection extends StatefulWidget {
  const ReviewListSection({
    required this.vehicleId,
    this.embedded = false,
    super.key,
  });

  final String vehicleId;
  final bool embedded;

  @override
  State<ReviewListSection> createState() => _ReviewListSectionState();
}

class _ReviewListSectionState extends State<ReviewListSection> {
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = context.read<CustomerService>().getVehicleReviews(widget.vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.embedded) ...[
          Text('Ulasan', style: context.textTitleMedium),
          AppGap.md,
        ],
        FutureBuilder<List<ReviewModel>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingView();
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Text(
                'Belum ada review untuk kendaraan ini.',
                style: context.textBodySmall,
              );
            }

            return Column(
              children: reviews.map((review) => ReviewItem(review: review)).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Review rental kendaraan milik satu mitra (semua armada).
class MitraReviewListSection extends StatefulWidget {
  const MitraReviewListSection({required this.mitraId, super.key});

  final String mitraId;

  @override
  State<MitraReviewListSection> createState() => _MitraReviewListSectionState();
}

class _MitraReviewListSectionState extends State<MitraReviewListSection> {
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = context.read<CustomerService>().getMitraReviews(widget.mitraId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Rental Kendaraan', style: context.textTitleMedium),
        AppGap.xs,
        Text(
          'Ulasan pelanggan untuk armada rental motor/mobil mitra ini.',
          style: context.textBodySmall,
        ),
        AppGap.md,
        FutureBuilder<List<ReviewModel>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingView();
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Text(
                'Belum ada review rental untuk mitra ini.',
                style: context.textBodySmall,
              );
            }

            return Column(
              children: reviews.map((review) => ReviewItem(review: review)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  const ReviewItem({required this.review, super.key});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null ? Icon(LucideIcons.user, size: 14.sp) : null,
              ),
              AppGap.h(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName ?? 'Pelanggan', style: context.textTitleSmall),
                    if (review.vehicleLabel != null)
                      Text(review.vehicleLabel!, style: context.textCardMeta),
                  ],
                ),
              ),
              ...List.generate(
                5,
                (index) => Icon(
                  LucideIcons.star,
                  size: 12.sp,
                  color: index < review.rating
                      ? context.cs.onSurface
                      : context.cs.outline.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            AppGap.xs,
            Text(review.comment!, style: context.textBodySmall),
          ],
          if (review.reply != null) ...[
            AppGap.sm,
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.cs.surfaceContainerHighest,
                borderRadius: AppShapes.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balasan Mitra:',
                    style: context.textBodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.xxs,
                  Text(review.reply!, style: context.textBodySmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
