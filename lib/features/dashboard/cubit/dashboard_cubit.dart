import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../core/helper/health_score_calculator.dart';
import '../../../core/helper/health_status_helper.dart';
import '../../../data/mock/mock_today.dart';
import '../../../data/models/alert_item.dart';
import '../../../data/models/blood_pressure_reading.dart';
import '../../../data/models/health_metric_id.dart';
import '../../../data/models/health_reading.dart';
import '../../../data/models/health_status.dart';
import '../../../data/models/today_snapshot.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/repositories/health_data_repository.dart';

enum DashboardSelectionType { bodyRegion, healthMetric }

class DashboardState extends Equatable {
  const DashboardState({
    this.loading = true,
    this.snapshot,
    this.unreadAlerts = 0,
    this.selectionType = DashboardSelectionType.bodyRegion,
    this.selectedId = 'chest-hr',
    this.healthScore,
    this.metricStatuses = const {},
    this.alerts = const [],
    this.error,
  });

  final bool loading;
  final TodaySnapshot? snapshot;
  final int unreadAlerts;
  final DashboardSelectionType selectionType;
  final String selectedId;
  final HealthScoreResult? healthScore;
  final Map<HealthMetricId, HealthStatus> metricStatuses;
  final List<AlertItem> alerts;
  final String? error;

  bool get isBodySelection =>
      selectionType == DashboardSelectionType.bodyRegion;

