import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/buttons/app_buttons.dart';
import '../../../../core/widgets/layout/scroll_safe_padding.dart';
import '../../../../core/widgets/map/location_picker_page.dart';
import '../../application/customer_service.dart';
import '../../data/models/address_model.dart';
import '../../data/models/region_model.dart';
import '../widgets/cascading_region_picker.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({this.initialAddress, super.key});

  final AddressModel? initialAddress;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();

  RegionItemModel? _selectedCountry;
  RegionItemModel? _selectedProvince;
  RegionItemModel? _selectedRegency;
  RegionItemModel? _selectedDistrict;
  RegionItemModel? _selectedVillage;

  LatLng? _selectedLocation;
  bool _isSaving = false;

  bool get _isEdit => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final addr = widget.initialAddress;
    if (addr != null) {
      _addressController.text = addr.fullAddress;
      _zipCodeController.text = addr.zipCode ?? '';
      _selectedCountry = RegionItemModel(
        id: addr.countryId,
        name: addr.countryName ?? 'Indonesia',
      );
      if (addr.provinceId != null) {
        _selectedProvince = RegionItemModel(
          id: addr.provinceId!,
          name: addr.provinceName ?? 'Provinsi Terpilih',
          countryId: addr.countryId,
        );
      }
      if (addr.regencyId != null) {
        _selectedRegency = RegionItemModel(
          id: addr.regencyId!,
          name: addr.regencyName ?? 'Kota Terpilih',
          provinceId: addr.provinceId,
        );
      }
      if (addr.districtId != null) {
        _selectedDistrict = RegionItemModel(
          id: addr.districtId!,
          name: addr.districtName ?? 'Kecamatan Terpilih',
          regencyId: addr.regencyId,
        );
      }
      if (addr.villageId != null) {
        _selectedVillage = RegionItemModel(
          id: addr.villageId!,
          name: addr.villageName ?? 'Desa Terpilih',
          districtId: addr.districtId,
        );
      }
      if (addr.latitude != null && addr.longitude != null) {
        _selectedLocation = LatLng(addr.latitude!, addr.longitude!);
      }
    } else {
      // Auto-load default country (Indonesia)
      _loadDefaultCountry();
    }
  }

  Future<void> _loadDefaultCountry() async {
    final service = context.read<CustomerService>();
    final countries = await service.getRegionsHierarchy();
    if (mounted && countries.isNotEmpty) {
      setState(() {
        _selectedCountry = countries.firstWhere(
          (c) => c.name.toLowerCase() == 'indonesia' || c.code == 'ID',
          orElse: () => countries.first,
        );
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final service = context.read<CustomerService>();
    final result = await showRegionPickerBottomSheet(
      context: context,
      title: 'Pilih Negara',
      loader: () => service.getRegionsHierarchy(),
      selectedItem: _selectedCountry,
    );
    if (result != null && result.id != _selectedCountry?.id) {
      setState(() {
        _selectedCountry = result;
        _selectedProvince = null;
        _selectedRegency = null;
        _selectedDistrict = null;
        _selectedVillage = null;
      });
    }
  }

  Future<void> _pickProvince() async {
    if (_selectedCountry == null) return;
    final service = context.read<CustomerService>();
    final result = await showRegionPickerBottomSheet(
      context: context,
      title: 'Pilih Provinsi',
      loader: () => service.getRegionsHierarchy(countryId: _selectedCountry!.id),
      selectedItem: _selectedProvince,
    );
    if (result != null && result.id != _selectedProvince?.id) {
      setState(() {
        _selectedProvince = result;
        _selectedRegency = null;
        _selectedDistrict = null;
        _selectedVillage = null;
      });
    }
  }

  Future<void> _pickRegency() async {
    if (_selectedProvince == null) return;
    final service = context.read<CustomerService>();
    final result = await showRegionPickerBottomSheet(
      context: context,
      title: 'Pilih Kota / Kabupaten',
      loader: () => service.getRegionsHierarchy(provinceId: _selectedProvince!.id),
      selectedItem: _selectedRegency,
    );
    if (result != null && result.id != _selectedRegency?.id) {
      setState(() {
        _selectedRegency = result;
        _selectedDistrict = null;
        _selectedVillage = null;
      });
    }
  }

  Future<void> _pickDistrict() async {
    if (_selectedRegency == null) return;
    final service = context.read<CustomerService>();
    final result = await showRegionPickerBottomSheet(
      context: context,
      title: 'Pilih Kecamatan',
      loader: () => service.getRegionsHierarchy(regencyId: _selectedRegency!.id),
      selectedItem: _selectedDistrict,
    );
    if (result != null && result.id != _selectedDistrict?.id) {
      setState(() {
        _selectedDistrict = result;
        _selectedVillage = null;
      });
    }
  }

  Future<void> _pickVillage() async {
    if (_selectedDistrict == null) return;
    final service = context.read<CustomerService>();
    final result = await showRegionPickerBottomSheet(
      context: context,
      title: 'Pilih Desa / Kelurahan',
      loader: () => service.getRegionsHierarchy(districtId: _selectedDistrict!.id),
      selectedItem: _selectedVillage,
    );
    if (result != null) {
      setState(() {
        _selectedVillage = result;
      });
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null) {
      final latLng = result['latlng'] as LatLng;
      final addressText = result['address'] as String?;
      setState(() {
        _selectedLocation = latLng;
        if (_addressController.text.trim().isEmpty && addressText != null) {
          _addressController.text = addressText;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih negara terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final service = context.read<CustomerService>();

    final payload = <String, dynamic>{
      'countryId': _selectedCountry!.id,
      'fullAddress': _addressController.text.trim(),
      if (_selectedProvince != null) 'provinceId': _selectedProvince!.id,
      if (_selectedRegency != null) 'regencyId': _selectedRegency!.id,
      if (_selectedDistrict != null) 'districtId': _selectedDistrict!.id,
      if (_selectedVillage != null) 'villageId': _selectedVillage!.id,
      if (_zipCodeController.text.trim().isNotEmpty)
        'zipCode': _zipCodeController.text.trim(),
      if (_selectedLocation != null) ...{
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      },
    };

    bool success;
    if (_isEdit) {
      success = await service.updateAddress(widget.initialAddress!.id, payload);
    } else {
      success = await service.createAddress(payload);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Alamat berhasil diperbarui' : 'Alamat berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(service.message ?? 'Gagal menyimpan alamat'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Alamat' : 'Tambah Alamat'),
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: ScrollSafePadding.withFab(
          horizontal: AppSpacing.page,
          top: AppSpacing.page,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Geographic Hierarchy
              Text('Wilayah Administratif', style: AppTextStyles.titleMedium),
              AppGap.xs,
              Text(
                'Pilih wilayah bertingkat untuk akurasi pengantaran',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
              AppGap.md,

              _buildDropdownSelector(
                label: 'Negara',
                value: _selectedCountry?.name ?? 'Pilih Negara',
                icon: LucideIcons.globe,
                onTap: _pickCountry,
                isEnabled: true,
              ),
              AppGap.sm,

              _buildDropdownSelector(
                label: 'Provinsi',
                value: _selectedProvince?.name ?? 'Pilih Provinsi',
                icon: LucideIcons.map,
                onTap: _pickProvince,
                isEnabled: _selectedCountry != null,
              ),
              AppGap.sm,

              _buildDropdownSelector(
                label: 'Kota / Kabupaten',
                value: _selectedRegency?.name ?? 'Pilih Kota / Kabupaten',
                icon: LucideIcons.building,
                onTap: _pickRegency,
                isEnabled: _selectedProvince != null,
              ),
              AppGap.sm,

              _buildDropdownSelector(
                label: 'Kecamatan',
                value: _selectedDistrict?.name ?? 'Pilih Kecamatan',
                icon: LucideIcons.navigation,
                onTap: _pickDistrict,
                isEnabled: _selectedRegency != null,
              ),
              AppGap.sm,

              _buildDropdownSelector(
                label: 'Desa / Kelurahan',
                value: _selectedVillage?.name ?? 'Pilih Desa / Kelurahan (Opsional)',
                icon: LucideIcons.mapPin,
                onTap: _pickVillage,
                isEnabled: _selectedDistrict != null,
              ),
              AppGap.lg,

              // Section 2: Address Details
              Text('Detail Alamat', style: AppTextStyles.titleMedium),
              AppGap.md,

              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap *',
                  hintText: 'Nama jalan, no. rumah, RT/RW, atau patokan',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(LucideIcons.mapPin, size: 20, color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 5) {
                    return 'Alamat lengkap minimal 5 karakter';
                  }
                  return null;
                },
              ),
              AppGap.md,

              TextFormField(
                controller: _zipCodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kode Pos (Opsional)',
                  hintText: 'Contoh: 10350',
                  prefixIcon: const Icon(LucideIcons.mail, size: 20, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              AppGap.lg,

              // Section 3: GPS Map Pin
              Text('Titik Koordinat (Peta)', style: AppTextStyles.titleMedium),
              AppGap.xs,
              Text(
                'Sematkan pin peta untuk memudahkan kurir dan mitra menjemput',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
              AppGap.md,

              OutlinedButton.icon(
                onPressed: _pickLocationOnMap,
                icon: const Icon(LucideIcons.mapPin),
                label: Text(
                  _selectedLocation == null
                      ? 'Pilih Lokasi di Peta'
                      : 'Koordinat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _selectedLocation != null ? AppColors.tertiary : AppColors.primary,
                  side: BorderSide(
                    color: _selectedLocation != null ? AppColors.tertiary : AppColors.border,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                  ),
                ),
              ),
              AppGap.xl,

              // Submit Button
              AppPrimaryButton(
                label: _isEdit ? 'Perbarui Alamat' : 'Simpan Alamat',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submitForm,
              ),
              AppGap.xl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surfaceMuted : AppColors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppShapes.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isEnabled ? AppColors.primary : AppColors.textTertiary,
            ),
            AppGap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
                      fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              size: 18.sp,
              color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
