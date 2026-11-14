import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ChartBar {
  const ChartBar({
    required this.label,
    required this.value,
    this.color = AppColors.cyan,
  });

  final String label;
  final double value;
  final Color color;
}

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    super.key,
    required this.bars,
    this.height = 200,
    this.baseline,
  });

  final List<ChartBar> bars;
  final double height;
  final double? baseline;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return SizedBox(height: height, child: const Center(child: Text('No data')));
    }
    final maxY = bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final top = (baseline != null && baseline! > maxY ? baseline! : maxY) + 8;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0),
                    style: AppTextStyles.caption.copyWith(fontSize: 9)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, m) {
                  final i = v.round();
                  if (i < 0 || i >= bars.length) return const SizedBox.shrink();
                  return Text(bars[i].label,
                      style: AppTextStyles.caption.copyWith(fontSize: 9));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: baseline == null
                ? []
                : [
                    HorizontalLine(
                      y: baseline!,
                      color: AppColors.green.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ],
          ),
          barGroups: bars.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: e.value.color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
