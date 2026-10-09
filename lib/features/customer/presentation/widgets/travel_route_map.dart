import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/shapes.dart';
import '../../data/models/travel_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TravelRouteMap extends StatelessWidget {
  const TravelRouteMap({
    required this.route,
    this.height = 180,
    super.key,
  });

  final TravelRouteModel route;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!route.hasMapCoords) {
      return Container(
        height: height.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightGray.withValues(alpha: 0.2),
          borderRadius: AppShapes.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.map, size: 32.sp, color: AppColors.lightGray),
            AppGap.sm,
            Text('Peta rute belum tersedia', style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
          ],
        ),
      );
    }

    final origin = LatLng(route.originLat!, route.originLng!);
    final destination = LatLng(route.destinationLat!, route.destinationLng!);
    final center = LatLng(
      (origin.latitude + destination.latitude) / 2,
      (origin.longitude + destination.longitude) / 2,
    );

    return ClipRRect(
      borderRadius: AppShapes.md,
      child: SizedBox(
        height: height.h,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 8,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.travelindo.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [origin, destination],
                  color: AppColors.teal,
                  strokeWidth: 3,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: origin,
                  width: 36.w,
                  height: 36.w,
                  child: Icon(LucideIcons.mapPin, color: AppColors.orange, size: 28.sp),
                ),
                Marker(
                  point: destination,
                  width: 36.w,
                  height: 36.w,
                  child: Icon(LucideIcons.flag, color: AppColors.teal, size: 28.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
