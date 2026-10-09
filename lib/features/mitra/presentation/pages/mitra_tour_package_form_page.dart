import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';

class MitraTourPackageFormPage extends StatefulWidget {
  const MitraTourPackageFormPage({this.packageId, super.key});

  final String? packageId;

  @override
  State<MitraTourPackageFormPage> createState() => _MitraTourPackageFormPageState();
}

class _MitraTourPackageFormPageState extends State<MitraTourPackageFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxPassengersController = TextEditingController(text: '4');
  final _durationController = TextEditingController();

  List<Map<String, dynamic>> _destinations = [];
  final Set<String> _selectedDestinationIds = {};
  bool _loading = true;
  bool _submitting = false;

  bool get _isEdit => widget.packageId != null && widget.packageId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final service = context.read<MitraService>();
    _destinations = await service.getTourDestinations();

    if (_isEdit) {
      await service.loadTourPackages();
      final pkg = service.tourPackages.firstWhere(
        (p) => p['id']?.toString() == widget.packageId,
        orElse: () => <String, dynamic>{},
      );
      if (pkg.isNotEmpty) {
        _nameController.text = pkg['name']?.toString() ?? '';
        _descriptionController.text = pkg['description']?.toString() ?? '';
        _priceController.text = (pkg['basePrice'] as num?)?.toString() ?? '';
        _maxPassengersController.text = (pkg['maxPassengers'] as num?)?.toString() ?? '4';
        _durationController.text = pkg['durationText']?.toString() ?? '';
        final dests = (pkg['destinations'] as List?) ?? [];
        for (final d in dests) {
          if (d is Map<String, dynamic>) {
            final destId = d['destinationId']?.toString() ?? d['id']?.toString();
            if (destId != null) _selectedDestinationIds.add(destId);
          }
        }
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxPassengersController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isEdit && _selectedDestinationIds.isEmpty) {
      SnackbarUtils.showError(context, 'Pilih minimal satu destinasi');
      return;
    }

    setState(() => _submitting = true);
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'basePrice': double.parse(_priceController.text.trim()),
      'maxPassengers': int.parse(_maxPassengersController.text.trim()),
      if (_durationController.text.isNotEmpty) 'durationText': _durationController.text.trim(),
    };
    if (!_isEdit) {
      data['destinations'] = _selectedDestinationIds.toList();
    }

    final service = context.read<MitraService>();
    final success = _isEdit
        ? await service.updateTourPackage(widget.packageId!, data)
        : await service.createTourPackage(data);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      SnackbarUtils.showSuccess(context, _isEdit ? 'Paket diperbarui' : 'Paket dibuat');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: AppLoadingView());

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Paket Wisata' : 'Tambah Paket Wisata')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.list,
          children: [
            Container(
              padding: AppPadding.card,
              decoration: AppDecorations.elevatedSurface(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail paket wisata — harga, durasi, dan destinasi yang disertakan.',
                    style: AppTextStyles.bodySmall,
                  ),
                  AppGap.lg,
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Paket', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length < 3) ? 'Minimal 3 karakter' : null,
                  ),
                  AppGap.md,
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  AppGap.md,
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Harga Dasar (Rp)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Harga tidak valid' : null,
                  ),
                  AppGap.md,
                  TextFormField(
                    controller: _maxPassengersController,
                    decoration: const InputDecoration(labelText: 'Maks. Penumpang', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Jumlah tidak valid' : null,
                  ),
                  AppGap.md,
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Durasi (cth: 3D2N)', border: OutlineInputBorder()),
                  ),
                  AppGap.section,
                  Text('Destinasi', style: AppTextStyles.titleMedium),
                  AppGap.sm,
                  if (_destinations.isEmpty)
                    Text('Destinasi belum tersedia. Hubungi admin.', style: AppTextStyles.bodySmall)
                  else
                    ..._destinations.map((dest) {
                      final id = dest['id']?.toString() ?? '';
                      final name = dest['name']?.toString() ?? id;
                      return CheckboxListTile(
                        value: _selectedDestinationIds.contains(id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedDestinationIds.add(id);
                            } else {
                              _selectedDestinationIds.remove(id);
                            }
                          });
                        },
                        title: Text(name),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
                ],
              ),
            ),
            AppGap.section,
            ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: Icon(_isEdit ? LucideIcons.save : LucideIcons.plus),
              label: Text(_submitting ? 'Menyimpan...' : (_isEdit ? 'Simpan' : 'Buat Paket')),
            ),
          ],
        ),
      ),
    );
  }
}
