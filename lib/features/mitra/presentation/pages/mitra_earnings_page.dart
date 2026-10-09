import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/cards/balance_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/lists/transaction_tile.dart';
import '../../../wallet/application/wallet_service.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../wallet/presentation/widgets/add_bank_account_bottom_sheet.dart';
import '../../application/mitra_service.dart';

class MitraEarningsPage extends StatefulWidget {
  const MitraEarningsPage({super.key});

  @override
  State<MitraEarningsPage> createState() => _MitraEarningsPageState();
}

class _MitraEarningsPageState extends State<MitraEarningsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadEarnings();
      context.read<MitraService>().loadEarningsHistory();
      context.read<WalletService>().loadBankAccounts();
    });
  }

  Future<void> _openAddBankSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const AddBankAccountBottomSheet(),
      ),
    );
    if (added == true && mounted) {
      // Reload bank accounts so dialog can reflect the new account
      await context.read<WalletService>().loadBankAccounts();
    }
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();

    // Pre-select the primary account if available
    final walletService = context.read<WalletService>();
    final initialAccounts = walletService.bankAccounts;
    String? selectedBankId = initialAccounts
        .cast<BankAccountModel?>()
        .firstWhere((b) => b?.isMain == true, orElse: () => null)
        ?.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final ws = context.watch<WalletService>();
          final mitraService = context.read<MitraService>();
          final bankAccounts = ws.bankAccounts;

          // Keep selectedBankId valid when accounts list changes
          if (selectedBankId != null && bankAccounts.every((b) => b.id != selectedBankId)) {
            selectedBankId = null;
          }

          return AlertDialog(
            title: const Text('Tarik Saldo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Penarikan',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                AppGap.lg,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Rekening Tujuan', style: AppTextStyles.labelSmall),
                ),
                AppGap.sm,
                if (bankAccounts.isEmpty)
                  TextButton.icon(
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Tambah Rekening Baru'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _openAddBankSheet();
                      if (mounted) _showWithdrawDialog();
                    },
                  )
                else
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedBankId,
                        isExpanded: true,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: bankAccounts.map((b) {
                          return DropdownMenuItem(
                            value: b.id,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${b.bankName}  ${b.accountNumber}',
                                        style: AppTextStyles.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'a.n. ${b.accountName}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                         color: AppColors.textTertiary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (b.isMain) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.teal.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Utama',
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.teal),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setDialogState(() => selectedBankId = val),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(LucideIcons.plus, size: 14),
                          label: const Text('Tambah Rekening'),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _openAddBankSheet();
                            if (mounted) _showWithdrawDialog();
                          },
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isEmpty || selectedBankId == null) return;

                  // C2 FIX: Strip Indonesian thousand separator (.) before parsing.
                  // Without this, typing "50.000" → double.tryParse → 50.0 → Rp 50 payout!
                  final rawText = amountController.text
                      .replaceAll('.', '')   // remove thousand sep
                      .replaceAll(',', '.'); // normalize decimal sep
                  final amount = double.tryParse(rawText) ?? 0;

                  if (amount <= 0) {
                    SnackbarUtils.showError(context, 'Masukkan jumlah penarikan yang valid');
                    return;
                  }
                  if (amount < 10000) {
                    SnackbarUtils.showError(context, 'Minimum penarikan Rp 10.000');
                    return;
                  }

                  final success = await mitraService.requestPayout(amount, selectedBankId!);
                  if (!mounted) return;
                  // H4 FIX: Always show feedback — success or error.
                  if (success) {
                    if (context.mounted) SnackbarUtils.showSuccess(context, 'Permintaan penarikan berhasil dikirim');
                    if (context.mounted) Navigator.pop(context);
                    mitraService.loadEarnings();
                  } else if (context.mounted) {
                    SnackbarUtils.showError(
                      context,
                      mitraService.message ?? 'Gagal memproses penarikan, coba lagi',
                    );
                  }
                },
                child: const Text('Tarik Dana'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendapatan Saya')),
      body: Consumer<MitraService>(
        builder: (context, service, child) {
          if (service.status == MitraStatus.loading && service.earnings == null) {
            return const AppLoadingView();
          }

          final earnings = service.earnings;
          final balance = (earnings?['balance'] as num?)?.toDouble() ?? 0.0;
          final totalEarnings = (earnings?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          final transactions = (earnings?['transactions'] as List?) ?? [];

          return RefreshIndicator(
            onRefresh: () => service.loadEarnings(),
            child: ListView(
              padding: AppPadding.screen,
              children: [
                BalanceCard(
                  title: 'Saldo Siap Tarik',
                  balance: balance,
                  style: BalanceCardStyle.tealGradient,
                  footer: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Pendapatan', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onDarkMuted)),
                            Text(
                              MoneyFormatter.rupiah(totalEarnings),
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      AppGap.h(AppSpacing.md),
                      ElevatedButton(
                        onPressed: _showWithdrawDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.teal,
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.section),
                        ),
                        child: const Text('Withdraw'),
                      ),
                    ],
                  ),
                ),
                AppGap.v(AppSpacing.xxl),
                Text('Riwayat Pendapatan', style: AppTextStyles.titleMedium),
                AppGap.md,
                if (transactions.isEmpty)
                  const AppEmptyState(
                    icon: LucideIcons.receipt,
                    title: 'Belum ada riwayat transaksi',
                    message: 'Pendapatan dan penarikan akan tercatat di sini.',
                  )
                else
                  ...transactions.map((t) {
                    final type = t['type']?.toString() ?? '';
                    final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                    return TransactionTile.earning(
                      title: t['description'] ?? 'Transaksi',
                      subtitle: t['createdAt'] ?? '',
                      amount: amount,
                      isPayout: type == 'PAYOUT',
                    );
                  }),
                AppGap.v(AppSpacing.xxl),
                Text('Riwayat Transaksi Unit', style: AppTextStyles.titleMedium),
                AppGap.md,
                if ((service.earningsHistory ?? []).isEmpty)
                  const AppEmptyState(
                    icon: LucideIcons.car,
                    title: 'Belum ada transaksi unit',
                    message: 'Booking yang sudah selesai akan tercatat di sini.',
                  )
                else
                  ...((service.earningsHistory)!.map((b) {
                    final vehicle = b['vehicle'] as Map<String, dynamic>?;
                    final title = vehicle != null
                        ? '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'.trim()
                        : 'Unit';
                    final net = (b['netAmount'] as num?)?.toDouble() ?? 0.0;
                    final date = b['createdAt']?.toString() ?? '';
                    return TransactionTile.earning(
                      title: title,
                      subtitle: date,
                      amount: net,
                      isPayout: false,
                    );
                  })),
              ],
            ),
          );
        },
      ),
    );
  }
}
