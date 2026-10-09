import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/motion.dart';
import '../../../../config/routes.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../../../core/widgets/motion/content_reveal.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/badges/verified_badge.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_grid.dart';
import '../../../../core/widgets/layout/listing_section.dart';
import '../../application/customer_service.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/tour_model.dart';
import '../widgets/review_list_section.dart';
import '../widgets/tour_package_card.dart';
import '../widgets/vehicle_card.dart';

class MitraPublicProfilePage extends StatefulWidget {
  const MitraPublicProfilePage({required this.mitraId, super.key});

  final String mitraId;

  @override
  State<MitraPublicProfilePage> createState() => _MitraPublicProfilePageState();
}

class _MitraPublicProfilePageState extends State<MitraPublicProfilePage> {
  late Future<Map<String, dynamic>?> _future;
  bool _followLoading = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<CustomerService>().getMitraPublicProfile(
      widget.mitraId,
    );
  }

  Future<void> _toggleFollow(Map<String, dynamic> profile) async {
    setState(() => _followLoading = true);
    final isFollowing = profile['isFollowing'] == true;
    final success = await context.read<CustomerService>().followMitra(
      widget.mitraId,
      follow: !isFollowing,
    );
    if (!mounted) return;
    setState(() => _followLoading = false);
    if (success) {
      setState(_reload);
    } else {
      SnackbarUtils.showError(context, 'Gagal memperbarui status follow');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final profile = snapshot.data;
          if (profile == null) {
            return AppErrorState(
              title: 'Profil tidak ditemukan',
              message: 'Mitra tidak tersedia atau sudah nonaktif.',
              onRetry: () => setState(_reload),
            );
          }

          final storeName = profile['storeName']?.toString() ?? 'Mitra';
          final isFollowing = profile['isFollowing'] == true;
          final isVerified = profile['isVerified'] == true;
          final avatarUrl = profile['avatarUrl']?.toString();
          final vehicles =
              (profile['vehicles'] as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .map(VehicleModel.fromJson)
                  .toList() ??
              [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                title: Text(storeName),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (profile['bannerUrl'] != null)
                        CachedNetworkImage(
                          imageUrl: profile['bannerUrl'].toString(),
                          fit: BoxFit.cover,
                        )
                      else
                        ColoredBox(
                          color: AppColors.navy.withValues(alpha: 0.1),
                        ),
                      Positioned(
                        left: AppSpacing.lg,
                        bottom: AppSpacing.md,
                        child: AppHero(
                          tag: AppHeroTags.mitraAvatar(widget.mitraId),
                          child: CircleAvatar(
                            radius: 36.r,
                            backgroundColor: AppColors.surface,
                            backgroundImage:
                                avatarUrl != null && avatarUrl.isNotEmpty
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Icon(
                                    LucideIcons.store,
                                    color: AppColors.navy,
                                    size: 28.sp,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ContentReveal(
                  child: Padding(
                    padding: AppPadding.list,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          storeName,
                                          style: AppTextStyles.headlineSmall,
                                        ),
                                      ),
                                      if (isVerified) ...[
                                        AppGap.h(AppSpacing.sm),
                                        const VerifiedBadge(),
                                      ],
                                    ],
                                  ),
                                  AppGap.xs,
                                  Text(
                                    '${profile['followerCount'] ?? 0} pengikut \u00b7 ${profile['vehicleCount'] ?? 0} kendaraan',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  if (profile['rating'] != null) ...[
                                    AppGap.xs,
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.star,
                                          size: 16.sp,
                                          color: AppColors.warning,
                                        ),
                                        AppGap.h(AppSpacing.xs),
                                        Text(
                                          (profile['rating'] as num)
                                              .toStringAsFixed(1),
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: AppMotion.fast,
                              switchInCurve: AppMotion.enter,
                              switchOutCurve: AppMotion.exit,
                              child: ElevatedButton.icon(
                                key: ValueKey(
                                  'follow-$isFollowing-$_followLoading',
                                ),
                                onPressed: _followLoading
                                    ? null
                                    : () => _toggleFollow(profile),
                                icon: Icon(
                                  isFollowing
                                      ? LucideIcons.userMinus
                                      : LucideIcons.userPlus,
                                ),
                                label: Text(
                                  _followLoading
                                      ? '...'
                                      : (isFollowing ? 'Mengikuti' : 'Ikuti'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (profile['storeDescription'] != null) ...[
                          AppGap.lg,
                          Text(
                            profile['storeDescription'].toString(),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                        AppGap.v(AppSpacing.xxl),
                        Text('Layanan Mitra', style: AppTextStyles.titleMedium),
                        AppGap.xs,
                        Text(
                          'Semua rental kendaraan dan paket wisata dari toko ini.',
                          style: AppTextStyles.bodySmall,
                        ),
                        AppGap.lg,
                        Text(
                          'Rental Kendaraan',
                          style: AppTextStyles.titleSmall,
                        ),
                        AppGap.md,
                        if (vehicles.isEmpty)
                          Text(
                            'Belum ada kendaraan aktif.',
                            style: AppTextStyles.bodySmall,
                          )
                        else
                          ListingGrid(
                            itemCount: vehicles.length,
                            textBlockHeight:
                                ListingCardMetrics.vehicleTextBlockHeight,
                            itemBuilder: (context, index) => VehicleCard(
                              vehicle: vehicles[index],
                              layout: VehicleCardLayout.listing,
                              onTap: () => context.push(
                                AppRoutePaths.vehicleDetail(vehicles[index].id),
                              ),
                            ),
                          ),
                        if ((profile['tourPackages'] as List?)?.isNotEmpty ==
                            true) ...[
                          AppGap.lg,
                          ListingSection(
                            title: 'Paket Wisata',
                            itemCount: (profile['tourPackages'] as List).length,
                            textBlockHeight:
                                ListingCardMetrics.tourTextBlockHeight,
                            itemBuilder: (context, index, _) {
                              final raw =
                                  (profile['tourPackages'] as List)[index];
                              if (raw is! Map<String, dynamic>)
                                return const SizedBox.shrink();
                              final tour = TourPackageModel.fromJson(raw);
                              return TourPackageCard(
                                tour: tour,
                                layout: TourPackageCardLayout.listing,
                              );
                            },
                          ),
                        ],
                        AppGap.lg,
                        MitraReviewListSection(mitraId: widget.mitraId),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
