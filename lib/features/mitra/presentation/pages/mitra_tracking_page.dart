import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_subscription_model.dart';

String _formatDateTime(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year} $hh:$mm';
}

class MitraTrackingPage extends StatefulWidget {
  const MitraTrackingPage({super.key});

  @override
  State<MitraTrackingPage> createState() => _MitraTrackingPageState();
}

class _MitraTrackingPageState extends State<MitraTrackingPage> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MitraService>().loadActiveTracking();
      if (!mounted) return;
      _fitMapToUnits(context.read<MitraService>().activeTracking);
    });
  }

  void _fitMapToUnits(List<ActiveTrackingUnitModel> units) {
    final points = units
        .where((u) => u.hasLocation)
        .map((u) => LatLng(u.lat!, u.lng!))
        .toList();
    if (points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (points.length == 1) {
        _mapController.move(points.first, 14);
        return;
      }
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(AppSpacing.mapBoundsPad)),
      );
    });
  }

  Future<void> _refresh(MitraService service) async {
    await service.loadActiveTracking();
    if (mounted) _fitMapToUnits(service.activeTracking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Motor'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutePaths.mitraSubscription),
            icon: Icon(LucideIcons.crown),
          ),
        ],
      ),
      body: Consumer<MitraService>(
        builder: (context, service, _) {
          if (service.status == MitraStatus.loading && service.activeTracking.isEmpty) {
            return const AppLoadingView();
          }

          final units = service.activeTracking;
          final isPro = service.subscription?.isPro == true;

          if (units.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(service),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  Icon(LucideIcons.mapPinOff, size: 48.sp, color: AppColors.lightGray),
                  AppGap.md,
                  Center(
                    child: Text(
                      'Tidak ada unit sedang disewa dengan tracking aktif',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppGap.sm,
                  Center(
                    child: Text(
                      'Tracking otomatis saat handover — lokasi dari HP penyewa. Mitra PRO bisa tambah GPS IoT.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final withLocation = units.where((u) => u.hasLocation).toList();

          return RefreshIndicator(
            onRefresh: () => _refresh(service),
            child: ListView(
              padding: AppPadding.list,
              children: [
                if (withLocation.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: AppShapes.md,
                    child: SizedBox(
                      height: 220.h,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(withLocation.first.lat!, withLocation.first.lng!),
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.travelindo.app',
                          ),
                          MarkerLayer(
                            markers: withLocation
                                .map(
                                  (u) => Marker(
                                    point: LatLng(u.lat!, u.lng!),
                                    width: 40.w,
                                    height: 40.w,
                                    child: Icon(
                                      LucideIcons.mapPin,
                                      color: u.isOverdue ? AppColors.error : AppColors.teal,
                                      size: 32.sp,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppGap.lg,
                ],
                Text('Unit aktif (${units.length})', style: AppTextStyles.titleMedium),
                AppGap.sm,
                ...units.asMap().entries.map(
                  (entry) => StaggeredListItem(
                    index: entry.key,
                    child: _TrackingUnitCard(unit: entry.value, showGpsSettings: isPro),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrackingUnitCard extends StatelessWidget {
  const _TrackingUnitCard({required this.unit, required this.showGpsSettings});

  final ActiveTrackingUnitModel unit;
  final bool showGpsSettings;

  @override
  Widget build(BuildContext context) {
    final dateFmt = _formatDateTime;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.listGap),
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: AppPadding.card,
        leading: CircleAvatar(
          backgroundColor: unit.isOverdue
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.teal.withValues(alpha: 0.15),
          child: Icon(
            LucideIcons.car,
            color: unit.isOverdue ? AppColors.error : AppColors.teal,
          ),
        ),
        title: Text(unit.vehicleName ?? 'Kendaraan', style: AppTextStyles.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unit.licensePlate != null) Text(unit.licensePlate!),
            if (unit.customerName != null) Text('Penyewa: ${unit.customerName}'),
            if (unit.endDate != null)
              Text(
                unit.isOverdue
                    ? 'OVERDUE — seharusnya kembali ${dateFmt(unit.endDate!)}'
                    : 'Kembali: ${dateFmt(unit.endDate!)}',
                style: unit.isOverdue
                    ? AppTextStyles.bodySmall.copyWith(color: AppColors.error)
                    : AppTextStyles.bodySmall,
              ),
            if (unit.isWaitingLocation)
              Text(
                'Menunggu lokasi dari HP penyewa',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (unit.isOffline)
              Text(
                'Sinyal offline',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
              ),
            if (unit.trackingSource != null && !unit.isWaitingLocation)
              Text(
                unit.isIotSource ? 'Sumber: GPS IoT (PRO)' : 'Sumber: HP penyewa',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.teal),
              ),
            if (unit.lastSeenAt != null)
              Text('Update: ${dateFmt(unit.lastSeenAt!)}', style: AppTextStyles.bodySmall),
          ],
        ),
        trailing: showGpsSettings
            ? IconButton(
                icon: Icon(LucideIcons.settings2),
                onPressed: () => context.push(AppRoutePaths.mitraVehicleGps(unit.vehicleId)),
              )
            : null,
      ),
    );
  }
}
