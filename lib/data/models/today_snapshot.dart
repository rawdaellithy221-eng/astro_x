import 'package:equatable/equatable.dart';

import 'blood_pressure_reading.dart';
import 'body_region.dart';
import 'health_reading.dart';

class TodaySnapshot extends Equatable {
  const TodaySnapshot({
    required this.greetingName,
    this.bloodPressure,
    required this.metrics,
    required this.bodyRegions,
    required this.attentionNote,
  });

  final String greetingName;
  final BloodPressureReading? bloodPressure;
  final List<HealthReading> metrics;
  final List<BodyRegion> bodyRegions;
  final String attentionNote;

  @override
  List<Object?> get props => [
        greetingName,
        bloodPressure,
        metrics,
        bodyRegions,
        attentionNote,
      ];
}
