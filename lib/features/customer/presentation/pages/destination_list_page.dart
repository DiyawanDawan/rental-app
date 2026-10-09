import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/spacing.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/router/router_query_mixin.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../application/customer_service.dart';
import '../../data/models/tourist_destination_model.dart';
import '../../../../core/widgets/cards/destination_card.dart';
import '../../../../core/widgets/layout/listing_card_metrics.dart';
import '../../../../core/widgets/layout/listing_grid.dart';
import '../../../../core/widgets/layout/listing_section.dart';
import '../widgets/tourist_destination_card.dart';

class DestinationListPage extends StatefulWidget {
  const DestinationListPage({super.key});

  @override
  State<DestinationListPage> createState() => _DestinationListPageState();
}

class _DestinationListPageState extends State<DestinationListPage> with RouterQueryMixin {
  late Future<List<TouristDestinationModel>> _future;
  final _searchController = TextEditingController();

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    final q = queryParameters['q'] ?? queryParameters['search'];
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
    }
    _future = context.read<CustomerService>().getTouristDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TouristDestinationModel> _filtered(List<TouristDestinationModel> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where(
          (d) =>
              d.name.toLowerCase().contains(query) ||
              (d.description ?? '').toLowerCase().contains(query) ||
              (d.address ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jelajah Destinasi')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.pageTop, AppSpacing.page, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari destinasi wisata...',
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
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.pageTop, AppSpacing.page, 0),
            child: Text(
              'Temukan tempat wisata populer, baca informasinya, lalu langsung cari paket wisata atau travel ke sana.',
              style: context.textBodySmall,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TouristDestinationModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppShimmerListingGrid(
                    itemCount: 12,
                    textBlockHeight: ListingCardMetrics.destinationTextBlockHeight,
                    textLines: 2,
                  );
                }

                final all = snapshot.data ?? [];
                final items = _filtered(all);
                final showPopularSection = items.length > 8;
                final popularItems = showPopularSection ? items.take(8).toList() : const <TouristDestinationModel>[];
                final gridItems = showPopularSection ? items.skip(8).toList() : items;

                if (all.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.mapPin,
                    title: 'Belum ada destinasi',
                    message: 'Destinasi wisata akan tampil di sini ketika tersedia.',
                  );
                }

                if (items.isEmpty) {
                  return AppEmptyState(
                    icon: LucideIcons.searchX,
                    title: 'Tidak ditemukan',
                    message: 'Coba kata kunci lain.',
                    actionLabel: 'Reset',
                    onAction: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  );
                }

                return CustomScrollView(
                  slivers: [
                    if (showPopularSection) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.md,
                            AppSpacing.page,
                            AppSpacing.sm,
                          ),
                          child: ListingSection(
                            title: 'Destinasi Populer',
                            itemCount: popularItems.length,
                            textBlockHeight: ListingCardMetrics.destinationTextBlockHeight,
                            itemBuilder: (context, index, _) => TouristDestinationCard(
                              destination: popularItems[index],
                              layout: DestinationCardLayout.listing,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.lg,
                            AppSpacing.page,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'Semua Destinasi',
                            style: context.textTitleMedium,
                          ),
                        ),
                      ),
                    ],
                    if (gridItems.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          showPopularSection ? 0 : AppSpacing.md,
                          AppSpacing.page,
                          AppSpacing.xxl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: ListingGrid(
                            itemCount: gridItems.length,
                            textBlockHeight: ListingCardMetrics.destinationTextBlockHeight,
                            itemBuilder: (context, index) => TouristDestinationCard(
                              destination: gridItems[index],
                              layout: DestinationCardLayout.listing,
                            ),
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
