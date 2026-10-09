import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/layout/scroll_safe_padding.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../application/customer_service.dart';
import '../../data/models/address_model.dart';
import '../widgets/address_card.dart';
import 'address_form_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  late Future<List<AddressModel>> _future;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _future = context.read<CustomerService>().getMyAddresses();
    });
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddressFormPage()),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _navigateToEditAddress(AddressModel address) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormPage(initialAddress: address),
      ),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _confirmDelete(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Alamat?',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDeep),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus alamat di "${address.fullAddress}"? Tindakan ini tidak dapat dibatalkan.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CustomerService>().deleteAddress(address.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alamat berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadAddresses();
        } else {
          final errorMsg = context.read<CustomerService>().message ?? 'Gagal menghapus alamat';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Saya'),
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadAddresses(),
        color: AppColors.accentWarm,
        child: FutureBuilder<List<AddressModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AppLoadingView());
            }

            final addresses = snapshot.data ?? [];
            if (addresses.isEmpty) {
              return Center(
                child: AppEmptyState(
                  icon: LucideIcons.mapPin,
                  title: 'Belum Ada Alamat Tersimpan',
                  message: 'Tambahkan alamat tempat tinggal atau kantor untuk memudahkan pemesanan dan pengantaran rental.',
                  actionLabel: 'Tambah Alamat Sekarang',
                  onAction: _navigateToAddAddress,
                ),
              );
            }

            return ListView.separated(
              padding: ScrollSafePadding.withFab(
                horizontal: AppSpacing.page,
                top: AppSpacing.page,
              ),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => AppGap.md,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return StaggeredListItem(
                  index: index,
                  child: AddressCard(
                    address: addr,
                    onEdit: () => _navigateToEditAddress(addr),
                    onDelete: () => _confirmDelete(addr),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAddress,
        backgroundColor: AppColors.accentWarm,
        foregroundColor: AppColors.textOnAccent,
        icon: Icon(LucideIcons.plus, size: 20.sp),
        label: const Text('Tambah Alamat'),
      ),
    );
  }
}
