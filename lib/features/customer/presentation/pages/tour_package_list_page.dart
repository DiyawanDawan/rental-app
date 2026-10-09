import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/services/user_location_service.dart';
import '../../../../core/router/router_query_mixin.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_grid.dart';
import '../../../../core/widgets/layout/listing_toolbar_divider.dart';
import '../../application/customer_service.dart';
import '../utils/tour_sort_utils.dart';
import '../../data/models/tour_model.dart';
import '../widgets/tour_package_card.dart';

class TourPackageListPage extends StatefulWidget {
  const TourPackageListPage({super.key});

  @override
  State<TourPackageListPage> createState() => _TourPackageListPageState();
}

class _TourPackageListPageState extends State<TourPackageListPage> with RouterQueryMixin {
  late Future<List<TourPackageModel>> _toursFuture;
  late Future<List<String>> _destinationsFuture;
  final _searchController = TextEditingController();

  String? _selectedDestination;
  String _sort = 'default';
  int? _maxDurationDays;
  double? _maxPrice;
  double? _userLat;
  double? _userLng;
  bool _locationDenied = false;

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    final q = queryParameters['q'] ?? queryParameters['search'];
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
    }
    final destination = queryParameters['destination'];
    if (destination != null && destination.isNotEmpty) {
      _selectedDestination = destination;
    }
    final sort = queryParameters['sort'];
    if (sort != null && TourSortOptions.options.containsKey(sort)) {
      _sort = sort;
      if (TourSortOptions.requiresLocation(sort)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _selectGeoSort(sort));
      }
    }
    final service = context.read<CustomerService>();
    _toursFuture = service.getTourPackages();
    _destinationsFuture = service.getTourDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadTours() {
    setState(() {
      _toursFuture = context.read<CustomerService>().getTourPackages();
    });
  }

  List<TourPackageModel> _applyFilters(List<TourPackageModel> tours) {
    var result = tours;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                (t.location ?? '').toLowerCase().contains(query) ||
                (t.description ?? '').toLowerCase().contains(query),
          )
          .toList();
    }
    if (_selectedDestination != null) {
      result = result
          .where((t) => (t.location ?? '').toLowerCase().contains(_selectedDestination!.toLowerCase()))
          .toList();
    }
    if (_maxDurationDays != null) {
      result = result.where((t) => (t.durationDays ?? 0) <= _maxDurationDays!).toList();
    }
    if (_maxPrice != null) {
      result = result.where((t) => t.price <= _maxPrice!).toList();
    }
    result = List<TourPackageModel>.from(result);
    if (TourSortOptions.requiresLocation(_sort) && _userLat != null && _userLng != null) {
      return applyTourGeoSort(result, _sort, _userLat!, _userLng!);
    }
    switch (_sort) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
      case 'duration_asc':
        result.sort((a, b) => (a.durationDays ?? 0).compareTo(b.durationDays ?? 0));
      case 'duration_desc':
        result.sort((a, b) => (b.durationDays ?? 0).compareTo(a.durationDays ?? 0));
    }
    return result;
  }

  Future<void> _selectGeoSort(String sort) async {
    if (!TourSortOptions.requiresLocation(sort)) {
      setState(() => _sort = sort);
      return;
    }
    final position = await UserLocationService.instance.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _locationDenied = true);
      return;
    }
    setState(() {
      _sort = sort;
      _userLat = position.latitude;
      _userLng = position.longitude;
      _locationDenied = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedDestination = null;
      _sort = 'default';
      _maxDurationDays = null;
      _maxPrice = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Wisata')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.pageTop, AppSpacing.page, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari paket wisata...',
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
          SizedBox(
            height: 48.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
              children: [
                FilterChip(
                  label: const Text('Semua Destinasi'),
                  selected: _selectedDestination == null,
                  onSelected: (_) => setState(() => _selectedDestination = null),
                ),
                FutureBuilder<List<String>>(
                  future: _destinationsFuture,
                  builder: (context, snapshot) {
                    final destinations = snapshot.data ?? [];
                    return Row(
                      children: destinations
                          .map(
                            (d) => Padding(
                              padding: EdgeInsets.only(left: AppSpacing.sm),
                              child: FilterChip(
                                label: Text(d),
                                selected: _selectedDestination == d,
                                onSelected: (_) => setState(() => _selectedDestination = d),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
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
                  _SortChip(label: 'Default', value: 'default', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Termurah', value: 'price_asc', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Termahal', value: 'price_desc', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Terpendek', value: 'duration_asc', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Terlama', value: 'duration_desc', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Terdekat', value: 'distance_asc', group: _sort, onSelect: (v) => _selectGeoSort(v)),
                  _SortChip(label: 'Terdekat & termurah', value: 'nearest_cheapest', group: _sort, onSelect: (v) => _selectGeoSort(v)),
                  FilterChip(
                    label: Text(_maxPrice == null ? 'Harga max' : '\u2264 ${MoneyFormatter.rupiah(_maxPrice!)}'),
                    selected: _maxPrice != null,
                    onSelected: (_) async {
                      final picked = await showDialog<double>(
                        context: context,
                        builder: (ctx) => _MaxPriceDialog(initial: _maxPrice),
                      );
                      if (picked != null) {
                        setState(() => _maxPrice = picked < 0 ? null : picked);
                      }
                    },
                  ),
                  FilterChip(
                    label: Text(_maxDurationDays == null ? 'Durasi max' : '\u2264 $_maxDurationDays hari'),
                    selected: _maxDurationDays != null,
                    onSelected: (_) async {
                      final picked = await showDialog<int>(
                        context: context,
                        builder: (ctx) => _MaxDurationDialog(initial: _maxDurationDays),
                      );
                      if (picked != null) {
                        setState(() => _maxDurationDays = picked < 0 ? null : picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_locationDenied && TourSortOptions.requiresLocation(_sort))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: MaterialBanner(
                content: const Text('Aktifkan lokasi untuk sort wisata berdasarkan jarak.'),
                leading: Icon(LucideIcons.mapPin, color: AppColors.orange),
                actions: [
                  TextButton(
                    onPressed: () => _selectGeoSort(_sort),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          const ListingToolbarDivider(),
          Expanded(
            child: FutureBuilder<List<TourPackageModel>>(
              future: _toursFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppShimmerListingGrid(
                    itemCount: 12,
                    textBlockHeight: ListingCardMetrics.tourTextBlockHeight,
                    textLines: 4,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.sm,
                      AppSpacing.page,
                      AppSpacing.page,
                    ),
                  );
                }

                final tours = _applyFilters(snapshot.data ?? []);
                final hasFilters = _selectedDestination != null ||
                    _searchController.text.isNotEmpty ||
                    _sort != 'default' ||
                    _maxPrice != null ||
                    _maxDurationDays != null;

                if (tours.isEmpty) {
                  return AppEmptyState(
                    icon: LucideIcons.treePalm,
                    title: 'Tidak ada paket wisata',
                    message: hasFilters
                        ? 'Tidak ada paket yang cocok dengan filter.'
                        : 'Paket wisata akan tampil di sini ketika tersedia.',
                    actionLabel: hasFilters ? 'Reset Filter' : null,
                    onAction: hasFilters ? _resetFilters : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _reloadTours(),
                  child: ListingGrid(
                    scrollable: true,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.sm,
                      AppSpacing.page,
                      AppSpacing.page,
                    ),
                    itemCount: tours.length,
                    textBlockHeight: ListingCardMetrics.tourTextBlockHeight,
                    itemBuilder: (context, index) => TourPackageCard(
                      tour: tours[index],
                      layout: TourPackageCardLayout.listing,
                      listingVariantIndex: index,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
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

class _MaxPriceDialog extends StatefulWidget {
  const _MaxPriceDialog({this.initial});
  final double? initial;

  @override
  State<_MaxPriceDialog> createState() => _MaxPriceDialogState();
}

class _MaxPriceDialogState extends State<_MaxPriceDialog> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial ?? 3000000;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Harga Maksimum'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(MoneyFormatter.rupiah(_value), style: AppTextStyles.titleMedium),
          Slider(
            value: _value,
            min: 500000,
            max: 10000000,
            divisions: 19,
            activeColor: AppColors.orange,
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, -1.0), child: const Text('Hapus')),
        TextButton(onPressed: () => Navigator.pop(context, _value), child: const Text('Terapkan')),
      ],
    );
  }
}

class _MaxDurationDialog extends StatefulWidget {
  const _MaxDurationDialog({this.initial});
  final int? initial;

  @override
  State<_MaxDurationDialog> createState() => _MaxDurationDialogState();
}

class _MaxDurationDialogState extends State<_MaxDurationDialog> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = widget.initial ?? 7;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Durasi Maksimum (hari)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_days hari', style: AppTextStyles.titleMedium),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 14,
            divisions: 13,
            activeColor: AppColors.orange,
            onChanged: (v) => setState(() => _days = v.round()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, -1), child: const Text('Hapus')),
        TextButton(onPressed: () => Navigator.pop(context, _days), child: const Text('Terapkan')),
      ],
    );
  }
}
