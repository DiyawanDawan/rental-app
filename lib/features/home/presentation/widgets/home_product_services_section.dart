import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/decorations.dart';
import '../../../../config/breakpoints.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/services/user_location_service.dart';
import '../../../../core/widgets/inputs/app_filter_chip.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/layout/page_width_container.dart';
import '../../../customer/data/models/amenity_model.dart';

/// Semua jenis layanan produk Travelindo + filter cepat di home.
class HomeProductServicesSection extends StatelessWidget {
  const HomeProductServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= AppBreakpoints.tablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Semua Layanan', style: context.textTitleLarge),
        AppGap.sectionTitleToContent,
        Text(
          'Pilih jenis layanan dan filter untuk langsung ke hasil yang Anda inginkan.',
          style: context.textBodySmall,
        ),
        AppGap.lg,
        if (isWide) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: _VehicleServiceBlock(compact: true)),
                AppGap.h(AppSpacing.md),
                const Expanded(child: _TravelServiceBlock()),
              ],
            ),
          ),
          AppGap.md,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: _TourServiceBlock()),
                AppGap.h(AppSpacing.md),
                const Expanded(child: _DestinationServiceBlock()),
              ],
            ),
          ),
          AppGap.md,
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - AppSpacing.md) / 2;
              return Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: cardWidth,
                  child: const _BlogServiceBlock(),
                ),
              );
            },
          ),
        ] else ...[
          const _VehicleServiceBlock(),
          AppGap.md,
          const _TravelServiceBlock(),
          AppGap.md,
          const _TourServiceBlock(),
          AppGap.md,
          const _DestinationServiceBlock(),
          AppGap.md,
          const _BlogServiceBlock(),
        ],
      ],
    );
  }
}

/// Panel putih penuh lebar — section [HomeProductServicesSection] di home.
class HomeProductServicesPanel extends StatelessWidget {
  const HomeProductServicesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenWidth < AppBreakpoints.mobile;

    return ColoredBox(
      color: context.cs.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: isMobile
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: const HomeProductServicesSection(),
              )
            : PageWidthContainer(
                child: const HomeProductServicesSection(),
              ),
      ),
    );
  }
}

class _ServiceBlock extends StatelessWidget {
  const _ServiceBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onSeeAll,
    required this.children,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onSeeAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.serviceBlockCardOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: context.isDarkTheme ? 0.22 : 0.12),
                  borderRadius: AppShapes.sm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              AppGap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTitleSmall),
                    AppGap.xs,
                    Text(subtitle, style: context.textBodySmall),
                  ],
                ),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
            ],
          ),
          AppGap.md,
          ...children,
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.label, required this.chips});

  final String label;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textCaption),
        AppGap.xs,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: chips,
        ),
      ],
    );
  }
}

class _VehicleServiceBlock extends StatefulWidget {
  const _VehicleServiceBlock({this.compact = false});

  final bool compact;

  @override
  State<_VehicleServiceBlock> createState() => _VehicleServiceBlockState();
}

class _VehicleServiceBlockState extends State<_VehicleServiceBlock> {
  String? _activeType;
  String _activeSort = 'price_asc';

