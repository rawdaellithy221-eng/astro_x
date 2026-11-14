import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/app_database.dart';
import '../../../core/helper/health_content_helper.dart';
import '../../../core/helper/health_score_calculator.dart';
import '../../../core/helper/health_status_helper.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/charts/health_gauge.dart';
import '../../../core/widgets/common_card.dart';
import '../../../core/widgets/health/health_status_badge.dart';
import '../../../core/widgets/health_metric_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/mock/mock_health_baselines.dart';
import '../../../data/models/alert_item.dart';
import '../../../data/models/body_region.dart';
import '../../../data/models/health_metric_id.dart';
import '../../../data/models/health_reading.dart';
import '../../../data/models/health_status.dart';
import '../../../data/models/today_snapshot.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/repositories/health_data_repository.dart';
import '../../../features/user/cubit/user_cubit.dart';
import '../cubit/dashboard_cubit.dart';

const Map<String, HealthMetricId> regionToMetric = {
  'head': HealthMetricId.oxygen,
  'chest-hr': HealthMetricId.heartRate,
  'chest-bp': HealthMetricId.bloodPressure,
  'abdomen': HealthMetricId.temperature,
};

const Map<HealthMetricId, String> metricToRegion = {
  HealthMetricId.oxygen: 'head',
  HealthMetricId.heartRate: 'chest-hr',
  HealthMetricId.bloodPressure: 'chest-bp',
  HealthMetricId.temperature: 'abdomen',
};

