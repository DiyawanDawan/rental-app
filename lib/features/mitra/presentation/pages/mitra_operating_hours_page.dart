import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MitraOperatingHoursPage extends StatefulWidget {
  const MitraOperatingHoursPage({super.key});

  @override
  State<MitraOperatingHoursPage> createState() =>
      _MitraOperatingHoursPageState();
}

class _MitraOperatingHoursPageState extends State<MitraOperatingHoursPage> {
  final List<String> _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  final List<Map<String, dynamic>> _editedHours = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await context.read<MitraService>().loadOperatingHours();
    final current = context.read<MitraService>().operatingHours;
    setState(() {
      _editedHours.clear();
      for (var index = 0; index < _days.length; index++) {
        final dayOfWeek = index == 6 ? 0 : index + 1;
        final existing = current.firstWhere(
          (h) => h['dayOfWeek'] == dayOfWeek,
          orElse: () => {
            'dayOfWeek': dayOfWeek,
            'isClosed': false,
            'openTime': '08:00',
            'closeTime': '17:00',
          },
        );
        _editedHours.add(Map.from(existing));
      }
    });
  }

  Future<void> _selectTime(int index, bool isOpenTime) async {
    final initialTimeStr = isOpenTime
        ? _editedHours[index]['openTime']
        : _editedHours[index]['closeTime'];
    final parts = initialTimeStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        final timeStr =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isOpenTime) {
          _editedHours[index]['openTime'] = timeStr;
        } else {
          _editedHours[index]['closeTime'] = timeStr;
        }
      });
    }
  }

  Future<void> _save() async {
    final payload = _editedHours
        .map(
          (hour) => {
            'dayOfWeek': hour['dayOfWeek'],
            'openTime': hour['openTime'],
            'closeTime': hour['closeTime'],
            'isClosed': hour['isClosed'] == true,
          },
        )
        .toList();
    final success = await context.read<MitraService>().updateOperatingHours(
      payload,
    );
    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Jam operasional berhasil diperbarui');
      Navigator.pop(context);
    } else {
      // M3 FIX: Show error feedback when save fails.
      final err = context.read<MitraService>().message;
      SnackbarUtils.showError(context, err ?? 'Gagal menyimpan jam operasional');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<MitraService>().status == MitraStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jam Operasional'),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: _save,
              icon: Icon(LucideIcons.check),
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: isLoading && _editedHours.isEmpty
          ? const AppLoadingView()
          : ListView(
              padding: AppPadding.list,
              children: [
                Container(
                  padding: AppPadding.card,
                  decoration: AppDecorations.elevatedSurface(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atur jam buka toko per hari — pelanggan melihat ketersediaan mitra.',
                        style: AppTextStyles.bodySmall,
                      ),
                      AppGap.lg,
                      ...List.generate(_editedHours.length, (index) {
                        final h = _editedHours[index];
                        final dayLabel = _getDayLabel(h['dayOfWeek']);
                        final isLast = index == _editedHours.length - 1;

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dayLabel,
                                          style: AppTextStyles.titleSmall,
                                        ),
                                      ),
                                      Switch(
                                        value: !(h['isClosed'] ?? false),
                                        onChanged: (val) => setState(
                                          () => h['isClosed'] = !val,
                                        ),
                                        activeColor: AppColors.orange,
                                      ),
                                    ],
                                  ),
                                  if (h['isClosed'] != true)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _TimeBox(
                                            label: 'Buka',
                                            time: h['openTime'],
                                            onTap: () =>
                                                _selectTime(index, true),
                                          ),
                                        ),
                                        AppGap.h(AppSpacing.lg),
                                        Expanded(
                                          child: _TimeBox(
                                            label: 'Tutup',
                                            time: h['closeTime'],
                                            onTap: () =>
                                                _selectTime(index, false),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Toko Tutup',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.critical,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _getDayLabel(int? dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 0:
        return 'Minggu';
      default:
        return 'Hari';
    }
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.time,
    required this.onTap,
  });
  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.page,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: AppShapes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            AppGap.xs,
            Text(time, style: AppTextStyles.titleSmall),
          ],
        ),
      ),
    );
  }
}
