import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../../data/models/time_series_point.dart'
    show TimeSeriesPoint, ChartAnnotation;
import '../../theme/app_text_styles.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.points,
    this.secondaryPoints,
    this.unit,
    this.baselineMin,
    this.baselineMax,
    this.annotations = const [],
    this.showPoints = false,
    this.showBaselineBand = true,
    this.height = 220,
    this.primaryColor = AppColors.cyan,
    this.secondaryColor = AppColors.purple,
  });

  final List<TimeSeriesPoint> points;
  final List<TimeSeriesPoint>? secondaryPoints;
  final String? unit;
  final double? baselineMin;
  final double? baselineMax;
  final List<ChartAnnotation> annotations;
  final bool showPoints;
  final bool showBaselineBand;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data')),
      );
    }

    final minY = _minY();
    final maxY = _maxY();

    final primarySpots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();
    final secondarySpots =
        (secondaryPoints ??
                points.where((p) => p.secondaryValue != null).toList())
            .asMap()
            .entries
            .map((e) {
              final v = secondaryPoints != null
                  ? e.value.value
                  : (points[e.key].secondaryValue ?? 0);
              return FlSpot(e.key.toDouble(), v);
            })
            .toList();

    final hasSecondary =
        secondaryPoints != null || points.any((p) => p.secondaryValue != null);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _interval(minY, maxY),
            getDrawingHorizontalLine: (value) =>
                FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _bottomInterval(points.length),
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _shortDate(points[i].date),
                    style: AppTextStyles.caption.copyWith(fontSize: 9),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (showBaselineBand && baselineMin != null)
                HorizontalLine(
                  y: baselineMin!,
                  color: AppColors.green.withValues(alpha: 0.4),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              if (showBaselineBand && baselineMax != null)
                HorizontalLine(
                  y: baselineMax!,
                  color: AppColors.green.withValues(alpha: 0.4),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
            ],
            verticalLines: annotations
                .map(
                  (a) => VerticalLine(
                    x: _annotationX(a).toDouble(),
                    color: _annotationColor(a.colorHint),
                    strokeWidth: 1,
                    dashArray: [3, 3],
                    label: VerticalLineLabel(
                      show: true,
                      alignment: Alignment.topCenter,
                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                      labelResolver: (_) => a.label,
                    ),
                  ),
                )
                .toList(),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final i = spot.x.round();
                  final date = i >= 0 && i < points.length
                      ? _shortDate(points[i].date)
                      : '';
                  return LineTooltipItem(
                    '$date  ${spot.y.toStringAsFixed(1)}${unit == null ? '' : ' $unit'}',
                    AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: primarySpots,
              isCurved: true,
              color: primaryColor,
              barWidth: 2.5,
              dotData: FlDotData(show: showPoints),
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withValues(alpha: 0.08),
              ),
            ),
            if (hasSecondary)
              LineChartBarData(
                spots: secondarySpots,
                isCurved: true,
                color: secondaryColor,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }

  double _minY() {
    final vals = points.map((p) => p.value).toList();
    if (points.any((p) => p.secondaryValue != null)) {
      vals.addAll(points.map((p) => p.secondaryValue!).where((v) => v > 0));
    }
    if (secondaryPoints != null) {
      vals.addAll(secondaryPoints!.map((p) => p.value));
    }
    final base = vals.reduce((a, b) => a < b ? a : b);
    final bMin = baselineMin ?? base;
    return (base < bMin ? base : bMin) - 4;
  }

  double _maxY() {
    final vals = points.map((p) => p.value).toList();
    if (points.any((p) => p.secondaryValue != null)) {
      vals.addAll(points.map((p) => p.secondaryValue!).where((v) => v > 0));
    }
    if (secondaryPoints != null) {
      vals.addAll(secondaryPoints!.map((p) => p.value));
    }
    final base = vals.reduce((a, b) => a > b ? a : b);
    final bMax = baselineMax ?? base;
    return (base > bMax ? base : bMax) + 4;
  }

  double _interval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 10) return 2;
    if (range <= 30) return 5;
    return 10;
  }

  double _bottomInterval(int len) {
    if (len <= 7) return 1;
    if (len <= 30) return 5;
    return 15;
  }

  double _annotationX(ChartAnnotation a) {
    final idx = points.indexWhere(
      (p) =>
          p.date.year == a.date.year &&
          p.date.month == a.date.month &&
          p.date.day == a.date.day,
    );
    if (idx >= 0) return idx.toDouble();
    // nearest
    return points.length.toDouble() - 1;
  }

  Color _annotationColor(String? hint) {
    return switch (hint) {
      'purple' => AppColors.purple,
      'orange' => AppColors.orange,
      'red' => AppColors.red,
      _ => AppColors.textMuted,
    };
  }

  String _shortDate(DateTime d) => '${d.month}/${d.day}';
}
