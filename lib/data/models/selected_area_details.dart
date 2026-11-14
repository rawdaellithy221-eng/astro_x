import 'package:equatable/equatable.dart';

class SelectedAreaDetails extends Equatable {
  const SelectedAreaDetails({
    required this.title,
    required this.statusLabel,
    required this.description,
    required this.readings,
    required this.baseline,
    required this.whyInSpace,
    required this.recommendedAction,
  });

  final String title;
  final String statusLabel;
  final String description;
  final List<String> readings;
  final String baseline;
  final String whyInSpace;
  final String recommendedAction;

  @override
  List<Object?> get props => [title, statusLabel, description, readings, baseline, whyInSpace, recommendedAction];
}