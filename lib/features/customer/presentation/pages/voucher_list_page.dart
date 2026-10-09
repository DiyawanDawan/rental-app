import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/breakpoints.dart';
import '../../../../config/color.dart';
import '../../../../config/motion.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/cards/voucher_ticket_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../application/customer_service.dart';
import '../../data/models/voucher_model.dart';

/// Halaman daftar voucher milik / tersedia untuk customer.
class VoucherListPage extends StatefulWidget {
  const VoucherListPage({super.key});

  @override
  State<VoucherListPage> createState() => _VoucherListPageState();
}

class _VoucherListPageState extends State<VoucherListPage> {
  List<VoucherModel> _vouchers = [];
  bool _loading = true;
  _VoucherFilter _filter = _VoucherFilter.all;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVouchers();
      if (mounted) setState(() => _revealed = true);
    });
  }

  Future<void> _loadVouchers() async {
    setState(() => _loading = true);
    final data = await context.read<CustomerService>().getAvailableVouchers();
    if (!mounted) return;
    setState(() {
      _vouchers = data;
      _loading = false;
    });
  }

  List<VoucherModel> get _filteredVouchers {
    return _vouchers.where((voucher) {
      final status = _resolveStatus(voucher);
      return switch (_filter) {
        _VoucherFilter.all => true,
        _VoucherFilter.available => status == VoucherTicketStatus.available,
        _VoucherFilter.expired => status == VoucherTicketStatus.expired,
      };
    }).toList();
  }

  VoucherTicketStatus _resolveStatus(VoucherModel voucher) {
    if (voucher.isExpired) return VoucherTicketStatus.expired;
    return VoucherTicketStatus.available;
  }

  String _discountLabel(VoucherModel voucher) {
    if (voucher.isPercentage) {
      return 'Diskon\n${voucher.discountAmount.toInt()}%';
    }
    return 'Hemat\n${MoneyFormatter.rupiah(voucher.discountAmount)}';
  }

  String _formatExpiry(String? raw) {
    if (raw == null || raw.isEmpty) return 'Tanpa batas';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      return '$d/$m/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String? _subtitle(VoucherModel voucher) {
    final parts = <String>[];
    if (voucher.description != null && voucher.description!.trim().isNotEmpty) {
      parts.add(voucher.description!.trim());
    }
    if (voucher.minPurchase != null && voucher.minPurchase! > 0) {
      parts.add('Min. belanja ${MoneyFormatter.rupiah(voucher.minPurchase)}');
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Saya'),
        centerTitle: false,
      ),
      body: AnimatedOpacity(
        opacity: _revealed ? 1 : 0,
        duration: AppMotion.medium,
        curve: AppMotion.enter,
        child: AnimatedSlide(
          offset: _revealed ? Offset.zero : AppMotion.pageSlideUpBegin,
          duration: AppMotion.medium,
          curve: AppMotion.enter,
          child: _loading
              ? const AppLoadingView()
              : RefreshIndicator(
                  onRefresh: _loadVouchers,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _PromoHeroBanner(count: _vouchers.length)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.section,
                            AppSpacing.page,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'Filter Voucher',
                            style: context.textTitleMedium,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _FilterChips(
                        selected: _filter,
                        onChanged: (value) => setState(() => _filter = value),
                      )),
                      if (_filteredVouchers.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState(
                            icon: LucideIcons.ticket,
                            title: 'Belum ada voucher',
                            message: _filter == _VoucherFilter.all
                                ? 'Voucher promo akan muncul di sini setelah tersedia untuk akun Anda.'
                                : 'Tidak ada voucher pada kategori filter ini.',
                            actionLabel: 'Muat Ulang',
                            onAction: _loadVouchers,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.md,
                            AppSpacing.page,
                            AppSpacing.xxl,
                          ),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              final columns =
                                  constraints.crossAxisExtent >= AppBreakpoints.mobile ? 2 : 1;
                              return _VoucherSliverList(
                                vouchers: _filteredVouchers,
                                columns: columns,
                                discountLabel: _discountLabel,
                                formatExpiry: _formatExpiry,
                                subtitle: _subtitle,
                                resolveStatus: _resolveStatus,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

enum _VoucherFilter { all, available, expired }

class _PromoHeroBanner extends StatelessWidget {
  const _PromoHeroBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.pageTop,
        AppSpacing.page,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.promoHeroGradient,
          borderRadius: AppShapes.lg,
          boxShadow: [
            BoxShadow(
              color: AppColors.promoGlow.withValues(alpha: 0.22),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hemat Lebih Banyak',
                    style: context.textTitleLarge.copyWith(
                      color: AppColors.promoOnGradient,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppGap.xs,
                  Text(
                    '$count voucher siap Anda gunakan saat checkout.',
                    style: context.textBodyMedium.copyWith(
                      color: AppColors.promoOnGradient.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.sparkles,
              color: AppColors.promoOnGradient.withValues(alpha: 0.9),
              size: 36.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
  });

  final _VoucherFilter selected;
  final ValueChanged<_VoucherFilter> onChanged;

  static const _labels = {
    _VoucherFilter.all: 'Semua',
    _VoucherFilter.available: 'Siap Pakai',
    _VoucherFilter.expired: 'Hangus',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        children: _labels.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => onChanged(entry.key),
              showCheckmark: false,
              selectedColor: AppColors.promoContainer,
              labelStyle: context.textBodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.promoDeep : context.cs.onSurfaceVariant,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.promoPrimary.withValues(alpha: 0.45)
                    : context.cs.outline.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.pill),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VoucherSliverList extends StatelessWidget {
  const _VoucherSliverList({
    required this.vouchers,
    required this.columns,
    required this.discountLabel,
    required this.formatExpiry,
    required this.subtitle,
    required this.resolveStatus,
  });

  final List<VoucherModel> vouchers;
  final int columns;
  final String Function(VoucherModel) discountLabel;
  final String Function(String?) formatExpiry;
  final String? Function(VoucherModel) subtitle;
  final VoucherTicketStatus Function(VoucherModel) resolveStatus;

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return SliverList.separated(
        itemCount: vouchers.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.listGap),
        itemBuilder: (context, index) => StaggeredListItem(
          index: index,
          child: _VoucherTicketItem(
            voucher: vouchers[index],
            discountLabel: discountLabel(vouchers[index]),
            expiry: formatExpiry(vouchers[index].expiryDate),
            subtitle: subtitle(vouchers[index]),
            status: resolveStatus(vouchers[index]),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.listGap,
        crossAxisSpacing: AppSpacing.listGap,
        childAspectRatio: 1.45,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => StaggeredListItem(
          index: index,
          child: _VoucherTicketItem(
            voucher: vouchers[index],
            discountLabel: discountLabel(vouchers[index]),
            expiry: formatExpiry(vouchers[index].expiryDate),
            subtitle: subtitle(vouchers[index]),
            status: resolveStatus(vouchers[index]),
          ),
        ),
        childCount: vouchers.length,
      ),
    );
  }
}

class _VoucherTicketItem extends StatelessWidget {
  const _VoucherTicketItem({
    required this.voucher,
    required this.discountLabel,
    required this.expiry,
    required this.subtitle,
    required this.status,
  });

  final VoucherModel voucher;
  final String discountLabel;
  final String expiry;
  final String? subtitle;
  final VoucherTicketStatus status;

  @override
  Widget build(BuildContext context) {
    return VoucherTicketCard(
      title: voucher.displayTitle,
      voucherCode: voucher.code,
      expiryDate: expiry,
      status: status,
      discountLabel: discountLabel,
      subtitle: subtitle,
      onCopy: () => SnackbarUtils.showSuccess(context, 'Kode voucher disalin'),
    );
  }
}
