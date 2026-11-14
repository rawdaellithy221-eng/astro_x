import 'package:equatable/equatable.dart';

import 'health_metric_id.dart';
import 'health_status.dart';

class HealthReading extends Equatable {
  const HealthReading({
    required this.metric,
    required this.value,
    required this.recordedAt,
    required this.status,
    this.secondaryValue,
    this.label,
    this.unit,
  });

  final HealthMetricId metric;
  final double value;
  final double? secondaryValue;
  final DateTime recordedAt;
  final HealthStatus status;
  final String? label;
  final String? unit;

  String get displayValue {
    if (metric == HealthMetricId.bloodPressure && secondaryValue != null) {
      return '${value.round()}/${secondaryValue!.round()}';
    }
    if (value == value.roundToDouble()) return '${value.round()}';
    return value.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [
        metric,
        value,
        secondaryValue,
        recordedAt,
        status,
        label,
        unit,
      ];
}
