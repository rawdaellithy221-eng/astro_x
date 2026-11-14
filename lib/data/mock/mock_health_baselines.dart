import '../models/health_baseline.dart';
import '../models/health_metric_id.dart';

abstract final class MockHealthBaselines {
  static const HealthBaseline heartRate = HealthBaseline(
    metric: HealthMetricId.heartRate,
    min: 60,
    max: 100,
  );

  static const HealthBaseline bloodPressure = HealthBaseline(
    metric: HealthMetricId.bloodPressure,
    min: 90,
    max: 119,
    secondaryMin: 60,
    secondaryMax: 79,
  );

  static const HealthBaseline oxygen = HealthBaseline(
    metric: HealthMetricId.oxygen,
    min: 95,
    max: 100,
  );

  static const HealthBaseline temperature = HealthBaseline(
    metric: HealthMetricId.temperature,
    min: 36,
    max: 37.5,
  );

  static const HealthBaseline sleep = HealthBaseline(
    metric: HealthMetricId.sleep,
    min: 7,
    max: 9,
  );

  static const HealthBaseline mood = HealthBaseline(
    metric: HealthMetricId.mood,
    min: 3,
    max: 5,
  );

  static const HealthBaseline weight = HealthBaseline(
    metric: HealthMetricId.weight,
    min: 71.8,
    max: 73.2,
  );

  static const HealthBaseline exercise = HealthBaseline(
    metric: HealthMetricId.exercise,
    min: 90,
    max: 90,
  );

  static const List<HealthBaseline> all = [
    heartRate,
    bloodPressure,
    oxygen,
    temperature,
    sleep,
    mood,
    weight,
    exercise,
  ];

  static HealthBaseline forMetric(HealthMetricId id) {
    return all.firstWhere((item) => item.metric == id);
  }
}
