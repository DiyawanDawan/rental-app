import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/customer_service.dart';

class LoyaltyHistoryPage extends StatefulWidget {
  const LoyaltyHistoryPage({super.key});

  @override
  State<LoyaltyHistoryPage> createState() => _LoyaltyHistoryPageState();
}

class _LoyaltyHistoryPageState extends State<LoyaltyHistoryPage> {
  Future<List<Map<String, dynamic>>>? _future;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = context.read<CustomerService>();
    _balance = await service.getLoyaltyBalance();
    _future = service.getLoyaltyHistory();
    if (mounted) setState(() {});
  }

  Future<void> _showApplyReferralDialog() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terapkan kode referral'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          maxLength: 20,
          decoration: const InputDecoration(
            labelText: 'Kode referral',
            hintText: 'Contoh: TRVABC123',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (code == null || code.trim().length < 4 || !mounted) return;
    final success = await context.read<CustomerService>().applyReferralCode(
      code,
    );
    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Kode referral berhasil diterapkan');
    } else {
      SnackbarUtils.showError(
        context,
        'Kode referral tidak valid atau sudah digunakan',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poin Loyalitas'),
        actions: [
          IconButton(
            onPressed: _showApplyReferralDialog,
            icon: const Icon(LucideIcons.userPlus),
            tooltip: 'Terapkan kode referral',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(AppSpacing.page),
            padding: AppPadding.screen,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: AppShapes.md,
            ),
            child: Column(
              children: [
                Text('Saldo Poin', style: AppTextStyles.bodySmall),
                AppGap.xs,
                Text(
                  '$_balance',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingView();
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.gift,
                    title: 'Belum ada riwayat',
                    message: 'Poin akan muncul setelah transaksi selesai.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(height: 1.h),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final points = (item['amount'] as num?)?.toInt() ?? 0;
                      final isCredit = points >= 0;
                      return ListTile(
                        leading: Icon(
                          isCredit
                              ? LucideIcons.arrowUpRight
                              : LucideIcons.arrowDownRight,
                          color: isCredit
                              ? AppColors.success
                              : AppColors.critical,
                        ),
                        title: Text(
                          item['description']?.toString() ?? 'Transaksi poin',
                        ),
                        subtitle: Text(item['createdAt']?.toString() ?? ''),
                        trailing: Text(
                          '${isCredit ? '+' : ''}$points',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isCredit
                                ? AppColors.success
                                : AppColors.critical,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
