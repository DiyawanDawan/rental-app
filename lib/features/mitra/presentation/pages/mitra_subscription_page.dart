import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';

String _formatShortDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class MitraSubscriptionPage extends StatefulWidget {
  const MitraSubscriptionPage({super.key});

  @override
  State<MitraSubscriptionPage> createState() => _MitraSubscriptionPageState();
}

class _MitraSubscriptionPageState extends State<MitraSubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadSubscription();
    });
  }

  Future<void> _upgrade() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upgrade Mitra PRO'),
        content: const Text(
          'Biaya upgrade akan dipotong dari saldo wallet mitra. Paket aktif 30 hari.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Upgrade')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await context.read<MitraService>().upgradeSubscription();
    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'Selamat! Anda sekarang Mitra PRO');
    } else {
      SnackbarUtils.showError(context, context.read<MitraService>().message ?? 'Upgrade gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Langganan Mitra')),
      body: Consumer<MitraService>(
        builder: (context, service, _) {
          final sub = service.subscription;
          if (service.status == MitraStatus.loading && sub == null) {
            return const AppLoadingView();
          }
          if (sub == null) {
            return Center(child: Text(service.message ?? 'Gagal memuat langganan'));
          }

          return RefreshIndicator(
            onRefresh: service.loadSubscription,
            child: ListView(
              padding: AppPadding.list,
              children: [
                _TierBadge(isPro: sub.isPro),
                AppGap.lg,
                Card(
                  child: Padding(
                    padding: AppPadding.list,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paket saat ini', style: AppTextStyles.titleMedium),
                        AppGap.sm,
                        Text(
                          sub.isPro ? 'Mitra PRO' : 'Mitra FREE',
                          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.teal),
                        ),
                        if (sub.expiresAt != null) ...[
                          AppGap.xs,
                          Text(
                            'Berlaku hingga ${_formatShortDate(sub.expiresAt!)}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                        AppGap.md,
                        Text(
                          'Armada: ${sub.vehicleCount} / ${sub.maxVehicles} unit',
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                AppGap.lg,
                Text('Fitur PRO', style: AppTextStyles.titleMedium),
                AppGap.sm,
                _FeatureRow(label: 'Find My Motor (HP penyewa)', enabled: sub.findMyMotor),
                _FeatureRow(label: 'GPS IoT tracker hardware', enabled: sub.iotGps),
                _FeatureRow(label: 'Pasang GPS tracker (pair IMEI)', enabled: sub.gpsPairing),
                _FeatureRow(label: 'Geofence & alert zona', enabled: sub.geofence),
                _FeatureRow(label: 'Riwayat lokasi 30 hari', enabled: sub.locationHistory),
                _FeatureRow(label: 'Limit armada hingga 50 unit', enabled: sub.isPro),
                if (!sub.isPro) ...[
                  AppGap.v(AppSpacing.xxl),
                  Card(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    child: Padding(
                      padding: AppPadding.list,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Upgrade ke PRO', style: AppTextStyles.titleMedium),
                          AppGap.sm,
                          Text(
                            '${MoneyFormatter.rupiah(sub.proMonthlyPrice)} / 30 hari',
                            style: AppTextStyles.headlineSmall,
                          ),
                          AppGap.md,
                          FilledButton(
                            onPressed: service.status == MitraStatus.loading ? null : _upgrade,
                            child: const Text('Upgrade Sekarang'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (sub.isPro) ...[
                  AppGap.lg,
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutePaths.mitraTracking),
                    icon: Icon(LucideIcons.mapPin),
                    label: const Text('Buka Find My Motor'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPro
              ? [AppColors.navy, AppColors.teal]
              : [AppColors.lightGray.withValues(alpha: 0.3), AppColors.lightGray.withValues(alpha: 0.1)],
        ),
        borderRadius: AppShapes.md,
      ),
      child: Column(
        children: [
          Icon(isPro ? LucideIcons.crown : LucideIcons.user, size: 40.sp, color: AppColors.onDark),
          AppGap.sm,
          Text(
            isPro ? 'MITRA PRO' : 'MITRA FREE',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.onDark, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            enabled ? LucideIcons.circleCheck : LucideIcons.circleX,
            color: enabled ? AppColors.teal : AppColors.lightGray,
            size: 20.sp,
          ),
          AppGap.h(AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
