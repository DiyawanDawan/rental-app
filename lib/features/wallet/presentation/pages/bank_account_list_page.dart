import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/layout/scroll_safe_padding.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../application/wallet_service.dart';
import '../../data/models/wallet_model.dart';
import '../widgets/add_bank_account_bottom_sheet.dart';

class BankAccountListPage extends StatefulWidget {
  const BankAccountListPage({super.key});

  @override
  State<BankAccountListPage> createState() => _BankAccountListPageState();
}

class _BankAccountListPageState extends State<BankAccountListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletService>().loadBankAccounts();
    });
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddBankAccountBottomSheet(),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WalletService service, BankAccountModel bank) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rekening?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus rekening ${bank.bankName} '
          '(${bank.accountNumber}) a.n. ${bank.accountName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final ok = await service.deleteBankAccount(bank.id);
      if (context.mounted) {
        if (ok) {
          SnackbarUtils.showSuccess(context, 'Rekening berhasil dihapus');
        } else {
          SnackbarUtils.showError(
            context,
            service.bankErrorMessage ?? 'Gagal menghapus rekening',
          );
        }
      }
    }
  }

  Widget _buildBankLogo(BankAccountModel bank) {
    if (bank.bankLogoUrl != null && bank.bankLogoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          bank.bankLogoUrl!,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => CircleAvatar(
            backgroundColor: bank.isMain ? AppColors.teal : AppColors.orange,
            child: Icon(LucideIcons.landmark, color: AppColors.onDark, size: 20.sp),
          ),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: bank.isMain ? AppColors.teal : AppColors.orange,
      child: Icon(LucideIcons.landmark, color: AppColors.onDark, size: 20.sp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekening Bank')),
      body: Consumer<WalletService>(
        builder: (context, service, _) {
          if (service.isBankLoading && service.bankAccounts.isEmpty) {
            return const AppLoadingView();
          }

          if (service.bankAccounts.isEmpty) {
            return AppEmptyState(
              icon: LucideIcons.landmark,
              title: 'Belum ada rekening',
              message: 'Tambahkan rekening bank untuk penarikan dana.',
              actionLabel: 'Tambah Rekening',
              onAction: _showAddSheet,
            );
          }

          return ListView.separated(
            padding: ScrollSafePadding.withFab(horizontal: AppSpacing.page, top: AppSpacing.page),
            itemCount: service.bankAccounts.length,
            separatorBuilder: (_, __) => AppGap.md,
            itemBuilder: (context, index) {
              final bank = service.bankAccounts[index];

              return StaggeredListItem(
                index: index,
                child: Container(
                  decoration: AppDecorations.floatingCard(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: ListTile(
                    leading: _buildBankLogo(bank),
                    title: Row(
                      children: [
                        Text(bank.bankName, style: AppTextStyles.titleSmall),
                        if (bank.isMain) ...[
                          AppGap.sm,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Utama',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        '${bank.accountNumber}\na.n. ${bank.accountName}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!bank.isMain)
                          Tooltip(
                            message: 'Jadikan utama',
                            child: IconButton(
                              icon: const Icon(LucideIcons.star, color: AppColors.rating),
                              onPressed: service.isBankActionLoading
                                  ? null
                                  : () async {
                                      final ok = await service.setPrimaryBankAccount(bank.id);
                                      if (context.mounted) {
                                        if (ok) {
                                          SnackbarUtils.showSuccess(
                                            context,
                                            'Rekening utama diperbarui',
                                          );
                                        } else {
                                          SnackbarUtils.showError(
                                            context,
                                            service.bankErrorMessage ?? 'Gagal memperbarui rekening',
                                          );
                                        }
                                      }
                                    },
                            ),
                          ),
                        Tooltip(
                          message: 'Hapus rekening',
                          child: IconButton(
                            icon: const Icon(LucideIcons.trash2, color: AppColors.critical),
                            onPressed: service.isBankActionLoading
                                ? null
                                : () => _confirmDelete(context, service, bank),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Tambah Rekening'),
      ),
    );
  }
}
