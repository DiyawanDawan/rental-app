import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';

import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/user_location_service.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';
import '../../../../core/router/router_query_mixin.dart';
import '../../../../core/widgets/layout/listing_grid.dart';
import '../../../../core/widgets/layout/listing_toolbar_divider.dart';
import '../../application/customer_service.dart';
import '../../data/customer_repository.dart';
import '../../data/models/amenity_model.dart';
import '../../data/models/vehicle_model.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_filter_sheet.dart';
import '../widgets/vehicle_map_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> with RouterQueryMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();

  bool _showHistory = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;
  List<VehicleModel> _vehicles = [];

  String? _selectedType;
  String? _selectedTransmission;
  String _selectedSort = 'newest';
  RangeValues _priceRange = const RangeValues(0, 5000000);
  final List<String> _selectedAmenityIds = [];
  final Set<String> _favoriteIds = {};
  bool _minRatingFour = false;
  bool _mapView = false;
  double? _userLat;
  double? _userLng;
  bool _locationDenied = false;
  static const _radiusKm = 25.0;

  static const _pageSize = 20;
  static const _maxPrice = 5000000.0;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    _applyInitialQueryParams(queryParameters);
    _loadVehicles(reset: true);
    context.read<CustomerService>().loadSearchHistory();
    _loadFavorites();
  }

  void _applyInitialQueryParams(Map<String, String> params) {
    final type = params['type'];
    if (type != null && VehicleTypeOptions.options.containsKey(type)) {
      _selectedType = type;
    }
    final transmission = params['transmission'];
    if (transmission != null && TransmissionOptions.options.containsKey(transmission)) {
      _selectedTransmission = transmission;
    }
    final search = params['search'];
    if (search != null && search.isNotEmpty) {
      _searchController.text = search;
    }
    final sort = params['sort'];
    if (sort != null && VehicleSortOptions.options.containsKey(sort)) {
      _selectedSort = sort;
    }
    final lat = double.tryParse(params['lat'] ?? '');
    final lng = double.tryParse(params['lng'] ?? '');
    if (lat != null && lng != null) {
      _userLat = lat;
      _userLng = lng;
    }
    if (params['minRating'] == '4') {
      _minRatingFour = true;
    }
  }

  Future<bool> _ensureLocationForGeoSort() async {
    if (!VehicleSortOptions.requiresLocation(_selectedSort)) return true;
    if (_userLat != null && _userLng != null) return true;

    final position = await UserLocationService.instance.getCurrentPosition();
    if (!mounted) return false;
    if (position == null) {
      setState(() => _locationDenied = true);
      return false;
    }
    setState(() {
      _userLat = position.latitude;
      _userLng = position.longitude;
      _locationDenied = false;
    });
    return true;
  }

  Future<void> _loadFavorites() async {
    if (!context.read<AuthService>().isAuthenticated) return;
    final favs = await context.read<CustomerService>().getFavoriteVehicles();
    if (!mounted) return;
    setState(() => _favoriteIds..clear()..addAll(favs.map((v) => v.id)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() => _showHistory = _searchFocusNode.hasFocus);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || _isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadVehicles(reset: false);
    }
  }

  Future<void> _loadVehicles({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final query = _searchController.text.trim();
      if (VehicleSortOptions.requiresLocation(_selectedSort)) {
        final hasLocation = await _ensureLocationForGeoSort();
        if (!hasLocation) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _vehicles = [];
            _errorMessage = null;
          });
          return;
        }
      }

      if (reset && query.isNotEmpty) {
        context.read<CustomerService>().addSearchHistory(query);
        await AnalyticsService.instance.logSearchVehicle(query: query);
      }

      final response = await getIt<CustomerRepository>().getVehicles(
        search: query,
        type: _selectedType,
        transmission: _selectedTransmission,
        sort: _selectedSort,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
        amenityIds: _selectedAmenityIds.isNotEmpty ? _selectedAmenityIds : null,
        minRating: _minRatingFour ? 4 : null,
        lat: _userLat,
        lng: _userLng,
        radiusKm: VehicleSortOptions.requiresLocation(_selectedSort) ? _radiusKm : null,
        page: reset ? 1 : _page + 1,
        limit: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _vehicles = response.data;
          _page = 1;
        } else {
          _vehicles = [..._vehicles, ...response.data];
          _page++;
        }
        _hasMore = _page < response.pagination.totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is Failure ? error.message : error.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _refresh() {
    _searchFocusNode.unfocus();
    setState(() => _showHistory = false);
    _loadVehicles(reset: true);
  }

  Future<void> _toggleMapView() async {
    if (!_mapView && _userLat == null && _userLng == null) {
      final position = await UserLocationService.instance.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
          _locationDenied = false;
        });
      }
    }
    if (!mounted) return;
    setState(() => _mapView = !_mapView);
  }

  void _applySearch(String query) {
    _searchController.text = query;
    _refresh();
  }

  Future<void> _toggleFavorite(String vehicleId) async {
    if (!context.read<AuthService>().isAuthenticated) {
      context.push(AppRoutePaths.login);
      return;
    }
    final favorited = await context.read<CustomerService>().toggleVehicleFavorite(vehicleId);
    if (!mounted || favorited == null) return;
    setState(() {
      if (favorited) {
        _favoriteIds.add(vehicleId);
      } else {
        _favoriteIds.remove(vehicleId);
      }
    });
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VehicleFilterSheet(
        initialType: _selectedType,
        initialTransmission: _selectedTransmission,
        initialSort: _selectedSort,
        initialPriceRange: _priceRange,
        initialAmenityIds: _selectedAmenityIds,
        initialMinRatingFour: _minRatingFour,
        onApply: (type, transmission, sort, priceRange, amenityIds, minRatingFour) {
          setState(() {
            _selectedType = type;
            _selectedTransmission = transmission;
            _selectedSort = sort;
            _priceRange = priceRange;
            _minRatingFour = minRatingFour;
            _selectedAmenityIds
              ..clear()
              ..addAll(amenityIds);
          });
          _refresh();
        },
      ),
    );
  }

  Future<void> _selectSort(String sort) async {
    if (!VehicleSortOptions.requiresLocation(sort)) {
      setState(() => _selectedSort = sort);
      _refresh();
      return;
    }
    final ok = await _ensureLocationForGeoSort();
    if (!mounted || !ok) return;
    setState(() => _selectedSort = sort);
    _refresh();
  }

  void _selectType(String? type) {
    setState(() => _selectedType = type);
    _refresh();
  }

  void _toggleTransmission(String value) {
    setState(() {
      _selectedTransmission = _selectedTransmission == value ? null : value;
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan'),
        actions: [
          IconButton(
            onPressed: _toggleMapView,
            icon: Icon(_mapView ? LucideIcons.layoutGrid : LucideIcons.map),
            tooltip: _mapView ? 'Tampilan daftar' : 'Tampilan peta',
          ),
          IconButton(
            onPressed: _showFilter,
            icon: Icon(LucideIcons.slidersHorizontal),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.pageTop, AppSpacing.page, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _refresh(),
                    decoration: InputDecoration(
                      hintText: 'Cari brand atau nama...',
                      prefixIcon: Icon(LucideIcons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(LucideIcons.x, size: 16.sp),
                              onPressed: () {
                                _searchController.clear();
                                _refresh();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                AppGap.h(AppSpacing.sm),
                IconButton.filled(
                  onPressed: _refresh,
                  icon: Icon(LucideIcons.arrowRight),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
                  ),
                ),
              ],
            ),
          ),
          if (_showHistory)
            Consumer<CustomerService>(
              builder: (context, service, child) {
                if (service.searchHistory.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Riwayat Pencarian', style: context.textTitleSmall),
                          TextButton(
                            onPressed: () => service.clearSearchHistory(),
                            child: Text(
                              'Hapus Semua',
                              style: context.textBodySmall.copyWith(fontSize: 12.sp, color: AppColors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...service.searchHistory.take(5).map(
                          (query) => ListTile(
                            leading: Icon(LucideIcons.history, size: 18.sp),
                            title: Text(query, style: context.textBodyMedium),
                            onTap: () => _applySearch(query),
                            dense: true,
                          ),
                        ),
                    const Divider(),
                  ],
                );
              },
            ),
          if (!_showHistory) ...[
            SizedBox(
              height: 48.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
                children: [
                  FilterChip(
                    label: const Text('Semua Jenis'),
                    selected: _selectedType == null,
                    onSelected: (_) => _selectType(null),
                  ),
                  ...VehicleTypeOptions.options.entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(e.value),
                        selected: _selectedType == e.key,
                        onSelected: (_) => _selectType(e.key),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _VehicleSortChip(
                      label: 'Terbaru',
                      value: 'newest',
                      group: _selectedSort,
                      onSelect: _selectSort,
                    ),
                    _VehicleSortChip(
                      label: 'Termurah',
                      value: 'price_asc',
                      group: _selectedSort,
                      onSelect: _selectSort,
                    ),
                    _VehicleSortChip(
                      label: 'Termahal',
                      value: 'price_desc',
                      group: _selectedSort,
                      onSelect: _selectSort,
                    ),
                    _VehicleSortChip(
                      label: 'Rating',
                      value: 'rating',
                      group: _selectedSort,
                      onSelect: _selectSort,
                    ),
                    _VehicleSortChip(
                      label: 'Terdekat',
                      value: 'distance_asc',
                      group: _selectedSort,
                      onSelect: _selectSort,
                    ),
                    _VehicleSortChip(
                      label: 'Terdekat & termurah',
                      value: 'nearest_cheapest',
                      group: _selectedSort,
                      onSelect: _selectSort,
                    ),
                    FilterChip(
                      label: const Text('Matic'),
                      selected: _selectedTransmission == 'MATIC',
                      onSelected: (_) => _toggleTransmission('MATIC'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: FilterChip(
                        label: const Text('Manual'),
                        selected: _selectedTransmission == 'MANUAL',
                        onSelected: (_) => _toggleTransmission('MANUAL'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: FilterChip(
                        label: const Text('Rating ≥ 4'),
                        selected: _minRatingFour,
                        onSelected: (v) {
                          setState(() => _minRatingFour = v);
                          _refresh();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(
                          _priceRange.start > 0 || _priceRange.end < _maxPrice
                              ? '${MoneyFormatter.rupiah(_priceRange.start)} – ${MoneyFormatter.rupiah(_priceRange.end)}'
                              : 'Harga',
                        ),
                        selected: _priceRange.start > 0 || _priceRange.end < _maxPrice,
                        onSelected: (_) => _showFilter(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: FilterChip(
                        label: const Text('Fasilitas'),
                        selected: _selectedAmenityIds.isNotEmpty,
                        onSelected: (_) => _showFilter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_locationDenied && VehicleSortOptions.requiresLocation(_selectedSort))
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
              child: MaterialBanner(
                content: const Text('Aktifkan lokasi untuk sort berdasarkan jarak.'),
                leading: Icon(LucideIcons.mapPin, color: AppColors.orange),
                actions: [
                  TextButton(
                    onPressed: () async {
                      UserLocationService.instance.clearCache();
                      final ok = await _ensureLocationForGeoSort();
                      if (ok) _refresh();
                    },
                    child: const Text('Coba lagi'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedSort = 'newest';
                      _locationDenied = false;
                    }),
                    child: const Text('Reset sort'),
                  ),
                ],
              ),
            ),
          const ListingToolbarDivider(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return AppShimmerListingGrid(
        itemCount: 14,
        textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
        textLines: 4,
        padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xxl),
      );
    }

    if (_errorMessage != null) {
      return AppErrorState(
        icon: LucideIcons.circleAlert,
        title: 'Gagal memuat kendaraan',
        message: _errorMessage!,
        onRetry: _refresh,
      );
    }

    if (_vehicles.isEmpty) {
      return AppErrorState(
        icon: LucideIcons.car,
        title: _locationDenied && VehicleSortOptions.requiresLocation(_selectedSort)
            ? 'Lokasi diperlukan'
            : 'Belum ada kendaraan',
        message: _locationDenied && VehicleSortOptions.requiresLocation(_selectedSort)
            ? 'Izinkan akses lokasi atau pilih sort lain.'
            : 'Coba ubah kata kunci pencarian atau filter.',
        onRetry: _refresh,
      );
    }

    if (_mapView) {
      return VehicleMapView(
        vehicles: _vehicles,
        userLocation: _userLat != null && _userLng != null ? LatLng(_userLat!, _userLng!) : null,
        onVehicleTap: (vehicle) => context.push(AppRoutePaths.vehicleDetail(vehicle.id)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadVehicles(reset: true),
      child: ListingGrid(
        scrollable: true,
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xxl),
        itemCount: _vehicles.length + (_isLoadingMore ? 1 : 0),
        textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
        itemBuilder: (context, index) {
          if (index >= _vehicles.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final vehicle = _vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            layout: VehicleCardLayout.listing,
            isFavorite: _favoriteIds.contains(vehicle.id),
            onFavoriteTap: () => _toggleFavorite(vehicle.id),
            onTap: () => context.push(AppRoutePaths.vehicleDetail(vehicle.id)),
          );
        },
      ),
    );
  }
}

class _VehicleSortChip extends StatelessWidget {
  const _VehicleSortChip({
    required this.label,
    required this.value,
    required this.group,
    required this.onSelect,
  });

  final String label;
  final String value;
  final String group;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: group == value,
        onSelected: (_) => onSelect(value),
      ),
    );
  }
}
