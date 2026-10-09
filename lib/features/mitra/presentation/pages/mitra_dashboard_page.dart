import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/cards/balance_card.dart';
import '../../../../core/widgets/cards/stat_card.dart';
import '../../../../core/widgets/charts/revenue_line_chart.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/lists/icon_menu_tile.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_subscription_model.dart';
import '../widgets/mitra_review_summary_card.dart';
import '../widgets/mitra_welcome_card.dart';

class MitraDashboardPage extends StatefulWidget {
  const MitraDashboardPage({super.key});

  @override
  State<MitraDashboardPage> createState() => _MitraDashboardPageState();
}

class _MitraDashboardPageState extends State<MitraDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadStats();
      context.read<MitraService>().loadProfile();
      context.read<MitraService>().loadEarnings();
      context.read<MitraService>().loadReviewsSummary();
      context.read<MitraService>().loadSubscription();
      context.read<MitraService>().loadActiveTracking();
    });
  }

  Future<void> _refresh() async {
    await context.read<MitraService>().loadStats();
    await context.read<MitraService>().loadProfile();
    await context.read<MitraService>().loadEarnings();
    await context.read<MitraService>().loadReviewsSummary();
    await context.read<MitraService>().loadSubscription();
    await context.read<MitraService>().loadActiveTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Mitra'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutePaths.mitraProfile),
            icon: Icon(LucideIcons.user),
          ),
        ],
      ),
      body: Consumer<MitraService>(
        builder: (context, service, child) {
          if (service.status == MitraStatus.loading && service.stats == null) {
            return const AppLoadingView();
          }

          final stats = service.stats;
          final earnings = service.earnings;
          final monthlyEarnings = (earnings?['monthly'] as List?) ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: AppPadding.list,
              children: [
                MitraWelcomeCard(
                  name: service.profile?.storeName.isNotEmpty == true
                      ? service.profile!.storeName
                      : (service.profile?.email ?? 'Mitra'),
                ),
                if (service.subscription != null) ...[
                  AppGap.md,
                  _SubscriptionBanner(subscription: service.subscription!),
                ],
                if (service.activeTracking.isNotEmpty) ...[
                  AppGap.sm,
                  Text(
                    '${service.activeTracking.length} unit sedang disewa & dilacak',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.section),
                Text('Statistik Bisnis', style: AppTextStyles.titleLarge),
                AppGap.md,
                StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.listGap,
                  crossAxisSpacing: AppSpacing.listGap,
                  children: [
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 100.h,
                      child: StatCard(
                        label: 'Total Kendaraan',
                        value: stats?.totalVehicles.toString() ?? '0',
                        icon: LucideIcons.car,
                        color: AppColors.teal,
                      ),
                    ),
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 100.h,
                      child: StatCard(
                        label: 'Pesanan Aktif',
                        value: stats?.totalBookings.toString() ?? '0',
                        icon: LucideIcons.calendarClock,
                        color: AppColors.orange,
                      ),
                    ),
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 100.h,
                      child: StatCard(
                        label: 'Rating Rata-rata',
                        value: stats?.ratingAverage.toStringAsFixed(1) ?? '0.0',
                        icon: LucideIcons.star,
                        color: AppColors.rating,
                      ),
                    ),
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 100.h,
                      child: StatCard(
                        label: 'Total Review',
                        value: (service.reviewsSummary?['total'] ?? 0)
                            .toString(),
                        icon: LucideIcons.messageSquare,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.section),
                Text(
                  'Performa Bisnis (Pendapatan)',
                  style: AppTextStyles.titleMedium,
                ),
                AppGap.md,
                RevenueLineChart(data: monthlyEarnings),
                SizedBox(height: AppSpacing.section),
                if (service.reviewsSummary != null) ...[
                  Text('Ringkasan Review', style: AppTextStyles.titleMedium),
                  AppGap.md,
                  MitraReviewSummaryCard(summary: service.reviewsSummary!),
                  SizedBox(height: AppSpacing.section),
                ],
                BalanceCard(
                  title: 'Saldo Anda',
                  balance: (earnings?['balance'] as num?)?.toDouble() ?? 0,
                  style: BalanceCardStyle.tealOutline,
                ),
                SizedBox(height: AppSpacing.section),
                Text('Menu Utama', style: AppTextStyles.titleLarge),
                AppGap.md,
                IconMenuTile(
                  title: 'Find My Motor',
                  subtitle: service.subscription?.isPro == true
                      ? 'Lacak unit (HP penyewa + GPS IoT PRO)'
                      : 'Lacak unit via lokasi HP penyewa',
                  icon: LucideIcons.mapPin,
                  onTap: () => context.push(AppRoutePaths.mitraTracking),
                ),
                IconMenuTile(
                  title: 'Paket Langganan',
                  subtitle: service.subscription?.isPro == true
                      ? 'Mitra PRO aktif — termasuk GPS IoT'
                      : 'Upgrade PRO untuk GPS tracker hardware',
                  icon: LucideIcons.crown,
                  onTap: () => context.push(AppRoutePaths.mitraSubscription),
                ),
                IconMenuTile(
                  title: 'Kelola Kendaraan',
                  subtitle: 'Tambah, edit, atau nonaktifkan armada',
                  icon: LucideIcons.car,
                  onTap: () => context.push(AppRoutePaths.mitraVehicles),
                ),
                IconMenuTile(
                  title: 'Pesanan Masuk',
                  subtitle: 'Approve, handover, dan return pesanan',
                  icon: LucideIcons.shoppingBag,
                  onTap: () => context.push(AppRoutePaths.mitraBookings),
                ),
                IconMenuTile(
                  title: 'Pengemudi',
                  subtitle: 'Kelola pengemudi dan data SIM',
                  icon: LucideIcons.car,
                  onTap: () => context.push(AppRoutePaths.mitraDrivers),
                ),
                IconMenuTile(
                  title: 'Earnings & Payout',
                  subtitle: 'Riwayat pendapatan dan tarik saldo',
                  icon: LucideIcons.wallet,
                  onTap: () => context.push('/mitra/earnings'),
                ),
                IconMenuTile(
                  title: 'Jam Operasional',
                  subtitle: 'Atur waktu buka dan tutup toko',
                  icon: LucideIcons.clock,
                  onTap: () => context.push('/mitra/operating-hours'),
                ),
                IconMenuTile(
                  title: 'Review Pelanggan',
                  subtitle: 'Lihat dan balas ulasan pelanggan',
                  icon: LucideIcons.star,
                  onTap: () => context.push(AppRoutePaths.mitraReviews),
                ),
                IconMenuTile(
                  title: 'Jadwal Shuttle',
                  subtitle: 'Kelola jadwal travel mitra',
                  icon: LucideIcons.bus,
                  onTap: () => context.push(AppRoutePaths.mitraTravelSchedules),
                ),
                IconMenuTile(
                  title: 'Paket Wisata',
                  subtitle: 'Kelola paket wisata mitra',
                  icon: LucideIcons.map,
                  onTap: () => context.push(AppRoutePaths.mitraTourPackages),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner({required this.subscription});

  final MitraSubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    final isPro = subscription.isPro;
    return InkWell(
      onTap: () => context.push(AppRoutePaths.mitraSubscription),
      borderRadius: AppShapes.md,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isPro
              ? AppColors.teal.withValues(alpha: 0.12)
              : AppColors.orange.withValues(alpha: 0.12),
          borderRadius: AppShapes.md,
          border: Border.all(color: isPro ? AppColors.teal : AppColors.orange),
        ),
        child: Row(
          children: [
            Icon(
              isPro ? LucideIcons.crown : LucideIcons.sparkles,
              color: isPro ? AppColors.teal : AppColors.orange,
            ),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro ? 'Mitra PRO' : 'Mitra FREE',
                    style: AppTextStyles.titleSmall,
                  ),
                  Text(
                    'Armada ${subscription.vehicleCount}/${subscription.maxVehicles}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
