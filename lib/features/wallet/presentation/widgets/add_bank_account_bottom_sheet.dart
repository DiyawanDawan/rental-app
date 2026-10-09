import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../config/shapes.dart';
import '../../../../../config/spacing.dart';
import '../../../../../config/text_styles.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/wallet_service.dart';
import '../../data/models/add_bank_account_input.dart';
import '../../data/models/supported_bank_model.dart';

class AddBankAccountBottomSheet extends StatefulWidget {
  const AddBankAccountBottomSheet({super.key});

  @override
  State<AddBankAccountBottomSheet> createState() => _AddBankAccountBottomSheetState();
}

class _AddBankAccountBottomSheetState extends State<AddBankAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  List<SupportedBankModel> _banks = [];
  SupportedBankModel? _selectedBank;
  bool _isMain = false;
  bool _isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanks();
    });
  }

  Future<void> _loadBanks() async {
    final service = context.read<WalletService>();
    final banks = await service.getSupportedBanks();
    if (mounted) {
      setState(() {
        _banks = banks;
        _isLoadingBanks = false;
      });
      // Set to main by default if user has no accounts yet
      if (service.bankAccounts.isEmpty) {
        setState(() {
          _isMain = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) {
      SnackbarUtils.showError(context, 'Pilih bank terlebih dahulu');
      return;
    }

    final service = context.read<WalletService>();
    final input = AddBankAccountInput(
      bankId: _selectedBank!.id,
      accountNumber: _accountNumberController.text,
      accountName: _accountNameController.text,
      isMain: _isMain,
    );

    final success = await service.addBankAccount(input);
    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Rekening berhasil ditambahkan');
      Navigator.pop(context, true);
    } else {
      if (service.bankErrorMessage != null) {
        SnackbarUtils.showError(context, service.bankErrorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<WalletService>().isBankActionLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.page,
        right: AppSpacing.page,
        top: AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tambah Rekening', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            AppGap.md,
            if (_isLoadingBanks)
              const Center(child: AppLoadingView())
            else
              DropdownButtonFormField<SupportedBankModel>(
                initialValue: _selectedBank,
                decoration: const InputDecoration(
                  labelText: 'Pilih Bank',
                  border: OutlineInputBorder(),
                ),
                items: _banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Row(
                      children: [
                        if (bank.logoUrl != null) ...[
                          Image.network(
                            bank.logoUrl!,
                            width: 24.w,
                            height: 24.h,
                            errorBuilder: (_, __, ___) => Icon(LucideIcons.landmark, size: 20.sp),
                          ),
                          AppGap.sm,
                        ],
                        Text(bank.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBank = val;
                  });
                },
                validator: (val) => val == null ? 'Pilih bank' : null,
              ),
            AppGap.md,
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) {
                if (val == null || val.isEmpty) return 'Nomor rekening wajib diisi';
                if (val.length < 5) return 'Nomor rekening minimal 5 digit';
                if (val.length > 30) return 'Nomor rekening maksimal 30 digit';
                return null;
              },
            ),
            AppGap.md,
            TextFormField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pemilik Rekening',
                border: OutlineInputBorder(),
                helperText: 'Sesuai dengan buku tabungan / m-banking',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Nama pemilik wajib diisi';
                if (val.length < 2) return 'Nama pemilik minimal 2 karakter';
                if (val.length > 100) return 'Nama pemilik maksimal 100 karakter';
                return null;
              },
            ),
            AppGap.md,
            SwitchListTile(
              title: const Text('Jadikan Rekening Utama'),
              subtitle: const Text('Rekening utama digunakan sebagai default pencairan'),
              value: _isMain,
              onChanged: context.read<WalletService>().bankAccounts.isEmpty
                  ? null // Disabled if it's the first account (always true)
                  : (val) => setState(() => _isMain = val),
              contentPadding: EdgeInsets.zero,
            ),
            AppGap.lg,
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.buttonRadius)),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Rekening'),
            ),
            AppGap.xl,
          ],
        ),
      ),
    );
  }
}
