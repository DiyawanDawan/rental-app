import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/di.dart';
import '../../../app/env.dart';
import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';
import '../../../core/errors/failure.dart';
import '../data/health_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthCheckPage extends StatefulWidget {
  const HealthCheckPage({super.key});

  @override
  State<HealthCheckPage> createState() => _HealthCheckPageState();
}

class _HealthCheckPageState extends State<HealthCheckPage> {
  late Future<_HealthCheckResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _checkHealth();
  }

  Future<_HealthCheckResult> _checkHealth() async {
    try {
      final response = await getIt<HealthRepository>().check();
      return _HealthCheckResult.success(
        message: response.message,
        data: response.data ?? const {},
      );
    } on Failure catch (failure) {
      return _HealthCheckResult.failure(failure.message);
    } catch (error) {
      return _HealthCheckResult.failure(error.toString());
    }
  }

  void _refresh() {
    setState(() {
      _future = _checkHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return const Scaffold(
        body: Center(child: Text('Halaman tidak tersedia')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Backend Health')),
      body: FutureBuilder<_HealthCheckResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final result = snapshot.data;
          final isSuccess = result?.isSuccess ?? false;

          return ListView(
            padding: AppPadding.list,
            children: [
              _StatusHeader(isSuccess: isSuccess),
              AppGap.lg,
              Text('Base URL', style: AppTextStyles.titleSmall),
              AppGap.xs,
              SelectableText(
                AppEnv.apiBaseUrl,
                style: AppTextStyles.bodyMedium,
              ),
              AppGap.lg,
              Text('Message', style: AppTextStyles.titleSmall),
              AppGap.xs,
              Text(
                result?.message ?? 'Tidak ada response',
                style: AppTextStyles.bodyMedium,
              ),
              if (result != null && result.data.isNotEmpty) ...[
                AppGap.lg,
                Text('Data', style: AppTextStyles.titleSmall),
                AppGap.xs,
                SelectableText(
                  result.data.toString(),
                  style: AppTextStyles.bodySmall,
                ),
              ],
              AppGap.v(AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: Icon(LucideIcons.refreshCw),
                label: Text('Cek ulang'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.isSuccess});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.statusAvailable : AppColors.critical;
    final icon = isSuccess ? LucideIcons.circleCheck : LucideIcons.circleX;
    final title = isSuccess ? 'Backend terhubung' : 'Backend belum terhubung';

    return Container(
      padding: AppPadding.list,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppShapes.sm,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          AppGap.h(AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCheckResult {
  const _HealthCheckResult({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory _HealthCheckResult.success({
    required String message,
    required Map<String, dynamic> data,
  }) {
    return _HealthCheckResult(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory _HealthCheckResult.failure(String message) {
    return _HealthCheckResult(
      isSuccess: false,
      message: message,
      data: const {},
    );
  }

  final bool isSuccess;
  final String message;
  final Map<String, dynamic> data;
}
