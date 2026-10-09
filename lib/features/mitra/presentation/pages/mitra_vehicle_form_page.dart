import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_vehicle_model.dart';
import '../../data/models/vehicle_enums.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MitraVehicleFormPage extends StatefulWidget {
  const MitraVehicleFormPage({this.vehicleId, super.key});

  final String? vehicleId;

  @override
  State<MitraVehicleFormPage> createState() => _MitraVehicleFormPageState();
}

class _MitraVehicleFormPageState extends State<MitraVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = VehicleTypeEnum.car.value;
  String _transmission = TransmissionTypeEnum.matic.value;
  String _rentalType = RentalTypeEnum.rental.value;
  bool _isInstantBooking = false;
  final List<File> _imageFiles = [];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.vehicleId != null;
    if (_isEdit) {
      _loadVehicleData();
    }
  }

  void _loadVehicleData() {
    final vehicle = context.read<MitraService>().vehicles.firstWhere(
          (v) => v.id == widget.vehicleId,
          orElse: () => const MitraVehicleModel(id: '', name: '', status: ''),
        );
    
    if (vehicle.id.isNotEmpty) {
      _nameController.text = vehicle.name;
      _brandController.text = vehicle.brand ?? '';
      _modelController.text = vehicle.model ?? '';
      _yearController.text = vehicle.year?.toString() ?? '';
      _plateController.text = vehicle.licensePlate ?? '';
      _priceController.text = vehicle.pricePerDay.toString();
      _capacityController.text = vehicle.seatingCapacity?.toString() ?? '';
      _colorController.text = vehicle.color ?? '';
      _descriptionController.text = vehicle.description ?? '';
      _type = vehicle.type.isNotEmpty ? vehicle.type : VehicleTypeEnum.car.value;
      _transmission = vehicle.transmission ?? TransmissionTypeEnum.matic.value;
      _rentalType = vehicle.rentalType ?? RentalTypeEnum.rental.value;
      _isInstantBooking = vehicle.isInstantBooking;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isEmpty) return;

    setState(() {
      final remaining = 8 - _imageFiles.length;
      _imageFiles.addAll(
        pickedFiles.take(remaining).map((f) => File(f.path)),
      );
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'type': _type,
      'year': int.tryParse(_yearController.text) ?? 2024,
      'transmission': _transmission,
      'licensePlate': _plateController.text.trim(),
      'color': _colorController.text.trim(),
      'seatingCapacity': int.tryParse(_capacityController.text) ?? 4,
      'pricePerDay': double.tryParse(_priceController.text) ?? 0,
      'description': _descriptionController.text.trim(),
      'rentalType': _rentalType,
      'isInstantBooking': _isInstantBooking,
    };

    final service = context.read<MitraService>();
    bool success;
    
    if (_isEdit) {
      success = await service.updateVehicle(widget.vehicleId!, data);
    } else {
      if (_imageFiles.isEmpty) {
        SnackbarUtils.showError(context, 'Minimal 1 foto kendaraan wajib diupload');
        return;
      }
      success = await service.createVehicle(
        data,
        photoPaths: _imageFiles.map((f) => f.path).toList(),
      );
    }

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Berhasil menyimpan data kendaraan');
      context.pop();
    } else {
      final failure = service.lastFailure;
      final details = failure?.details;
      final upgradeRequired = details is Map && details['upgradeRequired'] == true;
      final isLimitError = failure?.statusCode == 403 &&
          (upgradeRequired ||
              failure?.message.contains('Upgrade') == true ||
              failure?.message.contains('PRO') == true);
      if (isLimitError) {
        final upgrade = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Batas armada tercapai'),
            content: Text(failure?.message ?? 'Upgrade ke PRO untuk menambah kendaraan'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tutup')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Upgrade PRO')),
            ],
          ),
        );
        if (upgrade == true && mounted) {
          context.push(AppRoutePaths.mitraSubscription);
        }
      } else {
        SnackbarUtils.showError(context, service.message ?? 'Gagal menyimpan data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MitraService>();
    final isLoading = service.status == MitraStatus.loading;
    final uploadProgress = service.uploadProgress;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.list,
          children: [
            if (!_isEdit) ...[
              _buildImagePicker(),
              AppGap.section,
            ],
            Container(
              padding: AppPadding.card,
              decoration: AppDecorations.elevatedSurface(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi armada untuk pelanggan — spesifikasi, harga, dan deskripsi.',
                    style: AppTextStyles.bodySmall,
                  ),
                  AppGap.lg,
                  _buildTextField(_nameController, 'Nama Kendaraan', 'Contoh: Avanza Veloz', LucideIcons.car),
                  AppGap.lg,
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_brandController, 'Brand', 'Toyota', LucideIcons.tag)),
                      AppGap.h(AppSpacing.lg),
                      Expanded(child: _buildTextField(_modelController, 'Model', 'Veloz', LucideIcons.type)),
                    ],
                  ),
                  AppGap.lg,
                  Row(
                    children: [
                      Expanded(child: _buildTypeDropdown()),
                      AppGap.h(AppSpacing.lg),
                      Expanded(child: _buildTransmissionDropdown()),
                    ],
                  ),
                  AppGap.lg,
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_yearController, 'Tahun', '2023', LucideIcons.calendar, keyboardType: TextInputType.number)),
                      AppGap.h(AppSpacing.lg),
                      Expanded(child: _buildTextField(_plateController, 'Plat Nomor', 'B 1234 ABC', LucideIcons.hash)),
                    ],
                  ),
                  AppGap.lg,
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_capacityController, 'Kapasitas', '7', LucideIcons.users, keyboardType: TextInputType.number)),
                      AppGap.h(AppSpacing.lg),
                      Expanded(child: _buildTextField(_colorController, 'Warna', 'Hitam', LucideIcons.palette)),
                    ],
                  ),
                  AppGap.lg,
                  _buildTextField(_priceController, 'Harga Per Hari (Rp)', '350000', LucideIcons.banknote, keyboardType: TextInputType.number),
                  AppGap.lg,
                  _buildRentalTypeDropdown(),
                  AppGap.lg,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pemesanan Instan'),
                    subtitle: const Text('Pelanggan bisa langsung memesan tanpa konfirmasi manual'),
                    value: _isInstantBooking,
                    onChanged: (v) => setState(() => _isInstantBooking = v),
                  ),
                  AppGap.lg,
                  _buildTextField(_descriptionController, 'Deskripsi', 'Kondisi mulus, servis rutin...', LucideIcons.fileText, maxLines: 3),
                ],
              ),
            ),
            AppGap.section,
            if (_isEdit) ...[
              const Divider(),
              AppGap.lg,
              Text('Pengaturan Lanjutan', style: AppTextStyles.titleMedium),
              AppGap.md,
              _buildAdvancedButton(
                'Kelola Foto',
                'Tambah atau hapus foto armada',
                LucideIcons.images,
                () => context.push(AppRoutePaths.mitraVehiclePhotos(widget.vehicleId!)),
              ),
              _buildAdvancedButton(
                'Atur Harga Tambahan',
                'Set harga driver atau paket lengkap',
                LucideIcons.banknote,
                () => context.push(AppRoutePaths.mitraVehiclePricing(widget.vehicleId!)),
              ),
              _buildAdvancedButton(
                'Tanggal Tidak Tersedia',
                'Tandai tanggal saat armada libur',
                LucideIcons.calendarX,
                () => context.push(AppRoutePaths.mitraVehicleBlockedDates(widget.vehicleId!)),
              ),
              if (_type == 'BUS' || _type == 'VAN')
                _buildAdvancedButton(
                  'Denah Kursi Bus',
                  'Atur layout kursi & harga tier',
                  LucideIcons.layoutGrid,
                  () => context.push(AppRoutePaths.mitraVehicleSeatMap(widget.vehicleId!)),
                ),
              AppGap.section,
            ],
            AppGap.sm,
            if (isLoading && uploadProgress != null) ...[
              LinearProgressIndicator(value: uploadProgress),
              AppGap.sm,
              Text(
                service.uploadProgressLabel ?? 'Mengunggah foto...',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppGap.md,
            ],
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: Text(_isEdit ? 'Update Armada' : 'Simpan Armada'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto Kendaraan (1–8)', style: AppTextStyles.titleSmall),
        AppGap.sm,
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: _imageFiles.isEmpty ? 120.h : null,
            constraints: BoxConstraints(minHeight: 80.h),
            padding: AppPadding.card,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.3),
              borderRadius: AppShapes.md,
              border: Border.all(color: AppColors.lightGray),
            ),
            child: _imageFiles.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.imagePlus, size: 40.sp, color: AppColors.navy),
                      AppGap.sm,
                      Text('Pilih foto armada'),
                    ],
                  )
                : Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final file in _imageFiles)
                        ClipRRect(
                          borderRadius: AppShapes.sm,
                          child: Image.file(file, width: 72.w, height: 72.w, fit: BoxFit.cover),
                        ),
                      if (_imageFiles.length < 8)
                        InkWell(
                          onTap: _pickImages,
                          child: Container(
                            width: 72.w,
                            height: 72.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.lightGray),
                              borderRadius: AppShapes.sm,
                            ),
                            child: Icon(LucideIcons.plus, color: AppColors.navy),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.sp),
        border: OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      decoration: InputDecoration(
        labelText: 'Tipe',
        prefixIcon: Icon(LucideIcons.list, size: 20.sp),
        border: OutlineInputBorder(),
      ),
      items: VehicleTypeEnum.values
          .map((e) => DropdownMenuItem(value: e.value, child: Text(e.label)))
          .toList(),
      onChanged: (value) => setState(() => _type = value!),
    );
  }

  Widget _buildTransmissionDropdown() {
    return DropdownButtonFormField<String>(
      value: _transmission,
      decoration: InputDecoration(
        labelText: 'Transmisi',
        prefixIcon: Icon(LucideIcons.settings2, size: 20.sp),
        border: OutlineInputBorder(),
      ),
      items: TransmissionTypeEnum.values
          .map((e) => DropdownMenuItem(value: e.value, child: Text(e.label)))
          .toList(),
      onChanged: (value) => setState(() => _transmission = value!),
    );
  }

  Widget _buildRentalTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _rentalType,
      decoration: InputDecoration(
        labelText: 'Tipe Sewa',
        prefixIcon: Icon(LucideIcons.repeat, size: 20.sp),
        border: OutlineInputBorder(),
      ),
      items: RentalTypeEnum.values
          .map((e) => DropdownMenuItem(value: e.value, child: Text(e.label)))
          .toList(),
      onChanged: (value) => setState(() => _rentalType = value!),
    );
  }

  Widget _buildAdvancedButton(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return AnimatedInkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        decoration: AppDecorations.floatingCard(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.navy),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
