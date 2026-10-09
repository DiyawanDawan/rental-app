import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/customer_service.dart';
import '../../data/models/customer_payment_model.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late Future<List<CustomerPaymentModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerService>().getMyPayments();
  }

  void _refresh() {
    setState(() {
      _future = context.read<CustomerService>().getMyPayments();
    });
  }

  Color _statusColor(CustomerPaymentModel payment) {
    if (payment.isSuccess) return AppColors.success;
    if (payment.isFailed) return AppColors.error;
    return AppColors.warning;
  }

  IconData _statusIcon(CustomerPaymentModel payment) {
    if (payment.isSuccess) return LucideIcons.circleCheck;
    if (payment.isFailed) return LucideIcons.circleX;
    return LucideIcons.clock;
  }

  String _statusLabel(CustomerPaymentModel payment) {
    final s = payment.status.toUpperCase();
    if (s == 'SUCCESS' || s == 'PAID' || s == 'SETTLED') return 'Berhasil';
    if (s == 'FAILED') return 'Gagal';
    if (s == 'EXPIRED') return 'Kedaluwarsa';
    return 'Menunggu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembayaran')),
      body: FutureBuilder<List<CustomerPaymentModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final payments = snapshot.data ?? [];
          if (payments.isEmpty) {
            return const AppEmptyState(
              icon: LucideIcons.wallet,
              title: 'Belum ada pembayaran',
              message: 'Riwayat pembayaran booking akan muncul di sini.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: AppPadding.list,
              itemCount: payments.length,
              separatorBuilder: (_, __) => AppGap.sm,
              itemBuilder: (context, index) {
                final payment = payments[index];
                final statusColor = _statusColor(payment);
                return StaggeredListItem(
                  index: index,
                  child: Container(
                    decoration: AppDecorations.floatingCard(),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _statusIcon(payment),
                          color: statusColor,
                          size: 20.r,
                        ),
                      ),
                      title: Text(
                        payment.displayName,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              _statusLabel(payment),
                              style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                            ),
                          ),
                          if (payment.channelCode != null && payment.channelCode!.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                payment.channelCode!,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        MoneyFormatter.rupiah(payment.amount),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: payment.isSuccess ? AppColors.success : AppColors.textPrimary,
                        ),
                      ),
                    ),
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
