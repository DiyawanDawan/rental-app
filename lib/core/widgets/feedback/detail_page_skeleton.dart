import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/decorations.dart';
import '../../../config/spacing.dart';
import 'shimmer_loading.dart';

/// Placeholder shimmer untuk halaman detail dengan SliverAppBar.
class DetailPageSkeleton extends StatelessWidget {
  const DetailPageSkeleton({
    this.expandedHeight = 240,
    super.key,
  });

  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppDecorations.shimmerMid),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: double.infinity, height: 24.h),
                  SizedBox(height: AppSpacing.md),
                  AppShimmerBox(width: double.infinity, height: 14.h),
                  SizedBox(height: AppSpacing.xs),
                  AppShimmerBox(width: 260.w, height: 14.h),
                  SizedBox(height: AppSpacing.section),
                  AppShimmerBox(width: 140.w, height: 18.h),
                  SizedBox(height: AppSpacing.sm),
                  AppShimmerBox(width: double.infinity, height: 12.h),
                  SizedBox(height: AppSpacing.xs),
                  AppShimmerBox(width: 220.w, height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
