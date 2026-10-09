import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_grid.dart';
import '../../../../core/widgets/motion/animated_filter_switcher.dart';
import '../../application/customer_service.dart';
import '../../data/models/vehicle_model.dart';
import '../widgets/vehicle_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<VehicleModel>> _future;
  String _sort = 'newest';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<CustomerService>().getFavoriteVehicles();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  List<VehicleModel> _sorted(List<VehicleModel> vehicles) {
    final copy = List<VehicleModel>.from(vehicles);
    switch (_sort) {
      case 'price_asc':
        copy.sort((a, b) => (a.pricePerDay ?? 0).compareTo(b.pricePerDay ?? 0));
      case 'price_desc':
        copy.sort((a, b) => (b.pricePerDay ?? 0).compareTo(a.pricePerDay ?? 0));
      case 'rating':
        copy.sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
      default:
        copy.sort((a, b) => a.name.compareTo(b.name));
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Saya')),
      body: Column(
        children: [
          SizedBox(
            height: 48.h,
            child: AnimatedFilterSwitcher(
              filterKey: _sort,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
                children: [
                  _SortChip(label: 'A–Z', value: 'newest', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Harga ↑', value: 'price_asc', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Harga ↓', value: 'price_desc', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                  _SortChip(label: 'Rating', value: 'rating', group: _sort, onSelect: (v) => setState(() => _sort = v)),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VehicleModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppShimmerListingGrid(
                    itemCount: 8,
                    textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
                    textLines: 4,
                  );
                }

                final vehicles = _sorted(snapshot.data ?? []);
                if (vehicles.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.heart,
                    title: 'Belum ada favorit',
                    message: 'Simpan kendaraan favorit dengan mengetuk ikon hati.',
                  );
                }

                return AnimatedFilterSwitcher(
                  filterKey: _sort,
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListingGrid(
                      scrollable: true,
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xxl,
                      ),
                      itemCount: vehicles.length,
                      textBlockHeight: ListingCardMetrics.vehicleTextBlockHeight,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return VehicleCard(
                          vehicle: vehicle,
                          layout: VehicleCardLayout.listing,
                          isFavorite: true,
                          onFavoriteTap: () async {
                            await context.read<CustomerService>().toggleVehicleFavorite(vehicle.id);
                            _refresh();
                          },
                          onTap: () => context.push(AppRoutePaths.vehicleDetail(vehicle.id)),
                        );
                      },
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