  Future<void> _openSort(String sort) async {
    setState(() => _activeSort = sort);

    if (!VehicleSortOptions.requiresLocation(sort)) {
      context.push(AppRoutePaths.vehiclesWithQuery(type: _activeType, sort: sort));
      return;
    }

    final position = await UserLocationService.instance.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      SnackbarUtils.showError(context, 'Izinkan lokasi untuk sort berdasarkan jarak.');
    }
    context.push(
      AppRoutePaths.vehiclesWithQuery(
        type: _activeType,
        sort: sort,
        lat: position?.latitude,
        lng: position?.longitude,
      ),
    );
  }

  void _openType(String? type) {
    setState(() => _activeType = _activeType == type ? null : type);
    context.push(AppRoutePaths.vehiclesWithQuery(type: _activeType, sort: _activeSort));
  }

  @override
  Widget build(BuildContext context) {
    return _ServiceBlock(
      icon: LucideIcons.car,
      color: context.cs.secondary,
      title: 'Rental Kendaraan',
      subtitle: 'Mobil, motor, van, bus, dan truk',
      onSeeAll: () => context.push(AppRoutePaths.vehicles),
      children: widget.compact ? _compactFilters() : _fullFilters(),
    );
  }

  List<Widget> _fullFilters() {
    return [
      _vehicleTypeFilters(),
      AppGap.sm,
      _transmissionFilters(),
      AppGap.sm,
      _sortFilters(),
    ];
  }

  List<Widget> _compactFilters() {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _vehicleTypeFilters()),
          AppGap.h(AppSpacing.md),
          Expanded(child: _transmissionFilters()),
        ],
      ),
      AppGap.sm,
      _sortFilters(),
    ];
  }

  Widget _vehicleTypeFilters() {
    return _FilterRow(
      label: 'Jenis kendaraan',
      chips: [
        for (final entry in VehicleTypeOptions.options.entries)
          AppFilterChip(
            label: Text(entry.value),
            selected: _activeType == entry.key,
            onSelected: (_) => _openType(entry.key),
          ),
      ],
    );
  }

  Widget _transmissionFilters() {
    return _FilterRow(
      label: 'Transmisi',
      chips: [
        for (final entry in TransmissionOptions.options.entries)
          AppFilterChip(
            label: Text(entry.value),
            onSelected: (_) => context.push(
              AppRoutePaths.vehiclesWithQuery(transmission: entry.key, sort: _activeSort),
            ),
          ),
      ],
    );
  }

  Widget _sortFilters() {
    return _FilterRow(
      label: 'Urutkan',
      chips: [
        AppFilterChip(
          label: const Text('Termurah'),
          selected: _activeSort == 'price_asc',
          onSelected: (_) => _openSort('price_asc'),
        ),
        AppFilterChip(
          label: const Text('Rating tinggi'),
          selected: _activeSort == 'rating',
          onSelected: (_) => _openSort('rating'),
        ),
        AppFilterChip(
          label: const Text('Terdekat'),
          selected: _activeSort == 'distance_asc',
          onSelected: (_) => _openSort('distance_asc'),
        ),
        AppFilterChip(
          label: const Text('Terdekat & termurah'),
          selected: _activeSort == 'nearest_cheapest',
          onSelected: (_) => _openSort('nearest_cheapest'),
        ),
      ],
    );
  }
}

class _TravelServiceBlock extends StatelessWidget {
  const _TravelServiceBlock();

  @override
  Widget build(BuildContext context) {
    return _ServiceBlock(
      icon: LucideIcons.bus,
      color: context.cs.primary,
      title: 'Travel Antar Kota',
      subtitle: 'Jadwal keberangkatan antar kota',
      onSeeAll: () => context.push(AppRoutePaths.travelSearch),
      children: [
        _FilterRow(
          label: 'Aksi cepat',
          chips: [
            AppFilterChip(
              label: const Text('Cari rute'),
              onSelected: (_) => context.push(AppRoutePaths.travelSearch),
            ),
            AppFilterChip(
              label: const Text('Jadwal hari ini'),
              onSelected: (_) => context.push(AppRoutePaths.travelSearch),
            ),
          ],
        ),
        AppGap.sm,
        _FilterRow(
          label: 'Urutkan hasil',
          chips: [
            AppFilterChip(
              label: const Text('Berangkat awal'),
              onSelected: (_) => context.push(AppRoutePaths.travelSearch),
            ),
            AppFilterChip(
              label: const Text('Harga termurah'),
              onSelected: (_) => context.push(AppRoutePaths.travelSearch),
            ),
            AppFilterChip(
              label: const Text('Kursi tersedia'),
              onSelected: (_) => context.push(AppRoutePaths.travelSearch),
            ),
          ],
        ),
      ],
    );
  }
}

class _TourServiceBlock extends StatefulWidget {
  const _TourServiceBlock();

  @override
  State<_TourServiceBlock> createState() => _TourServiceBlockState();
}

class _TourServiceBlockState extends State<_TourServiceBlock> {
  String _activeSort = 'price_asc';

