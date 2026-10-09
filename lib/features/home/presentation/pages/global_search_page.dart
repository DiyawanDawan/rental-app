import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/di.dart';
import '../../../../core/services/user_location_service.dart';
import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../customer/data/customer_repository.dart';
import '../../../customer/data/models/blog_model.dart';
import '../../../customer/data/models/tour_model.dart';
import '../../../customer/data/models/travel_model.dart';
import '../../../customer/data/models/vehicle_model.dart';
import '../../../../core/router/router_query_mixin.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> with RouterQueryMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _isLoading = false;
  String _lastQuery = '';
  _GlobalSearchResults _results = const _GlobalSearchResults();

  static const _minQueryLength = 2;
  static const _previewLimit = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    final q = queryParameters['q'] ?? queryParameters['search'];
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
      _runSearch(q);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(value));
  }

  Future<void> _runSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < _minQueryLength) {
      setState(() {
        _lastQuery = query;
        _results = const _GlobalSearchResults();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _lastQuery = query;
      _isLoading = true;
    });

    final q = query.toLowerCase();
    final repository = getIt<CustomerRepository>();
    final userPosition = UserLocationService.instance.lastKnown ??
        await UserLocationService.instance.getCurrentPosition();

    try {
      final vehiclesFuture = repository.getVehicles(
        search: query.trim(),
        limit: _previewLimit,
        lat: userPosition?.latitude,
        lng: userPosition?.longitude,
        sort: userPosition != null ? 'nearest_cheapest' : 'price_asc',
        radiusKm: userPosition != null ? 25 : null,
      );
      final toursFuture = repository.getTourPackages();
      final routesFuture = repository.getTravelRoutes();
      final blogsFuture = repository.getBlogs();

      final vehiclesResponse = await vehiclesFuture;
      final toursResponse = await toursFuture;
      final routesResponse = await routesFuture;
      final blogsResponse = await blogsFuture;

      final tours = (toursResponse.data ?? [])
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                (t.location ?? '').toLowerCase().contains(q) ||
                (t.description ?? '').toLowerCase().contains(q),
          )
          .take(_previewLimit)
          .toList();

      final blogs = (blogsResponse.data ?? [])
          .where(
            (b) =>
                b.title.toLowerCase().contains(q) ||
                (b.excerpt ?? '').toLowerCase().contains(q) ||
                (b.category ?? '').toLowerCase().contains(q),
          )
          .take(_previewLimit)
          .toList();

      final travelRoutes = _matchTravelRoutes(routesResponse.data ?? [], q);

      if (!mounted || _lastQuery != query) return;

      setState(() {
        _results = _GlobalSearchResults(
          vehicles: vehiclesResponse.data,
          tours: tours,
          travelRoutes: travelRoutes,
          blogs: blogs,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || _lastQuery != query) return;
      setState(() => _isLoading = false);
    }
  }

  List<TravelRouteMatch> _matchTravelRoutes(List<Map<String, dynamic>> routes, String q) {
    final seen = <String>{};
    final matched = <TravelRouteMatch>[];

    for (final raw in routes) {
      final route = TravelRouteModel.fromJson(raw);
      if (route.origin.isEmpty || route.destination.isEmpty) continue;

      final haystack = '${route.origin} ${route.destination}'.toLowerCase();
      if (!haystack.contains(q)) continue;

      final key = '${route.origin}|${route.destination}';
      if (seen.contains(key)) continue;
      seen.add(key);
      matched.add(
        TravelRouteMatch(
          origin: route.origin,
          destination: route.destination,
          originRegencyId: route.originRegencyId,
          destinationRegencyId: route.destinationRegencyId,
        ),
      );
      if (matched.length >= _previewLimit) break;
    }

    return matched;
  }

  bool get _hasResults =>
      _results.vehicles.isNotEmpty ||
      _results.tours.isNotEmpty ||
      _results.travelRoutes.isNotEmpty ||
      _results.blogs.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final showMinLengthHint = query.isNotEmpty && query.length < _minQueryLength;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          onSubmitted: _runSearch,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari mobil, wisata, travel, artikel...',
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(LucideIcons.x, size: 18.sp),
                    onPressed: () {
                      _searchController.clear();
                      _onQueryChanged('');
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(showMinLengthHint),
    );
  }

  Widget _buildBody(bool showMinLengthHint) {
    if (showMinLengthHint) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Ketik minimal $_minQueryLength karakter untuk mulai mencari.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.search, size: 48.sp, color: AppColors.lightGray),
              AppGap.md,
              Text('Cari semua layanan', style: AppTextStyles.titleMedium),
              AppGap.sm,
              Text(
                'Satu kotak pencarian untuk rental, paket wisata, rute travel, dan artikel.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const AppShimmerResultList(itemCount: 6);
    }

    if (!_hasResults) {
      return AppEmptyState(
        icon: LucideIcons.searchX,
        title: 'Tidak ditemukan',
        message: 'Coba kata kunci lain untuk "$_lastQuery".',
      );
    }

    return ListView(
      padding: AppPadding.list,
      children: [
        if (_results.vehicles.isNotEmpty) ...[
          _SectionHeader(
            title: 'Rental',
            icon: LucideIcons.car,
            onSeeAll: () => context.push(AppRoutePaths.vehiclesWithQuery(search: _lastQuery)),
          ),
          ..._results.vehicles.map(
            (v) => _ResultTile(
              icon: LucideIcons.car,
              title: v.name,
              subtitle: '${v.brand ?? '-'} \u00b7 ${MoneyFormatter.rupiah(v.pricePerDay)}/hari',
              onTap: () => context.push(AppRoutePaths.vehicleDetail(v.id)),
            ),
          ),
          AppGap.lg,
        ],
        if (_results.tours.isNotEmpty) ...[
          _SectionHeader(
            title: 'Wisata',
            icon: LucideIcons.treePalm,
            onSeeAll: () => context.push(AppRoutePaths.tourPackagesWithQuery(q: _lastQuery)),
          ),
          ..._results.tours.map(
            (t) => _ResultTile(
              icon: LucideIcons.treePalm,
              title: t.title,
              subtitle: '${t.location ?? '-'} \u00b7 ${MoneyFormatter.rupiah(t.price)}',
              onTap: () => context.push(AppRoutePaths.tourDetail(t.id)),
            ),
          ),
          AppGap.lg,
        ],
        if (_results.travelRoutes.isNotEmpty) ...[
          _SectionHeader(
            title: 'Travel',
            icon: LucideIcons.bus,
            onSeeAll: () => context.push(AppRoutePaths.travelSearch),
          ),
          ..._results.travelRoutes.map(
            (r) => _ResultTile(
              icon: LucideIcons.bus,
              title: '${r.origin} \u2192 ${r.destination}',
              subtitle: 'Lihat jadwal travel',
              onTap: () {
                final date = DateTime.now().toIso8601String().split('T').first;
                context.push(
                  AppRoutePaths.travelSchedulesWithQuery(
                    origin: r.origin,
                    destination: r.destination,
                    date: date,
                    originRegencyId: r.originRegencyId,
                    destinationRegencyId: r.destinationRegencyId,
                  ),
                );
              },
            ),
          ),
          AppGap.lg,
        ],
        if (_results.blogs.isNotEmpty) ...[
          _SectionHeader(
            title: 'Artikel',
            icon: LucideIcons.newspaper,
            onSeeAll: () => context.push(AppRoutePaths.blogsWithQuery(q: _lastQuery)),
          ),
          ..._results.blogs.map(
            (b) => _ResultTile(
              icon: LucideIcons.newspaper,
              title: b.title,
              subtitle: b.category ?? 'Artikel',
              onTap: () => context.push(AppRoutePaths.blogDetail(b.slug)),
            ),
          ),
        ],
      ],
    );
  }
}

class TravelRouteMatch {
  const TravelRouteMatch({
    required this.origin,
    required this.destination,
    this.originRegencyId,
    this.destinationRegencyId,
  });

  final String origin;
  final String destination;
  final String? originRegencyId;
  final String? destinationRegencyId;
}

class _GlobalSearchResults {
  const _GlobalSearchResults({
    this.vehicles = const [],
    this.tours = const [],
    this.travelRoutes = const [],
    this.blogs = const [],
  });

  final List<VehicleModel> vehicles;
  final List<TourPackageModel> tours;
  final List<TravelRouteMatch> travelRoutes;
  final List<BlogModel> blogs;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.orange),
          AppGap.h(AppSpacing.sm),
          Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
          TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: AppDecorations.floatingCard(),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: AppColors.orange),
          title: Text(title, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Icon(LucideIcons.chevronRight, size: 18.sp),
          onTap: onTap,
        ),
      ),
    );
  }
}
