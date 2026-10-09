import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../application/customer_service.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerService>().getFollowingMitra();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<CustomerService>().getFollowingMitra();
    });
    await _future;
  }

  Future<void> _openProfile(
    BuildContext context,
    String id,
    String? avatarUrl,
  ) async {
    await precacheNetworkImageUrl(context, avatarUrl);
    if (!context.mounted) return;
    context.push(AppRoutePaths.mitraPublicProfile(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mitra Diikuti')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: LucideIcons.store,
              title: 'Belum mengikuti mitra',
              message: 'Ikuti mitra favorit dari halaman profil toko.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: AppPadding.list,
              itemCount: items.length,
              separatorBuilder: (_, __) => AppGap.sm,
              itemBuilder: (context, index) {
                final mitra = items[index];
                final id = mitra['id']?.toString() ?? '';
                final storeName = mitra['storeName']?.toString() ?? 'Mitra';
                final avatarUrl = mitra['avatarUrl']?.toString();
                final vehicleCount = mitra['vehicleCount']?.toString() ?? '0';

                return StaggeredListItem(
                  index: index,
                  child: AnimatedInkWell(
                    onTap: id.isEmpty
                        ? null
                        : () => _openProfile(context, id, avatarUrl),
                    borderRadius: AppShapes.md,
                    child: Container(
                      decoration: AppDecorations.floatingCard(),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          AppHero(
                            tag: AppHeroTags.mitraAvatar(id),
                            child: CircleAvatar(
                              radius: 24.r,
                              backgroundColor: AppColors.lightGray,
                              backgroundImage:
                                  avatarUrl != null && avatarUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(avatarUrl)
                                  : null,
                              child: avatarUrl == null || avatarUrl.isEmpty
                                  ? Icon(
                                      LucideIcons.store,
                                      color: AppColors.navy,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  storeName,
                                  style: AppTextStyles.titleSmall,
                                ),
                                Text(
                                  '$vehicleCount kendaraan',
                                  style: AppTextStyles.cardMeta,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 18.sp,
                            color: AppColors.lightGray,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
