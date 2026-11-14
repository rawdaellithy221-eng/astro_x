import 'package:astrox/core/database/app_database.dart';
import 'package:astrox/core/helper/health_score_calculator.dart';
import 'package:astrox/core/helper/health_input_validator.dart';
import 'package:astrox/core/helper/health_status_helper.dart';
import 'package:astrox/data/models/health_metric_id.dart';
import 'package:astrox/data/models/health_status.dart';
import 'package:astrox/data/repositories/alert_repository.dart';
import 'package:flutter_test/flutter_test.dart';

DailyHealthRecord record({
  int? systolic,
  int? diastolic,
  int? heartRate,
  int? oxygenSaturation,
  double? temperature,
  double? sleepHours,
  int? mood,
  String? exercise,
}) {
  return DailyHealthRecord(
    id: 1,
    userId: 1,
    recordDate: DateTime(2026, 1, 1),
    systolic: systolic,
    diastolic: diastolic,
    heartRate: heartRate,
    oxygenSaturation: oxygenSaturation,
    temperature: temperature,
    sleepHours: sleepHours,
    mood: mood,
    exercise: exercise,
    completedSteps: 0,
    lastUpdated: DateTime(2026, 1, 1, 9),
  );
}

void main() {
  group('centralized metric status', () {
    test('normal readings map to Normal', () {
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.heartRate,
          intValue: 64,
        ),
        HealthStatus.normal,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.bloodPressure,
          systolic: 118,
          diastolic: 76,
        ),
        HealthStatus.normal,
      );
      expect(
        HealthStatusHelper.statusForMetric(HealthMetricId.oxygen, intValue: 98),
        HealthStatus.normal,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.temperature,
          doubleValue: 36.6,
        ),
        HealthStatus.normal,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.sleep,
          doubleValue: 8,
        ),
        HealthStatus.normal,
      );
      expect(
        HealthStatusHelper.statusForMetric(HealthMetricId.mood, intValue: 4),
        HealthStatus.normal,
      );
    });

    test('watch readings map to Watch', () {
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.sleep,
          doubleValue: 6.1,
        ),
        HealthStatus.warning,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.heartRate,
          intValue: 80,
        ),
        HealthStatus.normal,
      );
      expect(
        HealthStatusHelper.statusForMetric(HealthMetricId.oxygen, intValue: 92),
        HealthStatus.warning,
      );
      expect(
        HealthStatusHelper.statusForMetric(HealthMetricId.mood, intValue: 2),
        HealthStatus.warning,
      );
    });

    test('alert readings map to Alert', () {
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.heartRate,
          intValue: 130,
        ),
        HealthStatus.critical,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.bloodPressure,
          systolic: 160,
          diastolic: 100,
        ),
        HealthStatus.warning,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.bloodPressure,
          systolic: 181,
          diastolic: 121,
        ),
        HealthStatus.critical,
      );
      expect(
        HealthStatusHelper.statusForMetric(HealthMetricId.oxygen, intValue: 85),
        HealthStatus.critical,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.temperature,
          doubleValue: 39,
        ),
        HealthStatus.critical,
      );
      expect(
        HealthStatusHelper.statusForMetric(
          HealthMetricId.sleep,
          doubleValue: 4,
        ),
        HealthStatus.critical,
      );
      expect(
        HealthStatusHelper.statusForMetric(HealthMetricId.mood, intValue: 1),
        HealthStatus.warning,
      );
    });

    test(
      'missing readings stay unavailable and thresholds can be configured',
      () {
        expect(
          HealthStatusHelper.statusForMetric(HealthMetricId.heartRate),
          HealthStatus.unknown,
        );
        expect(
          HealthStatusHelper.statusForMetric(
            HealthMetricId.bloodPressure,
            systolic: 120,
          ),
          HealthStatus.unknown,
        );
        expect(
          HealthStatusHelper.statusForMetric(
            HealthMetricId.heartRate,
            intValue: 85,
            thresholds: const HealthReferenceThresholds(
              heartRateNormalMin: 70,
              heartRateNormalMax: 90,
            ),
          ),
          HealthStatus.normal,
        );
      },
    );
  });

  group('technical input validation', () {
    test('exercise accepts plausible notes and rejects typing noise', () {
      expect(
        HealthInputValidator.exerciseMinutes(
          'Resistance 20 min',
          validate: true,
        ),
        20,
      );
      expect(
        () => HealthInputValidator.exerciseMinutes('abc 20', validate: true),
        throwsFormatException,
      );
      expect(
        () => HealthInputValidator.exerciseMinutes(
          '1500 minutes',
          validate: true,
        ),
        throwsFormatException,
      );
    });
  });

  group('overall health scoring', () {
    test('no record produces no score and no fake normal state', () {
      final result = HealthScoreCalculator.calculate(null);
      expect(result.overall, isNull);
      expect(result.heartBody, isNull);
      expect(result.sleepMind, isNull);
      expect(result.fitness, isNull);
      expect(result.overallStatus, HealthStatus.unknown);
    });

    test('a single category is not enough for an overall score', () {
      final result = HealthScoreCalculator.calculate(
        record(heartRate: 75, systolic: 118, diastolic: 76),
      );
      expect(result.heartBody, 100);
      expect(result.sleepMind, isNull);
      expect(result.fitness, isNull);
      expect(result.overall, isNull);
    });

    test('complete readings produce dynamic category and overall scores', () {
      final result = HealthScoreCalculator.calculate(
        record(
          heartRate: 64,
          systolic: 118,
          diastolic: 76,
          oxygenSaturation: 98,
          temperature: 36.6,
          sleepHours: 6.1,
          mood: 4,
          exercise: '30',
        ),
      );
      expect(result.heartBody, 100);
      expect(result.sleepMind, 80);
      expect(result.fitness, 100);
      expect(result.overall, 93);
      expect(result.overallStatus, HealthStatus.normal);
    });

    test('fitness comes from the logged exercise minutes', () {
      expect(
        HealthScoreCalculator.calculate(record(exercise: '45 minutes')).fitness,
        100,
      );
      expect(
        HealthScoreCalculator.calculate(record(exercise: 'Resistance 20 min'))
            .fitness,
        70,
      );
      expect(
        HealthScoreCalculator.calculate(record(exercise: 'none')).fitness,
        isNull,
      );
    });
  });

  group('alerts from real readings', () {
    test('no record and normal readings produce no alerts', () {
      expect(const AlertRepository().generate(null), isEmpty);
      expect(
        const AlertRepository().generate(
          record(
            heartRate: 64,
            systolic: 118,
            diastolic: 76,
            oxygenSaturation: 98,
            temperature: 36.6,
            sleepHours: 8,
            mood: 4,
          ),
        ),
        isEmpty,
      );
    });

    test('warnings and alerts are generated once per metric', () {
      final alerts = const AlertRepository().generate(
        record(heartRate: 130, sleepHours: 6.1),
      );
      expect(alerts.length, 2);
      expect(
        alerts.any(
          (a) =>
              a.metric == HealthMetricId.heartRate &&
              a.severity == AlertSeverity.critical,
        ),
        isTrue,
      );
      expect(
        alerts.any(
          (a) =>
              a.metric == HealthMetricId.sleep &&
              a.severity == AlertSeverity.warning,
        ),
        isTrue,
      );
      expect(alerts.map((a) => a.id).toSet().length, alerts.length);
      expect(alerts.every((a) => a.readingText != null), isTrue);
    });
  });
}
