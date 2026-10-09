import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_vehicle_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MitraVehicleBlockedDatesPage extends StatefulWidget {
  const MitraVehicleBlockedDatesPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MitraVehicleBlockedDatesPage> createState() => _MitraVehicleBlockedDatesPageState();
}

/// Stores each blocked date as a Map with 'date' and optional 'reason'.
class _MitraVehicleBlockedDatesPageState extends State<MitraVehicleBlockedDatesPage> {
  /// Each entry: { 'date': 'YYYY-MM-DD', 'reason': String? }
  final List<Map<String, String?>> _blockedDates = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final vehicle = context.read<MitraService>().vehicles.firstWhere(
          (v) => v.id == widget.vehicleId,
          orElse: () => const MitraVehicleModel(id: '', name: '', status: ''),
        );

    if (vehicle.id.isNotEmpty && vehicle.blockedDates != null) {
      setState(() {
        _blockedDates.addAll(
          vehicle.blockedDates!.map((d) => {'date': d, 'reason': null}),
        );
      });
    }
  }

  Future<void> _addDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null || !mounted) return;

    final dateStr = picked.toIso8601String().split('T')[0];
    if (_blockedDates.any((e) => e['date'] == dateStr)) {
      SnackbarUtils.showError(context, 'Tanggal $dateStr sudah ada dalam daftar');
      return;
    }

    // Ask for optional reason
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Tanggal: $dateStr'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Alasan (opsional)',
            hintText: 'Cth: Servis rutin, Dipakai sendiri',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tambah')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _blockedDates.add({
          'date': dateStr,
          'reason': reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
        });
        _blockedDates.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
      });
    }
  }

  Future<void> _save() async {
    final service = context.read<MitraService>();
    final dates = _blockedDates.map((e) => e['date']!).toList();
    // Individual per-date reasons are not yet supported by the API.
    // Pass the first non-null reason as a general note.
    final firstReason = _blockedDates
        .map((e) => e['reason'])
        .whereType<String>()
        .firstOrNull;

    final success = await service.setVehicleBlockedDates(
      widget.vehicleId,
      dates,
      reason: firstReason,
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Jadwal berhasil diperbarui');
      Navigator.pop(context);
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal memperbarui jadwal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanggal Blocked'),
      ),
      body: ListView(
        padding: AppPadding.list,
        children: [
          Text(
            'Tandai tanggal di mana armada ini tidak tersedia untuk disewa (misalnya sedang diservis atau dipakai sendiri).',
            style: AppTextStyles.bodySmall,
          ),
          AppGap.section,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daftar Tanggal', style: AppTextStyles.titleMedium),
              ElevatedButton.icon(
                onPressed: _addDate,
                icon: Icon(LucideIcons.calendarPlus, size: 16.sp),
                label: const Text('Tambah'),
              ),
            ],
          ),
          AppGap.md,
          if (_blockedDates.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl + AppSpacing.lg),
                child: const Text('Semua tanggal tersedia'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _blockedDates.length,
              itemBuilder: (context, index) {
                final entry = _blockedDates[index];
                final reason = entry['reason'];
                return Container(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: AppDecorations.floatingCard(),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: Icon(LucideIcons.calendarX, color: AppColors.critical),
                    title: Text(entry['date'] ?? ''),
                    subtitle: reason != null && reason.isNotEmpty
                        ? Text(reason, style: AppTextStyles.bodySmall)
                        : null,
                    trailing: IconButton(
                      icon: Icon(LucideIcons.trash2, size: 20.sp, color: AppColors.critical),
                      onPressed: () {
                        setState(() {
                          _blockedDates.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          AppGap.ctaSpacer,
          ElevatedButton(
            onPressed: _save,
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
