import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/decorations.dart';
import '../../../../core/widgets/cards/balance_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/lists/transaction_tile.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../application/wallet_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final ScrollController _scrollController = ScrollController();
  String _filter = 'all'; // all, in, out

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletService>().loadWalletData();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<WalletService>().loadMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dompet Saya')),
      body: Consumer<WalletService>(
        builder: (context, service, child) {
          if (service.status == WalletStatus.loading && service.transactions.isEmpty) {
            return const AppLoadingView();
          }

          final filteredTransactions = service.transactions.where((t) {
            if (_filter == 'in') return t.isCredit;
            if (_filter == 'out') return !t.isCredit;
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => service.loadWalletData(),
            child: ListView(
              controller: _scrollController,
              padding: AppPadding.screen,
              children: [
                BalanceCard(
                  title: 'Saldo Aktif',
                  balance: service.balance,
                  actions: [
                    BalanceCardAction(
                      icon: LucideIcons.circlePlus,
                      label: 'Top Up',
                      onTap: () => context.push('/wallet/topup'),
                    ),
                    BalanceCardAction(
                      icon: LucideIcons.landmark,
                      // H2 FIX: Customer cannot withdraw funds — only Mitra can.
                      // Button previously labeled 'Tarik Dana' was misleading.
                      label: 'Rekening',
                      onTap: () => context.push('/wallet/banks'),
                    ),
                  ],
                ),
                AppGap.md,
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: AppDecorations.floatingCard(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pemasukan', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                            AppGap.xs,
                            Text('+${MoneyFormatter.rupiah(service.totalEarned)}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.success)),
                          ],
                        ),
                      ),
                    ),
                    AppGap.h(AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: AppDecorations.floatingCard(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pengeluaran', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                            AppGap.xs,
                            Text('-${MoneyFormatter.rupiah(service.totalWithdrawn)}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.critical)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                AppGap.v(AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Riwayat Transaksi', style: AppTextStyles.titleMedium),
                    TextButton(
                      onPressed: () => context.push('/payments/history'),
                      child: const Text('Pembayaran'),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _filter == 'all',
                        onSelected: (_) => setState(() => _filter = 'all'),
                      ),
                      AppGap.h(AppSpacing.sm),
                      FilterChip(
                        label: const Text('Masuk (+)'),
                        selected: _filter == 'in',
                        onSelected: (_) => setState(() => _filter = 'in'),
                      ),
                      AppGap.h(AppSpacing.sm),
                      FilterChip(
                        label: const Text('Keluar (-)'),
                        selected: _filter == 'out',
                        onSelected: (_) => setState(() => _filter = 'out'),
                      ),
                    ],
                  ),
                ),
                AppGap.md,
                if (filteredTransactions.isEmpty)
                  const AppEmptyState(
                    icon: LucideIcons.receipt,
                    title: 'Belum ada transaksi',
                    message: 'Riwayat top up dan penarikan akan muncul di sini.',
                  )
                else
                  ...filteredTransactions.map(
                    (t) => TransactionTile(
                      title: t.description,
                      subtitle: t.createdAt,
                      amount: t.amount,
                      direction: t.isCredit ? TransactionDirection.credit : TransactionDirection.debit,
                      categoryLabel: t.category,
                    ),
                  ),
                if (service.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
