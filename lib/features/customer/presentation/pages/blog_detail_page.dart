import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/media/app_cached_network_image.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../../../core/widgets/motion/content_reveal.dart';
import '../../application/customer_service.dart';
import '../../data/models/blog_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlogDetailPage extends StatefulWidget {
  const BlogDetailPage({required this.slug, super.key});

  final String slug;

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  late Future<BlogModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerService>().getBlogBySlug(widget.slug);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BlogModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: AppLoadingView());
        }

        final blog = snapshot.data;
        if (blog == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Artikel')),
            body: const Center(child: Text('Artikel tidak ditemukan.')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 240.h,
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(
                    start: AppSpacing.page,
                    end: AppSpacing.page,
                    bottom: AppSpacing.md,
                  ),
                  title: Text(
                    blog.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.surface),
                  ),
                  background: blog.imageUrl != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            AppHero(
                              tag: AppHeroTags.blogImage(blog.slug),
                              child: AppCachedNetworkImage(
                                imageUrl: blog.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.overlayScrim.withValues(alpha: 0.1),
                                    AppColors.overlayScrimHeavy,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ColoredBox(color: AppColors.lightGray),
                ),
              ),
              SliverToBoxAdapter(
                child: ContentReveal(
                  child: Padding(
                  padding: AppPadding.screen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.category != null)
                        Text(
                          blog.category!.toUpperCase(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (blog.category != null) AppGap.sm,
                      Text(blog.title, style: AppTextStyles.headlineMedium),
                      AppGap.v(AppSpacing.xxl),
                      Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 14.sp, color: AppColors.lightGray),
                          AppGap.h(AppSpacing.xs),
                          Text(
                            _formatBlogDate(blog.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                          ),
                          if (blog.authorName != null) ...[
                            AppGap.h(AppSpacing.sm),
                            Text('·', style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
                            AppGap.h(AppSpacing.sm),
                            Text(
                              blog.authorName!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                            ),
                          ],
                        ],
                      ),
                      AppGap.v(AppSpacing.xxl),
                      const Divider(),
                      AppGap.v(AppSpacing.xxl),
                      Text(
                        blog.content ?? 'Tidak ada konten.',
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                      ),
                      AppGap.v(AppSpacing.xxl),
                    ],
                  ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatBlogDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw.split('T')[0];
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
