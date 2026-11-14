import 'package:equatable/equatable.dart';

import 'health_metric_id.dart';

class HealthBaseline extends Equatable {
  const HealthBaseline({
    required this.metric,
    required this.min,
    required this.max,
    this.secondaryMin,
    this.secondaryMax,
  });

  final HealthMetricId metric;
  final double min;
  final double max;
  final double? secondaryMin;
  final double? secondaryMax;

  String get rangeLabel {
    if (metric == HealthMetricId.bloodPressure &&
        secondaryMin != null &&
        secondaryMax != null) {
      return '${min.round()}/${secondaryMin!.round()}–${max.round()}/${secondaryMax!.round()}';
    }
    return '${_fmt(min)} to ${_fmt(max)}';
  }

  String _fmt(double n) => n == n.roundToDouble() ? '${n.round()}' : n.toStringAsFixed(1);

  @override
  List<Object?> get props => [metric, min, max, secondaryMin, secondaryMax];
}
