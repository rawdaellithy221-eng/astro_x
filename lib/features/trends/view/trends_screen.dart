import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/app_database.dart';
import '../../../core/helper/health_history_helper.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_card.dart';
import '../../../core/widgets/charts/bar_chart_widget.dart';
import '../../../core/widgets/charts/chart_tooltip.dart';
import '../../../core/widgets/charts/line_chart_widget.dart';
import '../../../data/models/health_metric_id.dart';
import '../../../data/models/health_status.dart' show TrendRange;
import '../../../data/models/time_series_point.dart' show ChartLegendItem;
import '../../../data/repositories/health_data_repository.dart';
import '../../../features/user/cubit/user_cubit.dart';
import '../cubit/trends_cubit.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key, this.areaFilter, this.initialMetric});

  final String? areaFilter;
  final HealthMetricId? initialMetric;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final userId = context.read<UserCubit>().state.userId;
    if (userId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cyan),
      );
    }
    return BlocProvider(
      create: (_) => TrendsCubit(
        healthRepository: HealthDataRepository(db),
        userId: userId,
        areaFilter: areaFilter,
        initialMetric: initialMetric,
      ),
      child: const _TrendsView(),
    );
  }
}

class _TrendsView extends StatelessWidget {
  const _TrendsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrendsCubit, TrendsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          );
        }
        final sleepPts = HealthHistoryHelper.pointsFor(
          state.records,
          HealthMetricId.sleep,
        );
        final moodPts = HealthHistoryHelper.pointsFor(
          state.records,
          HealthMetricId.mood,
        );
        final exercisePts = HealthHistoryHelper.pointsFor(
          state.records,
          HealthMetricId.exercise,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trends', style: AppTextStyles.display),
              const SizedBox(height: 4),
              Text(
                'Review saved readings over time alongside general reference bands.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppDimensions.space12),
              if (state.areaFilter != null) ...[
                Row(
                  children: [
                    Chip(
                      label: Text(
                        state.areaFilter!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                      backgroundColor: AppColors.cyanMuted,
                      side: const BorderSide(color: AppColors.borderCyan),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          context.read<TrendsCubit>().clearAreaFilter(),
                      child: Text(
                        'Clear filter',
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TrendRange.values.map((r) {
                  final selected = state.range == r;
                  final label = switch (r) {
                    TrendRange.days7 => '7 days',
                    TrendRange.days30 => '30 days',
                    TrendRange.wholeMission => 'Whole mission',
                  };
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) =>
                        context.read<TrendsCubit>().selectRange(r),
                    selectedColor: AppColors.cyanMuted,
                    backgroundColor: AppColors.surfaceAlt,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: selected
                          ? AppColors.cyan
                          : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.availableMetrics.map((m) {
                  final selected = state.metric == m;
                  return ChoiceChip(
                    label: Text(m.label),
                    selected: selected,
                    onSelected: (_) =>
                        context.read<TrendsCubit>().selectMetric(m),
                    selectedColor: AppColors.cyanMuted,
                    backgroundColor: AppColors.surfaceAlt,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: selected
                          ? AppColors.cyan
                          : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space16),
              if (state.records.isEmpty)
                CommonCard(
                  child: Text(
                    'No saved check-ins are available for this date range. '
                    'Complete a daily check-in or choose a wider range to see trends.',
                    style: AppTextStyles.body,
                  ),
                )
              else ...[
                CommonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.metric.label, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      if (state.points.isNotEmpty &&
                          state.baselineMin != null &&
                          state.baselineMax != null)
                        Text(
                          'Baseline ${state.baselineMin!.toStringAsFixed(1)}–${state.baselineMax!.toStringAsFixed(1)} ${state.metric.unit}',
                          style: AppTextStyles.caption,
                        )
                      else if (state.points.isEmpty)
                        Text(
                          'No saved ${state.metric.label.toLowerCase()} measurements in this date range.',
                          style: AppTextStyles.caption,
                        ),
                      const SizedBox(height: AppDimensions.space12),
                      LineChartWidget(
                        points: state.points,
                        unit: state.metric.unit,
                        baselineMin: state.points.isEmpty
                            ? null
                            : state.baselineMin,
                        baselineMax: state.points.isEmpty
                            ? null
                            : state.baselineMax,
                        showPoints: state.metric == HealthMetricId.oxygen,
                        annotations: state.annotations,
                        height: 260,
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      if (state.points.isNotEmpty)
                        ChartLegend(
                          items: [
                            ChartLegendItem(
                              label:
                                  state.metric == HealthMetricId.bloodPressure
                                  ? 'Systolic'
                                  : state.metric.label,
                              colorValue: AppColors.cyan.toARGB32(),
                            ),
                            if (state.metric == HealthMetricId.bloodPressure)
                              ChartLegendItem(
                                label: 'Diastolic',
                                colorValue: AppColors.purple.toARGB32(),
                              ),
                            if (state.baselineMin != null ||
                                state.baselineMax != null)
                              ChartLegendItem(
                                label: 'Baseline',
                                colorValue: AppColors.green.toARGB32(),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                CommonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What changed', style: AppTextStyles.titleSm),
                      const SizedBox(height: 4),
                      Text(_changeSummary(state), style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth >= 900 ? 3 : 1;
                    final charts = [
                      _SmallChart(
                        title: 'Sleep (h)',
                        child: LineChartWidget(
                          points: sleepPts,
                          unit: HealthMetricId.sleep.unit,
                          baselineMin: sleepPts.isEmpty ? null : 7,
                          baselineMax: sleepPts.isEmpty ? null : 8.5,
                          height: 160,
                          primaryColor: AppColors.purple,
                        ),
                      ),
                      _SmallChart(
                        title: 'Mood (1–5)',
                        child: LineChartWidget(
                          points: moodPts,
                          unit: HealthMetricId.mood.unit,
                          baselineMin: moodPts.isEmpty ? null : 3,
                          baselineMax: moodPts.isEmpty ? null : 5,
                          height: 160,
                          primaryColor: AppColors.purple,
                        ),
                      ),
                      _SmallChart(
                        title: 'Exercise (min)',
                        child: BarChartWidget(
                          bars: exercisePts
                              .map(
                                (p) => ChartBar(
                                  label: '${p.date.day}',
                                  value: p.value,
                                  color: AppColors.green,
                                ),
                              )
                              .toList(),
                          height: 160,
                          baseline: exercisePts.isEmpty ? null : 90,
                        ),
                      ),
                    ];
                    if (cols == 1) {
                      return Column(
                        children: charts
                            .map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: w,
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Row(
                      children: charts
                          .map(
                            (w) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: w,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _changeSummary(TrendsState state) {
    if (state.points.length < 2) {
      return 'Not enough saved readings to describe a change yet.';
    }
    final first = state.points.first.value;
    final last = state.points.last.value;
    final difference = last - first;
    final label = state.metric == HealthMetricId.bloodPressure
        ? 'Systolic blood pressure'
        : state.metric.label;
    if (difference.abs() < 0.05) {
      return '$label is unchanged over the selected range.';
    }
    final direction = difference > 0 ? 'up' : 'down';
    return '$label is $direction ${difference.abs().toStringAsFixed(1)} '
        '${state.metric.unit} over the selected range.';
  }
}

class _SmallChart extends StatelessWidget {
  const _SmallChart({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSm),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
