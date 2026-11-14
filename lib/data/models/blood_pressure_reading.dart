import 'package:equatable/equatable.dart';

import 'health_status.dart';

class BloodPressureReading extends Equatable {
  const BloodPressureReading({
    required this.systolic,
    required this.diastolic,
    required this.recordedAt,
    required this.status,
    this.context = CheckInContext.resting,
  });

  final int systolic;
  final int diastolic;
  final DateTime recordedAt;
  final HealthStatus status;
  final CheckInContext context;

  String get display => '$systolic/$diastolic';

  @override
  List<Object?> get props => [systolic, diastolic, recordedAt, status, context];
}