const List<HealthMetricId> _trackedMetrics = [
  HealthMetricId.heartRate,
  HealthMetricId.bloodPressure,
  HealthMetricId.oxygen,
  HealthMetricId.temperature,
  HealthMetricId.sleep,
  HealthMetricId.mood,
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.onNavigateToAlerts,
    this.onOpenTrends,
  });

  final VoidCallback? onNavigateToAlerts;
  final void Function({String? areaFilter, HealthMetricId? metric})?
  onOpenTrends;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().state.userId;
    if (userId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cyan),
      );
    }
    return BlocProvider(
      create: (context) {
        final db = context.read<AppDatabase>();
        return DashboardCubit(
          repository: HealthDataRepository(db),
          alertRepository: const AlertRepository(),
          userId: userId,
        )..load();
      },
      child: _DashboardView(
        onNavigateToAlerts: onNavigateToAlerts,
        onOpenTrends: onOpenTrends,
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({this.onNavigateToAlerts, this.onOpenTrends});
  final VoidCallback? onNavigateToAlerts;
  final void Function({String? areaFilter, HealthMetricId? metric})?
  onOpenTrends;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.loading || state.snapshot == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          );
        }
        final snapshot = state.snapshot!;
        final isBody = state.selectionType == DashboardSelectionType.bodyRegion;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 1100;
                  final left = _YourBodyCard(
                    regions: snapshot.bodyRegions,
                    selectedId: state.selectedId,
                    isBodySelection: isBody,
                    metricStatuses: state.metricStatuses,
                    onSelect: (id) =>
                        context.read<DashboardCubit>().selectBodyRegion(id),
                  );
                  final selectedMetricId = isBody
                      ? regionToMetric[state.selectedId]?.name
                      : state.selectedId;
                  final center = _HealthOverview(
                    snapshot: snapshot,
                    selectedMetricId: selectedMetricId,
                    metricStatuses: state.metricStatuses,
                    healthScore: state.healthScore,
                    onMetricSelected: (m) =>
                        context.read<DashboardCubit>().selectMetric(m),
                  );
                  final right = _SelectedAreaColumn(
                    selectedType: state.selectionType,
                    selectedId: state.selectedId,
                    metricStatuses: state.metricStatuses,
                    readings: snapshot.metrics,
                    alerts: state.alerts,
                    onOpenTrends: onOpenTrends,
                    onOpenAlerts: onNavigateToAlerts,
                  );

                  if (desktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: left),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(flex: 10, child: center),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(flex: 5, child: right),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      left,
                      const SizedBox(height: AppDimensions.space16),
                      center,
                      const SizedBox(height: AppDimensions.space16),
                      right,
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _YourBodyCard extends StatelessWidget {
  const _YourBodyCard({
    required this.regions,
    required this.selectedId,
    required this.isBodySelection,
    required this.metricStatuses,
    required this.onSelect,
  });

  final List<BodyRegion> regions;
  final String selectedId;
  final bool isBodySelection;
  final Map<HealthMetricId, HealthStatus> metricStatuses;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your body', style: AppTextStyles.title),
          const SizedBox(height: 2),
          Text('Tap an area', style: AppTextStyles.caption),
          const SizedBox(height: AppDimensions.space8),
          SizedBox(
            height: 420,
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/illustrations/body_silhouette.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    ...regions.map((r) {
                      final metric = regionToMetric[r.id];
                      final status = metric != null
                          ? (metricStatuses[metric] ?? HealthStatus.unknown)
                          : HealthStatus.unknown;
                      final color = status == HealthStatus.unknown
                          ? AppColors.unavailable
                          : AppColors.status(
                              HealthStatusHelper.toneFor(status),
                            );
                      final selectedMetricRegion =
                          metricToRegion[_metricFromName(selectedId)];
                      final isMarkerSelected = isBodySelection
                          ? selectedId == r.id
                          : selectedMetricRegion == r.id;
                      return Positioned(
                        left: c.maxWidth * r.relativeX - 10,
                        top: c.maxHeight * r.relativeY - 10,
                        child: GestureDetector(
                          onTap: () => onSelect(r.id),
                          child: Container(
                            width: isMarkerSelected ? 22 : 18,
                            height: isMarkerSelected ? 22 : 18,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: const [
              _Legend(color: AppColors.green, label: 'Normal'),
              _Legend(color: AppColors.orange, label: 'Warning'),
              _Legend(color: AppColors.red, label: 'Critical'),
              _Legend(color: AppColors.unavailable, label: 'Unavailable'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _HealthOverview extends StatelessWidget {
  const _HealthOverview({
    required this.snapshot,
    this.selectedMetricId,
    this.metricStatuses = const {},
    this.healthScore,
    required this.onMetricSelected,
  });

  final TodaySnapshot snapshot;
  final String? selectedMetricId;
  final Map<HealthMetricId, HealthStatus> metricStatuses;
  final HealthScoreResult? healthScore;
  final ValueChanged<HealthMetricId> onMetricSelected;

  @override
  Widget build(BuildContext context) {
    final metrics = snapshot.metrics;
    return Column(
      children: [
        _OverallHealthCard(
          healthScore: healthScore,
          hasMetrics: metrics.isNotEmpty,
        ),
        const SizedBox(height: AppDimensions.space12),
        if (metrics.isEmpty) ...[
          CommonCard(
            child: Row(
              children: [
                const Icon(
                  Icons.insights_outlined,
                  color: AppColors.cyan,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    snapshot.attentionNote,
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
        ],
        LayoutBuilder(
          builder: (context, c) {
            final crossAxisCount = c.maxWidth >= 480
                ? 3
                : (c.maxWidth >= 320 ? 2 : 1);
            final ratio = c.maxWidth >= 900
                ? 1.45
                : (c.maxWidth >= 600 ? 1.3 : 1.15);
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.space8,
              mainAxisSpacing: AppDimensions.space8,
              childAspectRatio: ratio,
              children: _trackedMetrics
                  .map(
                    (metric) => _metricCard(
                      metric,
                      _firstWhereOrNull(
                        metrics,
                        (reading) => reading.metric == metric,
                      ),
                      selectedMetricId,
                      metricStatuses,
                      onMetricSelected,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: AppDimensions.space12),
        CommonCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              Text('Due soon', style: AppTextStyles.titleSm),
              SizedBox(width: 8),
              _DueChip(label: 'Morning check-in', due: 'now'),
              _DueChip(label: 'Vision check', due: 'Friday'),
              _DueChip(label: 'Exercise reminder', due: ''),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    HealthMetricId metric,
    HealthReading? reading,
    String? selectedMetricId,
    Map<HealthMetricId, HealthStatus> metricStatuses,
    ValueChanged<HealthMetricId> onMetricSelected,
  ) {
    final status = reading == null
        ? HealthStatus.unknown
        : (metricStatuses[metric] ?? HealthStatus.unknown);
    final tone = HealthStatusHelper.toneFor(status);
    final baseline = MockHealthBaselines.forMetric(metric);
    final available = reading != null;

    final (double min, double max) = switch (metric) {
      HealthMetricId.heartRate => (40, 120),
      HealthMetricId.bloodPressure => (80, 160),
      HealthMetricId.oxygen => (90, 100),
      HealthMetricId.temperature => (35, 39),
      HealthMetricId.sleep => (0, 10),
      HealthMetricId.mood => (1, 5),
      _ => (0, 100),
    };

    final subtitle = !available
        ? 'No reading yet'
        : metric == HealthMetricId.bloodPressure
        ? '${reading.displayValue} mmHg'
        : null;

    return HealthMetricCard(
      title: _metricCardTitle(metric),
      value: reading?.value ?? 0,
      unit: reading?.unit ?? metric.unit,
      status: tone,
      available: available,
      subtitle: subtitle,
      trend: HealthContentHelper.baselineText(metric),
      selected: selectedMetricId == metric.name,
      onTap: () => onMetricSelected(metric),
      gaugeMin: min,
      gaugeMax: max,
      baselineMin: baseline.min,
      baselineMax: baseline.max == baseline.min ? null : baseline.max,
    );
  }

  String _metricCardTitle(HealthMetricId metric) {
    return switch (metric) {
      HealthMetricId.heartRate => 'Heart rate',
      HealthMetricId.bloodPressure => 'Blood pressure',
      HealthMetricId.oxygen => 'Oxygen',
      HealthMetricId.temperature => 'Temperature',
      HealthMetricId.sleep => 'Sleep',
      HealthMetricId.mood => 'Mood',
      _ => metric.label,
    };
  }
}

class _OverallHealthCard extends StatelessWidget {
  const _OverallHealthCard({
    required this.healthScore,
    required this.hasMetrics,
  });

  final HealthScoreResult? healthScore;
  final bool hasMetrics;

  @override
  Widget build(BuildContext context) {
    final overall = healthScore?.overall;
    final scoreStatus = healthScore?.overallStatus ?? HealthStatus.unknown;
    final tone = HealthStatusHelper.toneFor(scoreStatus);

    final gauge = HealthGauge(
      value: (overall ?? 0).toDouble(),
      unit: 'of 100',
      min: 0,
      max: 100,
      status: tone,
      size: 128,
      available: overall != null,
      label: overall == null ? 'Not enough data' : null,
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Overall health', style: AppTextStyles.title),
        const SizedBox(height: 4),
        Text(_description(overall), style: AppTextStyles.body),
        const SizedBox(height: 4),
        Text(
          'AstroX is a monitoring tool, not a diagnostic service. Reference bands are general and may not fit your individual health context.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppDimensions.space12),
        _CategoryRow(label: 'Heart and body', value: healthScore?.heartBody),
        _CategoryRow(label: 'Sleep and mind', value: healthScore?.sleepMind),
        _CategoryRow(label: 'Fitness and bones', value: healthScore?.fitness),
      ],
    );

    return CommonCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 430) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: gauge),
                const SizedBox(height: AppDimensions.space12),
                details,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gauge,
              const SizedBox(width: AppDimensions.space16),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }

  String _description(int? overall) {
    if (!hasMetrics) {
      return 'Complete your first daily check-in to see your health overview.';
    }
    if (overall == null) {
      return 'More saved readings are needed before a wellness score can be shown.';
    }
    if (overall >= 85) {
      return 'Your saved readings are mostly within the configured reference ranges.';
    }
    if (overall >= 70) {
      return 'Some saved readings are outside the configured ranges. Keep monitoring.';
    }
    return 'Several saved readings need attention. Review the related metrics.';
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.label, required this.value});
  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final score = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (score == null)
            Text(
              'Not enough data',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            )
          else ...[
            Text(
              '$score',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 5,
                  color: AppColors.cyan,
                  backgroundColor: AppColors.border,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DueChip extends StatelessWidget {
  const _DueChip({required this.label, required this.due});
  final String label;
  final String due;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption),
          if (due.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              due,
              style: AppTextStyles.caption.copyWith(color: AppColors.cyan),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedAreaColumn extends StatelessWidget {
  const _SelectedAreaColumn({
    required this.selectedType,
    required this.selectedId,
    required this.metricStatuses,
    required this.readings,
    required this.alerts,
    this.onOpenTrends,
    this.onOpenAlerts,
  });

  final DashboardSelectionType selectedType;
  final String selectedId;
  final Map<HealthMetricId, HealthStatus> metricStatuses;
  final List<HealthReading> readings;
  final List<AlertItem> alerts;
  final void Function({String? areaFilter, HealthMetricId? metric})?
  onOpenTrends;
  final VoidCallback? onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    final metric = selectedType == DashboardSelectionType.bodyRegion
        ? (regionToMetric[selectedId] ?? HealthMetricId.heartRate)
        : _metricFromName(selectedId);
    final reading = _firstWhereOrNull(readings, (r) => r.metric == metric);
    final status = metricStatuses[metric] ?? HealthStatus.unknown;
    final details = HealthContentHelper.detailsFor(metric, status, reading);
    final relatedAlert = _firstWhereOrNull(alerts, (a) => a.metric == metric);

    return Column(
      children: [
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SELECTED AREA', style: AppTextStyles.overline),
              const SizedBox(height: 4),
              Text(
                details.title,
                style: AppTextStyles.title.copyWith(color: AppColors.cyan),
              ),
              const SizedBox(height: 4),
              HealthStatusBadge(status: status),
              const SizedBox(height: AppDimensions.space8),
              Text(details.description, style: AppTextStyles.body),
              const SizedBox(height: AppDimensions.space8),
              Text('READINGS', style: AppTextStyles.overline),
              const SizedBox(height: 4),
              ...details.readings.map(
                (r) => Text(r, style: AppTextStyles.body),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text('REFERENCE', style: AppTextStyles.overline),
              const SizedBox(height: 4),
              Text(details.baseline, style: AppTextStyles.body),
              const SizedBox(height: AppDimensions.space8),
              Text('WHY IT MATTERS', style: AppTextStyles.overline),
              const SizedBox(height: 4),
              Text(details.whyInSpace, style: AppTextStyles.body),
              const SizedBox(height: AppDimensions.space8),
              Text('Recommended action', style: AppTextStyles.bodyStrong),
              Text(details.recommendedAction, style: AppTextStyles.body),
              const SizedBox(height: AppDimensions.space12),
              PrimaryButton(
                label: 'Open full details',
                onPressed: () {
                  if (selectedType == DashboardSelectionType.bodyRegion) {
                    onOpenTrends?.call(areaFilter: selectedId);
                  } else {
                    onOpenTrends?.call(metric: metric);
                  }
                },
                expand: true,
              ),
            ],
          ),
        ),
        if (relatedAlert != null) ...[
          const SizedBox(height: AppDimensions.space12),
          _ActiveAlertCard(alert: relatedAlert, onViewGuidance: onOpenAlerts),
        ],
      ],
    );
  }
}

class _ActiveAlertCard extends StatelessWidget {
  const _ActiveAlertCard({required this.alert, this.onViewGuidance});

  final AlertItem alert;
  final VoidCallback? onViewGuidance;

  @override
  Widget build(BuildContext context) {
    final critical = alert.severity == AlertSeverity.critical;
    final color = critical ? AppColors.red : AppColors.orange;
    return CommonCard(
      color: critical ? AppColors.redMuted : AppColors.orangeMuted,
      borderColor: color.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE ALERT',
            style: AppTextStyles.overline.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                critical ? Icons.error_outline : Icons.warning_amber_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(alert.title, style: AppTextStyles.bodyStrong),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(alert.summary, style: AppTextStyles.body),
          if (alert.readingText != null) ...[
            const SizedBox(height: 2),
            Text(alert.readingText!, style: AppTextStyles.caption),
          ],
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'View guidance',
            onPressed: onViewGuidance ?? () {},
            expand: true,
          ),
        ],
      ),
    );
  }
}

HealthMetricId _metricFromName(String name) {
  return HealthMetricId.values.firstWhere(
    (m) => m.name == name,
    orElse: () => HealthMetricId.heartRate,
  );
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
