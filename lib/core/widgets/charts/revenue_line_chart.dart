import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../config/shapes.dart';

/// Monthly revenue line chart shared by mitra dashboard and admin reports.
class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({
    required this.data,
    this.lineColor = AppColors.orange,
    this.height = 200,
    this.showBorder = false,
    this.emptyMessage = 'Belum ada data pendapatan',
    super.key,
  });

  final List<dynamic> data;
  final Color lineColor;
  final double height;
  final bool showBorder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height.h,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: AppShapes.md,
        ),
        child: Center(child: Text(emptyMessage, style: AppTextStyles.bodySmall)),
      );
    }

    final chart = LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
          show: showBorder,
          border: showBorder ? Border.all(color: AppColors.borderColor) : Border(),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              final val = (e.value['revenue'] as num?)?.toDouble() ?? 0.0;
              return FlSpot(e.key.toDouble(), val);
            }).toList(),
            isCurved: true,
            color: lineColor,
            barWidth: showBorder ? 4 : 3,
            isStrokeCapRound: !showBorder,
            dotData: FlDotData(show: showBorder),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );

    if (showBorder) {
      return SizedBox(height: height.h, child: chart);
    }

    return Container(
      height: height.h,
      padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.md,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: chart,
    );
  }
}
