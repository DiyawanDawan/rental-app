import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';
import '../../data/models/vehicle_geofence_model.dart';

class MitraVehicleGeofencePage extends StatefulWidget {
  const MitraVehicleGeofencePage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MitraVehicleGeofencePage> createState() => _MitraVehicleGeofencePageState();
}

class _MitraVehicleGeofencePageState extends State<MitraVehicleGeofencePage> {
  final _mapController = MapController();
  final _nameController = TextEditingController(text: 'Area sewa');
  List<VehicleGeofenceModel> _fences = [];
  LatLng _center = const LatLng(-6.2000, 106.8166);
  double _radiusM = 5000;
  String? _editingId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await context.read<MitraService>().loadVehicles();
    final fences = await context.read<MitraService>().loadVehicleGeofences(widget.vehicleId);
    if (!mounted) return;
    setState(() {
      _fences = fences;
      _loading = false;
      if (fences.isNotEmpty) {
        final first = fences.first;
        _center = LatLng(first.centerLat, first.centerLng);
        _radiusM = first.radiusM.toDouble();
        _nameController.text = first.name;
        _editingId = first.id;
      }
    });
    _mapController.move(_center, 12);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackbarUtils.showError(context, 'Nama geofence wajib diisi');
      return;
    }

    final ok = await context.read<MitraService>().saveVehicleGeofence(
          widget.vehicleId,
          id: _editingId,
          name: name,
          centerLat: _center.latitude,
          centerLng: _center.longitude,
          radiusM: _radiusM.round(),
        );
    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'Geofence disimpan');
      await _load();
    } else {
      SnackbarUtils.showError(context, context.read<MitraService>().message ?? 'Gagal menyimpan');
    }
  }

  Future<void> _delete(String id) async {
    final ok = await context.read<MitraService>().deleteVehicleGeofence(widget.vehicleId, id);
    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'Geofence dihapus');
      _editingId = null;
      _nameController.text = 'Area sewa';
      await _load();
    }
  }

  void _selectFence(VehicleGeofenceModel fence) {
    setState(() {
      _editingId = fence.id;
      _nameController.text = fence.name;
      _center = LatLng(fence.centerLat, fence.centerLng);
      _radiusM = fence.radiusM.toDouble();
    });
    _mapController.move(_center, 12);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<MitraService>().vehicles
        .where((v) => v.id == widget.vehicleId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text('Geofence \u2014 ${vehicle?.name ?? 'Kendaraan'}')),
      body: _loading
          ? const AppLoadingView()
          : ListView(
              padding: AppPadding.list,
              children: [
                ClipRRect(
                  borderRadius: AppShapes.md,
                  child: SizedBox(
                    height: 260.h,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: 12,
                        onTap: (_, point) => setState(() => _center = point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.travelindo.app',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _center,
                              radius: _radiusM,
                              useRadiusInMeter: true,
                              color: AppColors.teal.withValues(alpha: 0.15),
                              borderColor: AppColors.teal,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _center,
                              width: 36.w,
                              height: 36.w,
                              child: Icon(LucideIcons.mapPin, color: AppColors.teal, size: 32.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AppGap.sm,
                Text('Ketuk peta untuk pindah pusat zona', style: AppTextStyles.bodySmall),
                AppGap.lg,
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama zona',
                    border: OutlineInputBorder(),
                  ),
                ),
                AppGap.md,
                Text('Radius: ${_radiusM.round()} m', style: AppTextStyles.titleSmall),
                Slider(
                  value: _radiusM,
                  min: 500,
                  max: 20000,
                  divisions: 39,
                  label: '${_radiusM.round()} m',
                  onChanged: (v) => setState(() => _radiusM = v),
                ),
                FilledButton(onPressed: _save, child: const Text('Simpan Geofence')),
                if (_fences.isNotEmpty) ...[
                  AppGap.section,
                  Text('Zona tersimpan', style: AppTextStyles.titleMedium),
                  ..._fences.map(
                    (f) => Card(
                      child: ListTile(
                        selected: f.id == _editingId,
                        title: Text(f.name),
                        subtitle: Text('Radius ${f.radiusM} m'),
                        onTap: () => _selectFence(f),
                        trailing: IconButton(
                          icon: Icon(LucideIcons.trash2, color: AppColors.critical),
                          onPressed: () => _delete(f.id),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
