import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';

class MitraDriversPage extends StatefulWidget {
  const MitraDriversPage({super.key});

  @override
  State<MitraDriversPage> createState() => _MitraDriversPageState();
}

class _MitraDriversPageState extends State<MitraDriversPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadDrivers();
    });
  }

  Future<void> _addDriver() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final sim = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pengemudi'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama lengkap'),
                validator: _required,
              ),
              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Nomor telepon'),
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              TextFormField(
                controller: sim,
                decoration: const InputDecoration(labelText: 'Nomor SIM'),
                validator: _required,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(context, {
                'fullName': name.text.trim(),
                'phoneNumber': phone.text.trim(),
                'simNumber': sim.text.trim(),
                'simType': 'SIM_A',
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    name.dispose();
    phone.dispose();
    sim.dispose();
    if (data == null || !mounted) return;
    final success = await context.read<MitraService>().createDriver(data);
    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Pengemudi berhasil ditambahkan');
    } else {
      SnackbarUtils.showError(context, 'Gagal menambahkan pengemudi');
    }
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengemudi'),
        actions: [
          IconButton(
            onPressed: _addDriver,
            icon: const Icon(LucideIcons.userPlus),
            tooltip: 'Tambah pengemudi',
          ),
        ],
      ),
      body: Consumer<MitraService>(
        builder: (context, service, child) {
          if (service.status == MitraStatus.loading &&
              service.drivers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.drivers.isEmpty) {
            return Center(
              child: Padding(
                padding: AppPadding.screen,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.car, size: 48, color: AppColors.lightGray),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada pengemudi',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan pengemudi untuk pesanan dengan layanan supir.',
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: service.loadDrivers,
            child: ListView.separated(
              padding: AppPadding.list,
              itemCount: service.drivers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final driver = service.drivers[index];
                return ListTile(
                  leading: CircleAvatar(child: Icon(LucideIcons.userRound)),
                  title: Text(driver.fullName),
                  subtitle: Text(
                    '${driver.phoneNumber}\nSIM ${driver.simNumber}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      color: AppColors.critical,
                    ),
                    onPressed: () async {
                      final success = await service.deleteDriver(driver.id);
                      if (context.mounted && success) {
                        SnackbarUtils.showSuccess(context, 'Pengemudi dihapus');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
