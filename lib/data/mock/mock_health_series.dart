import '../models/health_metric_id.dart';
import '../models/health_status.dart';
import '../models/time_series_point.dart';
import 'mock_clock.dart';

/// Deterministic historical series. Never generated with Random().
abstract final class MockHealthSeries {
  static final DateTime end = MockClock.now;

  static List<TimeSeriesPoint> forMetric(
    HealthMetricId metric,
    TrendRange range,
  ) {
    final days = switch (range) {
      TrendRange.days7 => 7,
      TrendRange.days30 => 30,
      TrendRange.wholeMission => 90,
    };
    final series = _series(metric);
    return series.sublist(series.length - days);
  }

  static List<ChartAnnotation> heartRateAnnotations() {
    return [
      ChartAnnotation(
        date: end.subtract(const Duration(days: 5)),
        label: 'Spacewalk',
        colorHint: 'purple',
      ),
      ChartAnnotation(
        date: end.subtract(const Duration(days: 3)),
        label: '3 short nights',
        colorHint: 'orange',
      ),
      ChartAnnotation(
        date: end.subtract(const Duration(days: 2)),
        label: 'Watch above 100 at rest',
        colorHint: 'orange',
      ),
    ];
  }

  static List<TimeSeriesPoint> _series(HealthMetricId metric) {
    return List<TimeSeriesPoint>.generate(90, (index) {
      final daysAgo = 89 - index;
      final date = DateTime(end.year, end.month, end.day)
          .subtract(Duration(days: daysAgo));
      return TimeSeriesPoint(
        date: date,
        value: _value(metric, daysAgo),
        secondaryValue: metric == HealthMetricId.bloodPressure
            ? _diastolic(daysAgo)
            : null,
      );
    });
  }

  static double _value(HealthMetricId metric, int daysAgo) {
    return switch (metric) {
      HealthMetricId.heartRate => _heartRate(daysAgo),
      HealthMetricId.bloodPressure => _systolic(daysAgo),
      HealthMetricId.oxygen => daysAgo == 0 ? 98 : 97.0 + (daysAgo % 3 == 0 ? 1 : 0),
      HealthMetricId.temperature => 36.6 + (daysAgo % 5 == 0 ? 0.2 : 0),
      HealthMetricId.sleep => _sleep(daysAgo),
      HealthMetricId.mood => _mood(daysAgo),
      HealthMetricId.weight => 72.4 - (daysAgo < 20 ? 0.02 * (20 - daysAgo) : 0),
      HealthMetricId.exercise => _exercise(daysAgo),
    };
  }

  static double _heartRate(int daysAgo) {
    if (daysAgo == 0) return 74;
    if (daysAgo <= 6) return 62 + (7 - daysAgo) * 1.7;
    final wave = (daysAgo % 6) - 3;
    return 61 + wave * 0.4;
  }

  static double _systolic(int daysAgo) {
    if (daysAgo == 12) return 86;
    if (daysAgo == 0) return 118;
    return 116 + (daysAgo % 4 == 0 ? 2 : 0);
  }

  static double _diastolic(int daysAgo) {
    if (daysAgo == 12) return 56;
    if (daysAgo == 0) return 76;
    return 75 + (daysAgo % 5 == 0 ? 1 : 0);
  }

  static double _sleep(int daysAgo) {
    if (daysAgo <= 6) {
      const week = [6.0, 5.8, 6.1, 6.4, 5.9, 6.2, 6.0];
      return week[daysAgo];
    }
    return 7.1;
  }

  static double _mood(int daysAgo) {
    const pattern = [4.0, 3.0, 4.0, 3.0, 4.0, 4.0, 3.0];
    return pattern[daysAgo % pattern.length];
  }

  static double _exercise(int daysAgo) {
    if (daysAgo % 7 == 3) return 40;
    return 90;
  }
}
