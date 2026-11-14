import 'package:equatable/equatable.dart';

import 'health_metric_id.dart';
import 'health_status.dart';

class AlertItem extends Equatable {
  const AlertItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    required this.createdAt,
    required this.guidance,
    this.isUnread = true,
    this.metric,
    this.readingText,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.oxygen,
  });

  final String id;
  final String title;
  final String summary;
  final AlertSeverity severity;
  final DateTime createdAt;
  final List<String> guidance;
  final bool isUnread;

  /// Metric that triggered this alert, so every screen can show the same
  /// condition next to the same metric.
  final HealthMetricId? metric;

  /// Human readable snapshot of the reading that triggered the alert.
  final String? readingText;

  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? oxygen;

  AlertItem copyWith({bool? isUnread}) {
    return AlertItem(
      id: id,
      title: title,
      summary: summary,
      severity: severity,
      createdAt: createdAt,
      guidance: guidance,
      isUnread: isUnread ?? this.isUnread,
      metric: metric,
      readingText: readingText,
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      oxygen: oxygen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        severity,
        createdAt,
        guidance,
        isUnread,
        metric,
        readingText,
        systolic,
        diastolic,
        heartRate,
        oxygen,
      ];
}
