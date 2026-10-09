import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../core/widgets/layout/scroll_safe_padding.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/customer_service.dart';
import '../../data/models/voucher_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoucherSelector extends StatefulWidget {
  const VoucherSelector({
    required this.vouchers,
    this.selectedVoucher,
    required this.onSelected,
    this.orderAmount,
    this.rentalType,
    super.key,
  });

  final List<VoucherModel> vouchers;
  final VoucherModel? selectedVoucher;
  final ValueChanged<VoucherModel?> onSelected;
  final double? orderAmount;
  final String? rentalType;

  @override
  State<VoucherSelector> createState() => _VoucherSelectorState();
}

class _VoucherSelectorState extends State<VoucherSelector> {
  final _codeController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateAndApply() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidating = true);
    final voucher = await context.read<CustomerService>().validateVoucher(
      code: code,
      amount: widget.orderAmount ?? 100000,
      rentalType: widget.rentalType,
    );
    if (!mounted) return;
    setState(() => _isValidating = false);

    if (voucher != null) {
      widget.onSelected(voucher);
      Navigator.pop(context);
    } else {
      final msg = context.read<CustomerService>().message ??
          'Voucher tidak valid atau tidak memenuhi syarat minimum';
      SnackbarUtils.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: ScrollSafePadding.sheetPadding(context),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.sheetTop,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pilih Voucher', style: AppTextStyles.titleLarge),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            AppGap.sm,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Punya kode promo? Masukkan di sini',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.lightGray),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _isValidating ? null : _validateAndApply,
                    child: _isValidating
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.onDark),
                          )
                        : const Text('Gunakan'),
                  ),
                ],
              ),
            ),
            AppGap.md,
            if (widget.vouchers.isEmpty)
              Padding(
                padding: EdgeInsets.all(AppSpacing.xxl + AppSpacing.lg),
                child: const Center(child: Text('Tidak ada voucher publik tersedia saat ini.')),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: AppPadding.screen,
                  itemCount: widget.vouchers.length,
                  separatorBuilder: (_, __) => AppGap.md,
                  itemBuilder: (context, index) {
                    final voucher = widget.vouchers[index];
                    final isSelected = widget.selectedVoucher?.id == voucher.id;

                    return InkWell(
                      onTap: () {
                        widget.onSelected(isSelected ? null : voucher);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: AppPadding.list,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.orange.withValues(alpha: 0.05) : AppColors.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.orange : AppColors.lightGray,
                          ),
                          borderRadius: AppShapes.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.ticket, color: AppColors.orange),
                            ),
                            AppGap.h(AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(voucher.name ?? voucher.code, style: AppTextStyles.titleSmall),
                                  Text(
                                    voucher.description ?? 'Diskon menarik untuk Anda',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  AppGap.xs,
                                  Text(
                                    voucher.discountType == 'PERCENTAGE'
                                        ? 'Diskon ${voucher.discountAmount.toInt()}%'
                                        : 'Potongan ${MoneyFormatter.rupiah(voucher.discountAmount)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(LucideIcons.circleCheck, color: AppColors.orange),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
