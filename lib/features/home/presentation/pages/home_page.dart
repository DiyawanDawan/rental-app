import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/di.dart';
import '../../../../config/breakpoints.dart';
import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/layout/responsive_builder.dart';
import '../../../auth/application/auth_service.dart';
import '../../../customer/application/customer_service.dart';
import '../../../customer/data/customer_repository.dart';
import '../../../customer/data/models/banner_model.dart';
import '../../../customer/data/models/tour_model.dart';
import '../../../customer/data/models/tourist_destination_model.dart';
import '../../../customer/data/models/vehicle_model.dart';
import '../../../customer/presentation/utils/tour_recommendation_utils.dart';
import '../../../../core/widgets/layout/page_width_container.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_section.dart';
import '../../../customer/presentation/widgets/destination_listing_grid.dart';
import '../../../customer/presentation/widgets/tour_package_card.dart';
import '../../../customer/presentation/widgets/vehicle_card.dart';
import '../widgets/home_banner_section.dart';
import '../widgets/home_quick_access_card.dart';
import '../widgets/home_quick_actions_row.dart';
import '../widgets/home_product_services_section.dart';
import '../widgets/home_search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadHome();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthService>().isAuthenticated) {
        context.read<CustomerService>().loadUnreadCount();
      }
    });
  }

  Future<_HomeData> _loadHome() async {
    final repository = getIt<CustomerRepository>();
    final bannersResponse = await repository.getBanners(position: 'HOME_TOP');
    final vehiclesResponse = await repository.getVehicles(limit: 7, sort: 'newest');
    final toursResponse = await repository.getTourPackages();
    final destinationsResponse = await repository.getTouristDestinations();

    final banners = bannersResponse.data ?? const <BannerModel>[];
    final vehicles = vehiclesResponse.data;
    final tours = toursResponse.data ?? const <TourPackageModel>[];
    final destinations = destinationsResponse.data ?? const <TouristDestinationModel>[];
    final recommendedTours = pickRecommendedTours(tours, limit: 7);
    return _HomeData(
      banners: banners,
      vehicles: vehicles,
      tours: tours,
      recommendedTours: recommendedTours,
      destinations: destinations.take(14).toList(),
    );
  }

  void _refresh() {
    setState(() {
      _future = _loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isMitra = authService.user?.role == 'MITRA';
    final isMobile = context.isMobile;

    final content = FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingView();
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is Failure ? error.message : error.toString();
          return AppErrorState(
            title: 'Home belum bisa dimuat',
            message: message,
            onRetry: _refresh,
          );
        }

        final data = snapshot.data ?? const _HomeData();
        return ResponsiveBuilder(
          mobile: _HomeMobileLayout(
            data: data,
            authService: authService,
            isMitra: isMitra,
          ),
          tablet: _HomeWideLayout(
            data: data,
            authService: authService,
            isMitra: isMitra,
            onRefresh: () async => _refresh(),
          ),
          desktop: _HomeWideLayout(
            data: data,
            authService: authService,
            isMitra: isMitra,
            onRefresh: () async => _refresh(),
          ),
        );
      },
    );

    if (!isMobile) {
      return content;
    }

    return Scaffold(
      appBar: _buildAppBar(context, authService),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: content,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthService authService) {
    return AppBar(
      title: const Text('Travelindo'),
      actions: [HomeAppBarActions(authService: authService)],
    );
  }
}

class HomeAppBarActions extends StatelessWidget {
  const HomeAppBarActions({required this.authService, super.key});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (authService.isAuthenticated) ...[
          Consumer<CustomerService>(
            builder: (context, customerService, child) {
              return Stack(
                children: [
                  IconButton(
                    tooltip: 'Notifikasi',
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(LucideIcons.bell),
                  ),
                  if (customerService.unreadNotificationCount > 0)
                    Positioned(
                      right: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: AppColors.critical,
                          borderRadius: AppShapes.button,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          customerService.unreadNotificationCount > 99
                              ? '99+'
                              : customerService.unreadNotificationCount.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () => context.push(AppRoutePaths.profile),
            icon: const Icon(LucideIcons.user),
          ),
        ],
        if (!authService.isAuthenticated)
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => context.push(AppRoutePaths.settings),
            icon: const Icon(LucideIcons.settings),
          ),
      ],
    );
  }
}

