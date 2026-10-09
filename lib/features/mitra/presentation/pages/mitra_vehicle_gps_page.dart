import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';

class MitraVehicleGpsPage extends StatefulWidget {
  const MitraVehicleGpsPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MitraVehicleGpsPage> createState() => _MitraVehicleGpsPageState();
}

class _MitraVehicleGpsPageState extends State<MitraVehicleGpsPage> {
  final _deviceIdController = TextEditingController();
  final _vendorController = TextEditingController(text: 'generic');
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<MitraService>().loadVehicles();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  Future<void> _pair() async {
    final deviceId = _deviceIdController.text.trim();
    if (deviceId.isEmpty) {
      SnackbarUtils.showError(context, 'Device ID / IMEI wajib diisi');
      return;
    }

    final ok = await context.read<MitraService>().pairGpsDevice(
          widget.vehicleId,
          deviceId: deviceId,
          vendor: _vendorController.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'GPS berhasil dipasangkan');
    } else {
      SnackbarUtils.showError(context, context.read<MitraService>().message ?? 'Gagal pairing');
    }
  }

  Future<void> _unpair() async {
    final ok = await context.read<MitraService>().unpairGpsDevice(widget.vehicleId);
    if (!mounted) return;
    if (ok) {
      _deviceIdController.clear();
      SnackbarUtils.showSuccess(context, 'GPS dilepas');
    } else {
      SnackbarUtils.showError(context, context.read<MitraService>().message ?? 'Gagal unpair');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<MitraService>().vehicles
        .where((v) => v.id == widget.vehicleId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(vehicle?.name ?? 'Pasang GPS')),
      body: !_loaded
          ? const AppLoadingView()
          : ListView(
              padding: AppPadding.list,
              children: [
                Icon(LucideIcons.radio, size: 48.sp),
                AppGap.md,
                Text(
                  'Pasangkan GPS tracker ke unit ini dengan memasukkan Device ID / IMEI dari vendor tracker.',
                  style: AppTextStyles.bodyMedium,
                ),
                AppGap.v(AppSpacing.xxl),
                TextField(
                  controller: _deviceIdController,
                  decoration: const InputDecoration(
                    labelText: 'Device ID / IMEI',
                    hintText: 'Contoh: 867530012345678',
                    border: OutlineInputBorder(),
                  ),
                ),
                AppGap.lg,
                TextField(
                  controller: _vendorController,
                  decoration: const InputDecoration(
                    labelText: 'Vendor (opsional)',
                    hintText: 'generic, concox, teltonika',
                    border: OutlineInputBorder(),
                  ),
                ),
                AppGap.v(AppSpacing.xxl),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutePaths.mitraVehicleGeofence(widget.vehicleId)),
                  icon: Icon(LucideIcons.circleDashed),
                  label: const Text('Atur Geofence (zona sewa)'),
                ),
                AppGap.sm,
                FilledButton(onPressed: _pair, child: const Text('Simpan / Pair')),
                AppGap.sm,
                OutlinedButton(onPressed: _unpair, child: const Text('Lepas GPS')),
              ],
            ),
    );
  }
}
