import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/map/map_widget.dart';
import '../../data/models/vehicle_model.dart';

class VehicleMapView extends StatelessWidget {
  const VehicleMapView({
    required this.vehicles,
    required this.onVehicleTap,
    this.userLocation,
    super.key,
  });

  final List<VehicleModel> vehicles;
  final void Function(VehicleModel vehicle) onVehicleTap;
  final LatLng? userLocation;

  @override
  Widget build(BuildContext context) {
    final mapped = vehicles
        .where((v) => v.mitra?.latitude != null && v.mitra?.longitude != null)
        .toList();

    if (mapped.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Belum ada kendaraan dengan lokasi mitra di peta.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final center = userLocation ??
        LatLng(mapped.first.mitra!.latitude!, mapped.first.mitra!.longitude!);

    final markers = <Marker>[
      if (userLocation != null)
        Marker(
          point: userLocation!,
          width: 36,
          height: 36,
          child: Icon(LucideIcons.locateFixed, color: AppColors.teal, size: 28.sp),
        ),
      ...mapped.map(
        (v) => Marker(
          point: LatLng(v.mitra!.latitude!, v.mitra!.longitude!),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _showPreview(context, v),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.onDark, width: 2),
              ),
              child: Icon(LucideIcons.car, color: AppColors.onDark, size: 18.sp),
            ),
          ),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.page),
      child: TravelindoMap(
        initialLocation: center,
        markers: markers,
        height: MediaQuery.sizeOf(context).height,
        zoom: mapped.length == 1 ? 14 : 11,
      ),
    );
  }

  void _showPreview(BuildContext context, VehicleModel vehicle) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: Icon(LucideIcons.car, color: AppColors.orange),
          title: Text(vehicle.name, style: AppTextStyles.titleSmall),
          subtitle: Text(
            '${MoneyFormatter.rupiah(vehicle.pricePerDay)}/hari'
            '${vehicle.distanceKm != null ? ' \u00b7 ${vehicle.distanceKm!.toStringAsFixed(1)} km' : ''}',
          ),
          trailing: Icon(LucideIcons.chevronRight),
          onTap: () {
            Navigator.pop(ctx);
            onVehicleTap(vehicle);
          },
        ),
      ),
    );
  }
}