  Future<void> _open(String sort, {bool needsLocation = false}) async {
    setState(() => _activeSort = sort);

    if (!needsLocation) {
      context.push(AppRoutePaths.tourPackagesWithQuery(sort: sort));
      return;
    }

    final position = await UserLocationService.instance.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      SnackbarUtils.showError(context, 'Izinkan lokasi untuk sort wisata berdasarkan jarak.');
    }
    context.push(AppRoutePaths.tourPackagesWithQuery(sort: sort));
  }

  @override
  Widget build(BuildContext context) {
    return _ServiceBlock(
      icon: LucideIcons.treePalm,
      color: context.cs.tertiary,
      title: 'Paket Wisata',
      subtitle: 'Tour terorganisir ke destinasi populer',
      onSeeAll: () => context.push(AppRoutePaths.tourPackages),
      children: [
        _FilterRow(
          label: 'Urutkan',
          chips: [
            AppFilterChip(
              label: const Text('Termurah'),
              selected: _activeSort == 'price_asc',
              onSelected: (_) => _open('price_asc'),
            ),
            AppFilterChip(
              label: const Text('Terdekat'),
              selected: _activeSort == 'distance_asc',
              onSelected: (_) => _open('distance_asc', needsLocation: true),
            ),
            AppFilterChip(
              label: const Text('Terdekat & termurah'),
              selected: _activeSort == 'nearest_cheapest',
              onSelected: (_) => _open('nearest_cheapest', needsLocation: true),
            ),
            AppFilterChip(
              label: const Text('Durasi terpendek'),
              selected: _activeSort == 'duration_asc',
              onSelected: (_) => _open('duration_asc'),
            ),
          ],
        ),
      ],
    );
  }
}

class _DestinationServiceBlock extends StatelessWidget {
  const _DestinationServiceBlock();

  @override
  Widget build(BuildContext context) {
    return _ServiceBlock(
      icon: LucideIcons.mapPinned,
      color: context.accentNature,
      title: 'Destinasi Wisata',
      subtitle: 'Info tempat wisata & rencanakan perjalanan',
      onSeeAll: () => context.push(AppRoutePaths.destinations),
      children: [
        _FilterRow(
          label: 'Jelajahi',
          chips: [
            AppFilterChip(
              label: const Text('Semua destinasi'),
              onSelected: (_) => context.push(AppRoutePaths.destinations),
            ),
            AppFilterChip(
              label: const Text('Bali'),
              onSelected: (_) => context.push(AppRoutePaths.destinationsWithQuery(q: 'Bali')),
            ),
            AppFilterChip(
              label: const Text('Pantai'),
              onSelected: (_) => context.push(AppRoutePaths.destinationsWithQuery(q: 'pantai')),
            ),
            AppFilterChip(
              label: const Text('Gunung'),
              onSelected: (_) => context.push(AppRoutePaths.destinationsWithQuery(q: 'gunung')),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlogServiceBlock extends StatelessWidget {
  const _BlogServiceBlock();

  @override
  Widget build(BuildContext context) {
    return _ServiceBlock(
      icon: LucideIcons.bookOpen,
      color: context.cs.secondary,
      title: 'Blog & Tips',
      subtitle: 'Artikel perjalanan dan inspirasi wisata',
      onSeeAll: () => context.push(AppRoutePaths.blogs),
      children: [
        _FilterRow(
          label: 'Kategori',
          chips: [
            AppFilterChip(
              label: const Text('Semua artikel'),
              onSelected: (_) => context.push(AppRoutePaths.blogs),
            ),
            AppFilterChip(
              label: const Text('Tips perjalanan'),
              onSelected: (_) => context.push(AppRoutePaths.blogsWithQuery(category: 'TIPS')),
            ),
            AppFilterChip(
              label: const Text('Kuliner'),
              onSelected: (_) => context.push(AppRoutePaths.blogsWithQuery(category: 'FOOD')),
            ),
            AppFilterChip(
              label: const Text('Budaya'),
              onSelected: (_) => context.push(AppRoutePaths.blogsWithQuery(category: 'CULTURE')),
            ),
          ],
        ),
      ],
    );
  }
}
