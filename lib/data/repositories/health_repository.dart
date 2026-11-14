import '../mock/mock_health_baselines.dart';
import '../mock/mock_health_series.dart';
import '../mock/mock_today.dart';
import '../models/health_baseline.dart';
import '../models/health_metric_id.dart';
import '../models/health_status.dart';
import '../models/time_series_point.dart';
import '../models/today_snapshot.dart';

class HealthRepository {
  const HealthRepository();

  TodaySnapshot today() => MockToday.snapshot;

  HealthBaseline baseline(HealthMetricId metric) {
    return MockHealthBaselines.forMetric(metric);
  }

  List<HealthBaseline> baselines() => MockHealthBaselines.all;

  List<TimeSeriesPoint> series(HealthMetricId metric, TrendRange range) {
    return MockHealthSeries.forMetric(metric, range);
  }

  List<ChartAnnotation> heartRateAnnotations() {
    return MockHealthSeries.heartRateAnnotations();
  }
}
