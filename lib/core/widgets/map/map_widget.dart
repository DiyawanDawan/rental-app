import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

enum MapLayerType { street, satellite }

class TravelindoMap extends StatefulWidget {
  const TravelindoMap({
    required this.initialLocation,
    this.markers = const [],
    this.height = 300,
    this.zoom = 15,
    super.key,
  });

  final LatLng initialLocation;
  final List<Marker> markers;
  final double height;
  final double zoom;

  @override
  State<TravelindoMap> createState() => _TravelindoMapState();
}

class _TravelindoMapState extends State<TravelindoMap> {
  MapLayerType _currentLayer = MapLayerType.street;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppShapes.md,
        border: Border.all(color: AppColors.lightGray),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.initialLocation,
              initialZoom: widget.zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: _currentLayer == MapLayerType.street
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.travelindo.app',
              ),
              MarkerLayer(markers: widget.markers),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.md),
                child: Column(
                  children: [
                    _MapControlBtn(
                      icon: LucideIcons.layers,
                      onTap: () {
                        setState(() {
                          _currentLayer = _currentLayer == MapLayerType.street
                              ? MapLayerType.satellite
                              : MapLayerType.street;
                        });
                      },
                      isActive: _currentLayer == MapLayerType.satellite,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  const _MapControlBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.orange : AppColors.surface,
          borderRadius: AppShapes.sm,
          boxShadow: AppDecorations.softShadow(opacity: 0.1, blur: 4, offsetY: 2),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isActive ? AppColors.onDark : AppColors.navy,
        ),
      ),
    );
  }
}
