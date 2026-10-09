import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/widgets/feedback/detail_page_skeleton.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/layout/sticky_dual_action_bar.dart';
import '../../../../core/widgets/layout/sticky_price_bar.dart';
import '../../../../core/widgets/map/map_widget.dart';
import '../../application/customer_service.dart';
import '../../data/models/tourist_destination_model.dart';
import '../../../../core/widgets/motion/content_reveal.dart';
import '../widgets/destination_media_gallery.dart';

class DestinationDetailPage extends StatefulWidget {
  const DestinationDetailPage({required this.destinationId, super.key});

  final String destinationId;

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  late Future<TouristDestinationModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerService>().getTouristDestinationById(widget.destinationId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TouristDestinationModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: DetailPageSkeleton(expandedHeight: 220));
        }

        final destination = snapshot.data;
        if (destination == null) {
          return Scaffold(
            body: AppEmptyState(
              icon: LucideIcons.mapPinOff,
              title: 'Destinasi tidak ditemukan',
              message: 'Destinasi mungkin sudah tidak tersedia.',
              actionLabel: 'Kembali',
              onAction: () => context.pop(),
            ),
          );
        }

        final colors = context.cs;
        final isDark = context.isDarkTheme;
        final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: scaffoldBg,
                foregroundColor: colors.onSurface,
                title: Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTitleMedium,
                ),
              ),
              SliverToBoxAdapter(
                child: DestinationStaggeredGallery(media: destination.media),
              ),
              SliverToBoxAdapter(
                child: ContentReveal(
                  child: Transform.translate(
                  offset: Offset(0, -AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.vertical(top: AppShapes.lg.topLeft),
                      border: isDark
                          ? Border(top: BorderSide(color: colors.outline.withValues(alpha: 0.35)))
                          : null,
                      boxShadow: isDark
                          ? null
                          : AppDecorations.softShadow(
                              opacity: 0.06,
                              blur: 12,
                              offsetY: -4,
                            ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.lg,
                      AppSpacing.page,
                      scrollBottomInsetForStickyBar(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(destination.name, style: context.textTitleLarge),
                        if (destination.address != null && destination.address!.isNotEmpty) ...[
                          AppGap.titleToSubtitle,
                          Row(
                            children: [
                              Icon(LucideIcons.mapPin, size: 16.sp, color: AppColors.orange),
                              AppGap.h(AppSpacing.sm),
                              Expanded(child: Text(destination.address!, style: context.textBodySmall)),
                            ],
                          ),
                        ],
                        AppGap.section,
                        Text('Informasi Destinasi', style: context.textTitleMedium),
                        AppGap.sectionTitleToContent,
                        Text(
                          destination.description ?? 'Belum ada deskripsi destinasi.',
                          style: context.textBodyMedium.copyWith(height: 1.6),
                        ),
                        SizedBox(height: AppSpacing.section),
                        DestinationVideoSection(videos: destination.videoMedia),
                        if (destination.latitude != null && destination.longitude != null) ...[
                          SizedBox(height: AppSpacing.section),
                          Text('Lokasi di Peta', style: context.textTitleMedium),
                          AppGap.sectionTitleToContent,
                          ClipRRect(
                            borderRadius: AppShapes.md,
                            child: TravelindoMap(
                              initialLocation: LatLng(destination.latitude!, destination.longitude!),
                              height: 200.h,
                              zoom: 12,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.section),
                        Text('Rencanakan Perjalanan', style: context.textTitleMedium),
                        AppGap.sectionTitleToContent,
                        Text(
                          'Langsung cari layanan Travelindo ke ${destination.name}.',
                          style: context.textBodySmall,
                        ),
                        AppGap.lg,
                        _ActionTile(
                          icon: LucideIcons.treePalm,
                          title: 'Cari Paket Wisata',
                          subtitle: 'Paket tour ke ${destination.name}',
                          color: AppColors.teal,
                          onTap: () => context.push(
                            AppRoutePaths.tourPackagesWithQuery(destination: destination.name),
                          ),
                        ),
                        SizedBox(height: AppSpacing.listGap),
                        _ActionTile(
                          icon: LucideIcons.bus,
                          title: 'Cari Travel',
                          subtitle: 'Jadwal antar kota ke ${destination.name}',
                          color: AppColors.orange,
                          onTap: () => context.push(
                            AppRoutePaths.travelSearchWithQuery(destination: destination.name),
                          ),
                        ),
                        SizedBox(height: AppSpacing.listGap),
                        _ActionTile(
                          icon: LucideIcons.car,
                          title: 'Sewa Kendaraan',
                          subtitle: 'Rental mobil/motor di sekitar ${destination.name}',
                          color: AppColors.navy,
                          onTap: () => context.push(
                            AppRoutePaths.vehiclesWithQuery(search: destination.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: StickyDualActionBar(
            primaryLabel: 'Paket Wisata',
            onPrimary: () => context.push(
              AppRoutePaths.tourPackagesWithQuery(destination: destination.name),
            ),
            secondaryLabel: 'Cari Travel',
            onSecondary: () => context.push(
              AppRoutePaths.travelSearchWithQuery(destination: destination.name),
            ),
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCardOf(context),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: context.isDarkTheme ? 0.22 : 0.12),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTitleSmall),
                  Text(subtitle, style: context.textBodySmall),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18.sp, color: context.cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
