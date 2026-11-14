import '../database/app_database.dart';
import '../../data/models/health_metric_id.dart';
import '../../data/models/health_status.dart';
import 'health_status_helper.dart';

/// A purely non-diagnostic wellness summary built from the readings the user
/// actually saved. `null` always means "not enough data" and is never treated
/// as zero or as a normal reading.
class HealthScoreResult {
  const HealthScoreResult({
    this.overall,
    this.heartBody,
    this.sleepMind,
    this.fitness,
  });

  final int? overall;
  final int? heartBody;
  final int? sleepMind;
  final int? fitness;

  bool get hasOverall => overall != null;

  /// Wellness band used only to colour the gauge. This is not a medical
  /// classification.
  HealthStatus get overallStatus {
    final value = overall;
    if (value == null) return HealthStatus.unknown;
    if (value >= 85) return HealthStatus.normal;
    if (value >= 70) return HealthStatus.warning;
    return HealthStatus.critical;
  }
}

/// Calculates a simple wellness score from saved readings.
///
/// Rules (kept here so they are easy to review and change):
/// 1. Each available metric is converted to points using the same centralized
///    status rules as the rest of the app: Normal = 100, Watch = 60,
///    Alert = 30. Unavailable metrics are ignored.
/// 2. A category score is the average of its available metric points. A
///    category with no valid readings is `null` ("not enough data").
/// 3. The overall score is the average of the available category scores. It is
///    only produced when at least two categories have data, so a single
///    reading cannot generate a global health score.
/// 4. Fitness uses the logged exercise minutes against a non-clinical activity
///    goal (30+ min = 100, 15-29 min = 70, 1-14 min = 40). Text that does not
///    contain a number leaves the category unavailable.
///
/// This is a wellness summary, not a medical assessment.
class HealthScoreCalculator {
  static HealthScoreResult calculate(DailyHealthRecord? record) {
    if (record == null) return const HealthScoreResult();

    int? scoreFor(HealthStatus status) => switch (status) {
          HealthStatus.normal => 100,
          HealthStatus.warning => 60,
          HealthStatus.critical => 30,
          HealthStatus.unknown => null,
        };

    final heartScores = <int>[];
    if (record.heartRate != null) {
      final score = scoreFor(HealthStatusHelper.statusForMetric(
        HealthMetricId.heartRate,
        intValue: record.heartRate,
      ));
      if (score != null) heartScores.add(score);
    }
    if (record.systolic != null && record.diastolic != null) {
      final score = scoreFor(HealthStatusHelper.statusForMetric(
        HealthMetricId.bloodPressure,
        systolic: record.systolic,
        diastolic: record.diastolic,
      ));
      if (score != null) heartScores.add(score);
    }
    if (record.oxygenSaturation != null) {
      final score = scoreFor(HealthStatusHelper.statusForMetric(
        HealthMetricId.oxygen,
        intValue: record.oxygenSaturation,
      ));
      if (score != null) heartScores.add(score);
    }
    final heartBody = _average(heartScores);

    final sleepScores = <int>[];
    if (record.sleepHours != null) {
      final score = scoreFor(HealthStatusHelper.statusForMetric(
        HealthMetricId.sleep,
        doubleValue: record.sleepHours,
      ));
      if (score != null) sleepScores.add(score);
    }
    if (record.mood != null) {
      final score = scoreFor(HealthStatusHelper.statusForMetric(
        HealthMetricId.mood,
        intValue: record.mood,
      ));
      if (score != null) sleepScores.add(score);
    }
    final sleepMind = _average(sleepScores);

    final fitness = _fitnessScore(record.exercise);

    final categories = [heartBody, sleepMind, fitness].whereType<int>().toList();
    final overall = categories.length >= 2 ? _average(categories) : null;

    return HealthScoreResult(
      overall: overall,
      heartBody: heartBody,
      sleepMind: sleepMind,
      fitness: fitness,
    );
  }

  static int? _average(List<int> values) {
    if (values.isEmpty) return null;
    return (values.reduce((a, b) => a + b) / values.length).round();
  }

  static int? _fitnessScore(String? exercise) {
    if (exercise == null || exercise.trim().isEmpty) return null;
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(exercise);
    if (match == null) return null;
    final minutes = double.tryParse(match.group(0)!);
    if (minutes == null || minutes <= 0) return null;
    if (minutes >= 30) return 100;
    if (minutes >= 15) return 70;
    return 40;
  }
}