  DashboardState copyWith({
    bool? loading,
    TodaySnapshot? snapshot,
    int? unreadAlerts,
    DashboardSelectionType? selectionType,
    String? selectedId,
    HealthScoreResult? healthScore,
    Map<HealthMetricId, HealthStatus>? metricStatuses,
    List<AlertItem>? alerts,
    String? error,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      snapshot: snapshot ?? this.snapshot,
      unreadAlerts: unreadAlerts ?? this.unreadAlerts,
      selectionType: selectionType ?? this.selectionType,
      selectedId: selectedId ?? this.selectedId,
      healthScore: healthScore ?? this.healthScore,
      metricStatuses: metricStatuses ?? this.metricStatuses,
      alerts: alerts ?? this.alerts,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    snapshot,
    unreadAlerts,
    selectionType,
    selectedId,
    healthScore,
    metricStatuses,
    alerts,
    error,
  ];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    HealthDataRepository? repository,
    AlertRepository? alertRepository,
    this._userId,
  }) : _repo = repository,
       _alerts = alertRepository ?? const AlertRepository(),
       super(const DashboardState());

  final HealthDataRepository? _repo;
  final AlertRepository _alerts;
  final int? _userId;
  StreamSubscription? _sub;

  void load() {
    final repo = _repo;
    final userId = _userId;
    if (repo == null || userId == null) {
      emit(
        state.copyWith(
          loading: false,
          snapshot: _emptySnapshot(),
          healthScore: const HealthScoreResult(),
          metricStatuses: const {},
          alerts: const [],
          unreadAlerts: 0,
        ),
      );
      return;
    }
    _sub?.cancel();
    _sub = repo
        .watchLatestCompletedRecord(userId)
        .listen(
          (record) {
            final statuses = _computeStatuses(record);
            final alerts = record == null
                ? const <AlertItem>[]
                : _alerts.generate(record);
            emit(
              state.copyWith(
                loading: false,
                snapshot: _toSnapshot(record, statuses),
                healthScore: HealthScoreCalculator.calculate(record),
                metricStatuses: statuses,
                alerts: alerts,
                unreadAlerts: alerts.where((a) => a.isUnread).length,
              ),
            );
          },
          onError: (e) {
            emit(state.copyWith(loading: false, error: e.toString()));
          },
        );
  }

  TodaySnapshot _toSnapshot(
    DailyHealthRecord? record,
    Map<HealthMetricId, HealthStatus> statuses,
  ) {
    final metrics = <HealthReading>[];
    BloodPressureReading? bloodPressure;

    if (record != null) {
      final heartRate = record.heartRate;
      if (heartRate != null) {
        metrics.add(
          HealthReading(
            metric: HealthMetricId.heartRate,
            value: heartRate.toDouble(),
            recordedAt: record.lastUpdated,
            status: statuses[HealthMetricId.heartRate] ?? HealthStatus.unknown,
            label: 'Heart rate',
            unit: 'bpm',
          ),
        );
      }

      final systolic = record.systolic;
      final diastolic = record.diastolic;
      if (systolic != null && diastolic != null) {
        final status =
            statuses[HealthMetricId.bloodPressure] ?? HealthStatus.unknown;
        bloodPressure = BloodPressureReading(
          systolic: systolic,
          diastolic: diastolic,
          recordedAt: record.lastUpdated,
          status: status,
        );
        metrics.add(
          HealthReading(
            metric: HealthMetricId.bloodPressure,
            value: systolic.toDouble(),
            secondaryValue: diastolic.toDouble(),
            recordedAt: record.lastUpdated,
            status: status,
            label: 'Blood pressure',
            unit: 'mmHg',
          ),
        );
      }

      final oxygen = record.oxygenSaturation;
      if (oxygen != null) {
        metrics.add(
          HealthReading(
            metric: HealthMetricId.oxygen,
            value: oxygen.toDouble(),
            recordedAt: record.lastUpdated,
            status: statuses[HealthMetricId.oxygen] ?? HealthStatus.unknown,
            label: 'Oxygen',
            unit: '%',
          ),
        );
      }

      final temperature = record.temperature;
      if (temperature != null) {
        metrics.add(
          HealthReading(
            metric: HealthMetricId.temperature,
            value: temperature,
            recordedAt: record.lastUpdated,
            status:
                statuses[HealthMetricId.temperature] ?? HealthStatus.unknown,
            label: 'Temperature',
            unit: '°C',
          ),
        );
      }

      final sleep = record.sleepHours;
      if (sleep != null) {
        metrics.add(
          HealthReading(
            metric: HealthMetricId.sleep,
            value: sleep,
            recordedAt: record.lastUpdated,
            status: statuses[HealthMetricId.sleep] ?? HealthStatus.unknown,
            label: 'Sleep last night',
            unit: 'h',
          ),
        );
      }

      final mood = record.mood;
      if (mood != null) {
        metrics.add(
          HealthReading(
            metric: HealthMetricId.mood,
            value: mood.toDouble(),
            recordedAt: record.lastUpdated,
            status: statuses[HealthMetricId.mood] ?? HealthStatus.unknown,
            label: 'Mood today',
            unit: '/5',
          ),
        );
      }
    }

    return TodaySnapshot(
      greetingName: 'ASTRO_01',
      bloodPressure: bloodPressure,
      metrics: metrics,
      bodyRegions: MockToday.snapshot.bodyRegions,
      attentionNote: _attentionNote(statuses, metrics.isEmpty),
    );
  }

  String _attentionNote(
    Map<HealthMetricId, HealthStatus> statuses,
    bool isEmpty,
  ) {
    if (isEmpty) {
      return 'Welcome to AstroX. Complete your first daily check-in to see your health overview.';
    }
    if (statuses.values.contains(HealthStatus.critical)) {
      return 'Some saved readings need attention. Open the related metric for details.';
    }
    if (statuses.values.contains(HealthStatus.warning)) {
      return 'Some saved readings are marked for watch.';
    }
    return 'Your latest saved readings are within the configured reference ranges.';
  }

  TodaySnapshot _emptySnapshot() => TodaySnapshot(
    greetingName: 'ASTRO_01',
    metrics: const [],
    bodyRegions: MockToday.snapshot.bodyRegions,
    attentionNote: 'Welcome to AstroX. Complete your first daily check-in to see your health overview.',
  );

  Map<HealthMetricId, HealthStatus> _computeStatuses(
    DailyHealthRecord? record,
  ) {
    if (record == null) return {};
    final map = <HealthMetricId, HealthStatus>{};

    final heartRate = record.heartRate;
    if (heartRate != null) {
      map[HealthMetricId.heartRate] = HealthStatusHelper.statusForMetric(
        HealthMetricId.heartRate,
        intValue: heartRate,
      );
    }

    final systolic = record.systolic;
    final diastolic = record.diastolic;
    if (systolic != null && diastolic != null) {
      map[HealthMetricId.bloodPressure] = HealthStatusHelper.statusForMetric(
        HealthMetricId.bloodPressure,
        systolic: systolic,
        diastolic: diastolic,
      );
    }

    final oxygen = record.oxygenSaturation;
    if (oxygen != null) {
      map[HealthMetricId.oxygen] = HealthStatusHelper.statusForMetric(
        HealthMetricId.oxygen,
        intValue: oxygen,
      );
    }

    final temperature = record.temperature;
    if (temperature != null) {
      map[HealthMetricId.temperature] = HealthStatusHelper.statusForMetric(
        HealthMetricId.temperature,
        doubleValue: temperature,
      );
    }

    final sleep = record.sleepHours;
    if (sleep != null) {
      map[HealthMetricId.sleep] = HealthStatusHelper.statusForMetric(
        HealthMetricId.sleep,
        doubleValue: sleep,
      );
    }

    final mood = record.mood;
    if (mood != null) {
      map[HealthMetricId.mood] = HealthStatusHelper.statusForMetric(
        HealthMetricId.mood,
        intValue: mood,
      );
    }

    return map;
  }

  void selectBodyRegion(String id) => emit(
    state.copyWith(
      selectionType: DashboardSelectionType.bodyRegion,
      selectedId: id,
    ),
  );

  void selectMetric(HealthMetricId metric) => emit(
    state.copyWith(
      selectionType: DashboardSelectionType.healthMetric,
      selectedId: metric.name,
    ),
  );

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
