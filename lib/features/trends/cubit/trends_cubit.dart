import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../core/helper/health_history_helper.dart';
import '../../../data/mock/mock_dashboard.dart';
import '../../../data/models/health_metric_id.dart';
import '../../../data/models/health_status.dart' show TrendRange;
import '../../../data/models/time_series_point.dart'
    show TimeSeriesPoint, ChartAnnotation;
import '../../../data/repositories/health_data_repository.dart';
import '../../../data/repositories/health_repository.dart';

const _trendMetrics = [
  HealthMetricId.heartRate,
  HealthMetricId.bloodPressure,
  HealthMetricId.oxygen,
  HealthMetricId.temperature,
  HealthMetricId.sleep,
  HealthMetricId.mood,
  HealthMetricId.exercise,
];

class TrendsState extends Equatable {
  const TrendsState({
    this.loading = true,
    this.metric = HealthMetricId.heartRate,
    this.range = TrendRange.days7,
    this.points = const [],
    this.records = const [],
    this.baselineMin,
    this.baselineMax,
    this.annotations = const [],
    this.areaFilter,
    this.availableMetrics = _trendMetrics,
  });

  final bool loading;
  final HealthMetricId metric;
  final TrendRange range;
  final List<TimeSeriesPoint> points;
  final List<DailyHealthRecord> records;
  final double? baselineMin;
  final double? baselineMax;
  final List<ChartAnnotation> annotations;
  final String? areaFilter;
  final List<HealthMetricId> availableMetrics;

  TrendsState copyWith({
    bool? loading,
    HealthMetricId? metric,
    TrendRange? range,
    List<TimeSeriesPoint>? points,
    List<DailyHealthRecord>? records,
    double? baselineMin,
    double? baselineMax,
    List<ChartAnnotation>? annotations,
    String? areaFilter,
    bool clearAreaFilter = false,
    List<HealthMetricId>? availableMetrics,
  }) {
    return TrendsState(
      loading: loading ?? this.loading,
      metric: metric ?? this.metric,
      range: range ?? this.range,
      points: points ?? this.points,
      records: records ?? this.records,
      baselineMin: baselineMin ?? this.baselineMin,
      baselineMax: baselineMax ?? this.baselineMax,
      annotations: annotations ?? this.annotations,
      areaFilter: clearAreaFilter ? null : (areaFilter ?? this.areaFilter),
      availableMetrics: availableMetrics ?? this.availableMetrics,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    metric,
    range,
    points,
    records,
    baselineMin,
    baselineMax,
    annotations,
    areaFilter,
    availableMetrics,
  ];
}

class TrendsCubit extends Cubit<TrendsState> {
  TrendsCubit({
    HealthRepository? repository,
    HealthDataRepository? healthRepository,
    this.userId,
    String? areaFilter,
    HealthMetricId? initialMetric,
  }) : _repo = repository ?? const HealthRepository(),
       _health = healthRepository,
       super(TrendsState(areaFilter: areaFilter)) {
    load(areaFilter: areaFilter, initialMetric: initialMetric);
  }

  final HealthRepository _repo;
  final HealthDataRepository? _health;
  final int? userId;
  int _loadToken = 0;

  Future<void> load({
    HealthMetricId? metric,
    TrendRange? range,
    String? areaFilter,
    bool clearArea = false,
    HealthMetricId? initialMetric,
  }) async {
    final token = ++_loadToken;
    final a = clearArea ? null : (areaFilter ?? state.areaFilter);
    final allowed = a == null
        ? _trendMetrics
        : (MockDashboard.regionMetrics[a] ?? [HealthMetricId.heartRate]);
    final candidate = initialMetric ?? metric;
    final m = candidate != null && allowed.contains(candidate)
        ? candidate
        : (allowed.contains(state.metric) ? state.metric : allowed.first);
    final r = range ?? state.range;
    final baseline = _repo.baseline(m);

    emit(
      state.copyWith(
        loading: true,
        metric: m,
        range: r,
        baselineMin: baseline.min,
        baselineMax: baseline.max,
        areaFilter: a,
        clearAreaFilter: clearArea,
        availableMetrics: allowed,
      ),
    );

    List<DailyHealthRecord> records;
    try {
      records = await _fetchRecords(r);
    } catch (_) {
      if (isClosed || token != _loadToken) return;
      emit(
        state.copyWith(
          loading: false,
          points: const [],
          records: const [],
          annotations: const [],
        ),
      );
      return;
    }

    if (isClosed || token != _loadToken) return;
    emit(
      state.copyWith(
        loading: false,
        metric: m,
        range: r,
        points: HealthHistoryHelper.pointsFor(records, m),
        records: records,
        baselineMin: baseline.min,
        baselineMax: baseline.max,
        annotations: const [],
        areaFilter: a,
        clearAreaFilter: clearArea,
        availableMetrics: allowed,
      ),
    );
  }

  Future<List<DailyHealthRecord>> _fetchRecords(TrendRange range) async {
    final health = _health;
    final uid = userId;
    if (health == null || uid == null) return const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = switch (range) {
      TrendRange.days7 => today.subtract(const Duration(days: 6)),
      TrendRange.days30 => today.subtract(const Duration(days: 29)),
      TrendRange.wholeMission => null,
    };
    return health.getRecords(
      uid,
      start: start,
      end: today.add(const Duration(days: 1)),
      completedOnly: true,
    );
  }

  void selectMetric(HealthMetricId metric) {
    if (!state.availableMetrics.contains(metric)) return;
    load(metric: metric);
  }

  void selectRange(TrendRange range) => load(range: range);

  void clearAreaFilter() => load(clearArea: true);
}
