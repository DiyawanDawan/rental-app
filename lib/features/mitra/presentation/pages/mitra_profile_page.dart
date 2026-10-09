import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/badges/verified_badge.dart';
import '../../../../core/widgets/map/location_picker_page.dart';
import '../../application/mitra_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MitraProfilePage extends StatefulWidget {
  const MitraProfilePage({super.key});

  @override
  State<MitraProfilePage> createState() => _MitraProfilePageState();
}

class _MitraProfilePageState extends State<MitraProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  LatLng? _selectedLocation;
  String? _bannerPath;
  String? _currentBannerUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final profile = context.read<MitraService>().profile;
    if (profile != null) {
      _storeNameController.text = profile.storeName;
      _descriptionController.text = profile.description ?? '';
      _addressController.text = profile.address ?? '';
      _phoneController.text = profile.phoneNumber;
      _currentBannerUrl = profile.bannerUrl;
      if (profile.latitude != null && profile.longitude != null) {
        _selectedLocation = LatLng(profile.latitude!, profile.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _bannerPath = image.path;
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(initialLocation: _selectedLocation),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result['latlng'] as LatLng;
        if (_addressController.text.isEmpty) {
          _addressController.text = result['address'] as String;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await context.read<MitraService>().updateProfile(
      {
        'storeName': _storeNameController.text.trim(),
        'storeDescription': _descriptionController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      },
      bannerPath: _bannerPath,
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Profil mitra berhasil diperbarui');
    } else {
      SnackbarUtils.showError(context, context.read<MitraService>().message ?? 'Gagal memperbarui profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = context.watch<MitraService>().profile?.isVerified ?? false;

    return Scaffold(
      appBar: AppBar(title: Text('Profil Mitra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.screen,
          children: [
            if (isVerified)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: const VerifiedBadge.banner(),
              ),
            Text('Banner Toko', style: AppTextStyles.titleSmall),
            AppGap.sm,
            InkWell(
              onTap: _pickBanner,
              child: Container(
                height: 150.h,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.2),
                  borderRadius: AppShapes.md,
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: _bannerPath != null
                    ? ClipRRect(
                        borderRadius: AppShapes.md,
                        child: Image.file(File(_bannerPath!), fit: BoxFit.cover),
                      )
                    : _currentBannerUrl != null
                        ? ClipRRect(
                            borderRadius: AppShapes.md,
                            child: CachedNetworkImage(imageUrl: _currentBannerUrl!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.imagePlus, size: 32.sp, color: AppColors.lightGray),
                              AppGap.sm,
                              Text('Upload Banner Toko', style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray)),
                            ],
                          ),
              ),
            ),
            AppGap.section,
            _buildTextField(_storeNameController, 'Nama Toko/Rental', LucideIcons.store),
            AppGap.lg,
            _buildTextField(
              _descriptionController,
              'Deskripsi Toko',
              LucideIcons.fileText,
              maxLines: 4,
            ),
            AppGap.lg,
            _buildTextField(_phoneController, 'Nomor Telepon Bisnis', LucideIcons.phone, keyboardType: TextInputType.phone),
            AppGap.lg,
            Text('Lokasi Kantor/Penjemputan', style: AppTextStyles.titleSmall),
            AppGap.sm,
            InkWell(
              onTap: _pickLocation,
              child: Container(
                padding: AppPadding.list,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: AppShapes.sm,
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.mapPin, color: AppColors.orange),
                    AppGap.h(AppSpacing.md),
                    Expanded(
                      child: Text(
                        _selectedLocation == null
                            ? 'Pilih lokasi di peta'
                            : 'Lokasi Terpilih: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, size: 16.sp),
                  ],
                ),
              ),
            ),
            AppGap.lg,
            _buildTextField(_addressController, 'Alamat Lengkap', LucideIcons.map, maxLines: 3),
            AppGap.ctaSpacer,
            ElevatedButton(
              onPressed: _save,
              child: Text('Simpan Profil Mitra'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20.sp),
        border: OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (v) => (v == null || v.isEmpty) ? '$label wajib diisi' : null,
    );
  }
}
