import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/feedback/shimmer_loading.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/hero_tags.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/media/app_cached_network_image.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/router/router_query_mixin.dart';
import '../../application/customer_service.dart';
import '../../data/models/blog_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> with RouterQueryMixin {
  late Future<List<BlogModel>> _future;
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    final category = queryParameters['category'];
    if (category != null && category.isNotEmpty) {
      _selectedCategory = category;
    }
    final q = queryParameters['q'] ?? queryParameters['search'];
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
    }
    _future = context.read<CustomerService>().getBlogs(category: _selectedCategory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BlogModel> _filtered(List<BlogModel> blogs) {
    var result = blogs;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (b) =>
                b.title.toLowerCase().contains(query) ||
                (b.excerpt ?? '').toLowerCase().contains(query) ||
                (b.category ?? '').toLowerCase().contains(query),
          )
          .toList();
    }
    if (_selectedCategory != null) {
      result = result.where((b) => b.category == _selectedCategory).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel & Tips')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.pageTop, AppSpacing.page, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari artikel...',
                prefixIcon: Icon(LucideIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(LucideIcons.x, size: 16.sp),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BlogModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppShimmerLoading(itemCount: 5);
                }

                final allBlogs = snapshot.data ?? [];
                final categories = allBlogs
                    .map((b) => b.category)
                    .whereType<String>()
                    .where((c) => c.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();

                final blogs = _filtered(allBlogs);
                if (allBlogs.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.newspaper,
                    title: 'Belum ada artikel',
                    message: 'Tips perjalanan dan artikel akan tampil di sini.',
                  );
                }

                return Column(
                  children: [
                    if (categories.isNotEmpty)
                      SizedBox(
                        height: 48.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
                          children: [
                            FilterChip(
                              label: const Text('Semua'),
                              selected: _selectedCategory == null,
                              onSelected: (_) => setState(() => _selectedCategory = null),
                            ),
                            ...categories.map(
                              (c) => Padding(
                                padding: EdgeInsets.only(left: AppSpacing.sm),
                                child: FilterChip(
                                  label: Text(c),
                                  selected: _selectedCategory == c,
                                  onSelected: (_) => setState(() => _selectedCategory = c),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: blogs.isEmpty
                          ? AppEmptyState(
                              icon: LucideIcons.searchX,
                              title: 'Tidak ditemukan',
                              message: 'Coba kata kunci atau kategori lain.',
                              actionLabel: 'Reset',
                              onAction: () => setState(() {
                                _selectedCategory = null;
                                _searchController.clear();
                              }),
                            )
                          : ListView.separated(
                              padding: AppPadding.list,
                              itemCount: blogs.length,
                              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.listGap),
                              itemBuilder: (context, index) => StaggeredListItem(
                                index: index,
                                child: _BlogCard(blog: blogs[index]),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw.split('T')[0];
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _BlogCard extends StatelessWidget {
  const _BlogCard({required this.blog});
  final BlogModel blog;

  Future<void> _openDetail(BuildContext context) async {
    await precacheNetworkImageUrl(context, blog.imageUrl);
    if (!context.mounted) return;
    context.push(AppRoutePaths.blogDetail(blog.slug));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: () => _openDetail(context),
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCard(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imageUrl != null)
              AppHero(
                tag: AppHeroTags.blogImage(blog.slug),
                child: AppCachedNetworkImage(
                  imageUrl: blog.imageUrl!,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(height: 180.h, color: AppColors.lightGray, child: Icon(LucideIcons.image)),
            Padding(
              padding: AppPadding.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (blog.category != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      margin: EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.1),
                        borderRadius: AppShapes.xxs,
                      ),
                      child: Text(
                        blog.category!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Text(blog.title, style: AppTextStyles.titleMedium),
                  AppGap.titleToSubtitle,
                  if (blog.excerpt != null)
                    Text(
                      blog.excerpt!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  AppGap.sectionTitleToContent,
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 14.sp, color: AppColors.lightGray),
                      AppGap.h(AppSpacing.xs),
                      Text(
                        _formatDate(blog.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                      ),
                      if (blog.authorName != null) ...[
                        AppGap.h(AppSpacing.sm),
                        Text('·', style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
                        AppGap.h(AppSpacing.sm),
                        Expanded(
                          child: Text(
                            blog.authorName!,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

