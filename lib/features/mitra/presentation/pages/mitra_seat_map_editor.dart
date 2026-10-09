import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Editor denah kursi bus untuk kendaraan SHUTTLE / BOTH.
class MitraSeatMapEditorPage extends StatefulWidget {
  const MitraSeatMapEditorPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MitraSeatMapEditorPage> createState() => _MitraSeatMapEditorPageState();
}

class _MitraSeatMapEditorPageState extends State<MitraSeatMapEditorPage> {
  int _rows = 10;
  int _leftSeats = 2;
  int _rightSeats = 2;
  double _regularPrice = 100000;
  double _vipPrice = 150000;
  double _windowPrice = 120000;
  bool _vipFrontRow = true;
  bool _windowOuter = true;

  Future<void> _save() async {
    final seatMap = _buildSeatMap();
    final success = await context.read<MitraService>().updateVehicle(widget.vehicleId, {
      'seatMap': seatMap,
    });

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Denah kursi berhasil disimpan');
      context.pop();
    } else {
      SnackbarUtils.showError(
        context,
        context.read<MitraService>().message ?? 'Gagal menyimpan denah kursi',
      );
    }
  }

  Map<String, dynamic> _buildSeatMap() {
    const leftLetters = ['A', 'B', 'C'];
    const rightLetters = ['C', 'D', 'E'];
    final rows = <Map<String, dynamic>>[];

    for (var r = 1; r <= _rows; r++) {
      final seats = <Map<String, dynamic>>[];

      for (var i = 0; i < _leftSeats; i++) {
        final code = '$r${leftLetters[i]}';
        seats.add(_seatEntry(code, r, i, _leftSeats, true));
      }
      for (var i = 0; i < _rightSeats; i++) {
        final code = '$r${rightLetters[i]}';
        seats.add(_seatEntry(code, r, i, _rightSeats, false));
      }

      rows.add({'label': r.toString(), 'seats': seats});
    }

    return {'rows': rows};
  }

  Map<String, dynamic> _seatEntry(String code, int row, int index, int sideCount, bool isLeft) {
    var tier = 'REGULAR';
    var price = _regularPrice;

    if (_vipFrontRow && row == 1) {
      tier = 'VIP';
      price = _vipPrice;
    } else if (_windowOuter && (index == 0 || index == sideCount - 1)) {
      tier = 'WINDOW';
      price = _windowPrice;
    }

    return {'code': code, 'tier': tier, 'price': price.round()};
  }

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'bus_2_2':
          _rows = 12;
          _leftSeats = 2;
          _rightSeats = 2;
        case 'bus_2_1':
          _rows = 10;
          _leftSeats = 2;
          _rightSeats = 1;
        case 'minibus':
          _rows = 4;
          _leftSeats = 2;
          _rightSeats = 2;
          _regularPrice = 75000;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MitraService>().status == MitraStatus.loading;
    final preview = _buildSeatMap();
    final totalSeats = (preview['rows'] as List).fold<int>(
      0,
      (sum, row) => sum + ((row as Map)['seats'] as List).length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Denah Kursi Bus')),
      body: ListView(
        padding: AppPadding.list,
        children: [
          Text('Preset Layout', style: AppTextStyles.titleSmall),
          AppGap.sm,
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ActionChip(label: const Text('Bus 2-2'), onPressed: () => _applyPreset('bus_2_2')),
              ActionChip(label: const Text('Bus 2-1'), onPressed: () => _applyPreset('bus_2_1')),
              ActionChip(label: const Text('Minibus'), onPressed: () => _applyPreset('minibus')),
            ],
          ),
          AppGap.section,
          Text('Konfigurasi', style: AppTextStyles.titleSmall),
          AppGap.sm,
          _sliderRow('Baris', _rows.toDouble(), 3, 20, (v) => setState(() => _rows = v.round())),
          _sliderRow('Kursi kiri', _leftSeats.toDouble(), 1, 3, (v) => setState(() => _leftSeats = v.round())),
          _sliderRow('Kursi kanan', _rightSeats.toDouble(), 1, 3, (v) => setState(() => _rightSeats = v.round())),
          SwitchListTile(
            title: const Text('Baris depan = VIP'),
            value: _vipFrontRow,
            onChanged: (v) => setState(() => _vipFrontRow = v),
          ),
          SwitchListTile(
            title: const Text('Kursi pinggir = Jendela'),
            value: _windowOuter,
            onChanged: (v) => setState(() => _windowOuter = v),
          ),
          AppGap.md,
          Text('Harga per Tier (Rp)', style: AppTextStyles.titleSmall),
          AppGap.sm,
          _priceField('Reguler', _regularPrice, (v) => _regularPrice = v),
          _priceField('VIP', _vipPrice, (v) => _vipPrice = v),
          _priceField('Jendela', _windowPrice, (v) => _windowPrice = v),
          AppGap.section,
          Card(
            child: Padding(
              padding: AppPadding.list,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.bus, size: 18.sp, color: AppColors.navy),
                      AppGap.h(AppSpacing.sm),
                      Text('Preview: $totalSeats kursi', style: AppTextStyles.titleSmall),
                    ],
                  ),
                  AppGap.sm,
                  Text(
                    '${(preview['rows'] as List).length} baris · $_leftSeats+$_rightSeats per baris',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                  ),
                ],
              ),
            ),
          ),
          AppGap.section,
          ElevatedButton(
            onPressed: isLoading ? null : _save,
            child: Text(isLoading ? 'Menyimpan...' : 'Simpan Denah Kursi'),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}', style: AppTextStyles.bodySmall),
        Slider(value: value, min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
      ],
    );
  }

  Widget _priceField(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        initialValue: value.round().toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) => onChanged(double.tryParse(v) ?? value),
      ),
    );
  }
}
