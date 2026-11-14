import 'package:equatable/equatable.dart';

import 'health_metric_id.dart';

class CheckInStep extends Equatable {
  const CheckInStep({
    required this.index,
    required this.metric,
    required this.title,
    required this.prompt,
    required this.howTo,
    required this.whyItMatters,
  });

  final int index;
  final HealthMetricId metric;
  final String title;
  final String prompt;
  final List<String> howTo;
  final String whyItMatters;

  @override
  List<Object?> get props => [index, metric, title, prompt, howTo, whyItMatters];
}
