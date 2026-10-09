import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_vehicle_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MitraVehiclePricingPage extends StatefulWidget {
  const MitraVehiclePricingPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MitraVehiclePricingPage> createState() => _MitraVehiclePricingPageState();
}

class _MitraVehiclePricingPageState extends State<MitraVehiclePricingPage> {
  final _formKey = GlobalKey<FormState>();
  final _driverPriceController = TextEditingController();
  final _fullPackagePriceController = TextEditingController();
  final _depositController = TextEditingController();

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

    if (vehicle.id.isNotEmpty) {
      _driverPriceController.text = vehicle.priceWithDriver?.toString() ?? '';
      _fullPackagePriceController.text = vehicle.priceFullPackage?.toString() ?? '';
      _depositController.text = vehicle.depositAmount?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _driverPriceController.dispose();
    _fullPackagePriceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pricing = {
      if (_driverPriceController.text.isNotEmpty)
        'priceWithDriver': double.parse(_driverPriceController.text),
      if (_fullPackagePriceController.text.isNotEmpty)
        'priceFullPackage': double.parse(_fullPackagePriceController.text),
      if (_depositController.text.isNotEmpty)
        'depositAmount': double.parse(_depositController.text),
    };

    if (pricing.isEmpty) {
      SnackbarUtils.showInfo(context, 'Tidak ada perubahan untuk disimpan');
      return;
    }

    final service = context.read<MitraService>();
    final success = await service.setVehiclePricing(widget.vehicleId, pricing);

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Harga berhasil diperbarui');
      Navigator.pop(context);
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal memperbarui harga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harga Tambahan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.list,
          children: [
            Text(
              'Gunakan halaman ini untuk mengatur harga tambahan selain harga sewa harian lepas kunci.',
              style: AppTextStyles.bodySmall,
            ),
            AppGap.section,
            _buildPriceField(
              _driverPriceController,
              'Harga Dengan Sopir',
              'Harga per hari jika customer menyewa dengan sopir',
            ),
            AppGap.lg,
            _buildPriceField(
              _fullPackagePriceController,
              'Harga Paket Lengkap',
              'Harga per hari termasuk sopir dan BBM',
            ),
            AppGap.lg,
            _buildPriceField(
              _depositController,
              'Biaya Deposit / Jaminan',
              'Uang jaminan yang harus dibayar customer (jika ada)',
            ),
            AppGap.ctaSpacer,
            ElevatedButton(
              onPressed: _submit,
              child: Text('Simpan Harga'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Contoh: 500000',
        helperText: hint,
        prefixIcon: Icon(LucideIcons.banknote, size: 20.sp),
        border: OutlineInputBorder(),
        suffixText: 'IDR',
      ),
    );
  }
}
