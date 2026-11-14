import 'package:equatable/equatable.dart';

import 'health_status.dart';

class BodyRegion extends Equatable {
  const BodyRegion({
    required this.id,
    required this.label,
    required this.status,
    required this.note,
    required this.relativeX,
    required this.relativeY,
  });

  final String id;
  final String label;
  final HealthStatus status;
  final String note;
  final double relativeX;
  final double relativeY;

  @override
  List<Object?> get props => [id, label, status, note, relativeX, relativeY];
}