// ── Shared content blocks ─────────────────────────────────────────────────────

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.authService,
    required this.isMitra,
    this.compactHero = false,
  });

  final _HomeData data;
  final AuthService authService;
  final bool isMitra;

  /// Tablet/desktop — header sudah punya nav & search; hero ringkas.
  final bool compactHero;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isMitra) ...[
          HomeQuickAccessCard(
            title: 'Dashboard Mitra',
            subtitle: 'Kelola armada dan pesanan Anda',
            icon: LucideIcons.layoutDashboard,
            color: AppColors.orange,
            onTap: () => context.push(AppRoutePaths.mitraDashboard),
          ),
          AppGap.section,
        ] else if (authService.isAuthenticated) ...[
          HomeQuickAccessCard(
            title: 'Pesanan Saya',
            subtitle: 'Cek status dan riwayat pesanan',
            icon: LucideIcons.shoppingBag,
            color: AppColors.teal,
            onTap: () => context.push(AppRoutePaths.bookings),
          ),
          AppGap.section,
        ],
        if (!compactHero) ...[
          Text('Temukan perjalananmu', style: context.textHeadlineLarge),
          AppGap.titleToSubtitle,
          Text(
            'Rental kendaraan, travel, dan paket wisata dalam satu aplikasi.',
            style: context.textBodyMedium,
          ),
          if (!authService.isAuthenticated) ...[
            AppGap.headlineToBody,
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutePaths.login),
                    icon: const Icon(LucideIcons.logIn),
                    label: const Text('Masuk'),
                  ),
                ),
                AppGap.h(AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutePaths.register),
                    icon: const Icon(LucideIcons.userPlus),
                    label: const Text('Daftar'),
                  ),
                ),
              ],
            ),
          ],
          AppGap.lg,
        ],
        if (context.screenWidth < AppBreakpoints.mobile) ...[
          HomeSearchBar(),
          AppGap.section,
        ],
        if (data.banners.isNotEmpty) ...[
          HomeBannerSection(banners: data.banners),
          AppGap.section,
        ],
        if (!compactHero) ...[
          const HomeQuickActionsRow(),
          AppGap.section,
        ],
        DestinationListingSection(destinations: data.destinations),
        AppGap.homeSection,
        ListingSection(
          title: 'Kendaraan terbaru',
          onAction: () => context.push(AppRoutePaths.vehicles),
          itemCount: data.vehicles.length,
          textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
          empty: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutePaths.vehicles),
            icon: const Icon(LucideIcons.car),
            label: const Text('Buka daftar kendaraan'),
          ),
          itemBuilder: (context, index, _) {
            final vehicle = data.vehicles[index];
            return VehicleCard(
              vehicle: vehicle,
              layout: VehicleCardLayout.listing,
              onTap: () => context.push(AppRoutePaths.vehicleDetail(vehicle.id)),
            );
          },
        ),
        AppGap.homeSection,
        ListingSection(
          title: 'Rekomendasi Wisata',
          onAction: () => context.push(AppRoutePaths.tourPackages),
          itemCount: data.recommendedTours.length,
          textBlockHeight: ListingCardMetrics.tourTextBlockHeight,
          empty: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutePaths.tourPackages),
            icon: const Icon(LucideIcons.treePalm),
            label: const Text('Jelajahi paket wisata'),
          ),
          itemBuilder: (context, index, _) => TourPackageCard(
            tour: data.recommendedTours[index],
            layout: TourPackageCardLayout.listing,
            showRecommendedBadge: true,
            listingVariantIndex: index,
          ),
        ),
        AppGap.homeSection,
      ],
    );
  }
}

class _HomeMobileLayout extends StatelessWidget {
  const _HomeMobileLayout({
    required this.data,
    required this.authService,
    required this.isMitra,
  });

  final _HomeData data;
  final AuthService authService;
  final bool isMitra;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: AppSpacing.fabListClearance),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.page,
            AppSpacing.page,
            0,
          ),
          child: _HomeContent(
            data: data,
            authService: authService,
            isMitra: isMitra,
          ),
        ),
        const HomeProductServicesPanel(),
      ],
    );
  }
}

class _HomeWideLayout extends StatelessWidget {
  const _HomeWideLayout({
    required this.data,
    required this.authService,
    required this.isMitra,
    required this.onRefresh,
  });

  final _HomeData data;
  final AuthService authService;
  final bool isMitra;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              0,
              AppSpacing.xl,
              0,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: PageWidthContainer(
                child: _HomeContent(
                  data: data,
                  authService: authService,
                  isMitra: isMitra,
                  compactHero: true,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: HomeProductServicesPanel()),
          SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.page),
            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    this.banners = const [],
    this.vehicles = const [],
    this.tours = const [],
    this.recommendedTours = const [],
    this.destinations = const [],
  });

  final List<BannerModel> banners;
  final List<VehicleModel> vehicles;
  final List<TourPackageModel> tours;
  final List<TourPackageModel> recommendedTours;
  final List<TouristDestinationModel> destinations;
}
