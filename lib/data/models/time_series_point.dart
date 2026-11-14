import 'package:equatable/equatable.dart';

class TimeSeriesPoint extends Equatable {
  const TimeSeriesPoint({
    required this.date,
    required this.value,
    this.secondaryValue,
  });

  final DateTime date;
  final double value;
  final double? secondaryValue;

  @override
  List<Object?> get props => [date, value, secondaryValue];
}

class ChartAnnotation extends Equatable {
  const ChartAnnotation({
    required this.date,
    required this.label,
    this.colorHint,
  });

  final DateTime date;
  final String label;
  final String? colorHint;

  @override
  List<Object?> get props => [date, label, colorHint];
}

class ChartLegendItem extends Equatable {
  const ChartLegendItem({
    required this.label,
    required this.colorValue,
  });

  final String label;
  final int colorValue;

  @override
  List<Object?> get props => [label, colorValue];
}
