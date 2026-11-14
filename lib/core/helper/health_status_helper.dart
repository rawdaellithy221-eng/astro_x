import '../../data/models/health_metric_id.dart';
import '../../data/models/health_status.dart';
import '../constants/app_colors.dart';

/// Configurable general reference bands for adult wellness monitoring.
/// These are prompts for review, not diagnostic criteria. Individual targets
/// vary with age, pregnancy, altitude, activity, conditions, and care plans.
class HealthReferenceThresholds {
  const HealthReferenceThresholds({
    this.heartRateNormalMin = 60,
    this.heartRateNormalMax = 100,
    this.heartRateCriticalBelow = 40,
    this.heartRateCriticalAbove = 120,
    this.systolicNormalBelow = 120,
    this.diastolicNormalBelow = 80,
    this.systolicCriticalAbove = 180,
    this.diastolicCriticalAbove = 120,
    this.oxygenNormalMin = 95,
    this.oxygenCriticalBelow = 90,
    this.temperatureNormalMin = 36,
    this.temperatureNormalMax = 37.5,
    this.temperatureCriticalBelow = 35,
    this.temperatureCriticalAbove = 39,
    this.sleepNormalMin = 7,
    this.sleepNormalMax = 9,
    this.sleepCriticalBelow = 4,
    this.sleepCriticalAbove = 12,
    this.moodNormalMin = 3,
  });

  final int heartRateNormalMin;
  final int heartRateNormalMax;
  final int heartRateCriticalBelow;
  final int heartRateCriticalAbove;
  final int systolicNormalBelow;
  final int diastolicNormalBelow;
  final int systolicCriticalAbove;
  final int diastolicCriticalAbove;
  final int oxygenNormalMin;
  final int oxygenCriticalBelow;
  final double temperatureNormalMin;
  final double temperatureNormalMax;
  final double temperatureCriticalBelow;
  final double temperatureCriticalAbove;
  final double sleepNormalMin;
  final double sleepNormalMax;
  final double sleepCriticalBelow;
  final double sleepCriticalAbove;
  final int moodNormalMin;
}

abstract final class HealthStatusHelper {
  static const HealthReferenceThresholds defaultThresholds =
      HealthReferenceThresholds();

  static HealthStatus fromThresholds({
    required double value,
    required double normalMin,
    required double normalMax,
    required double warnMin,
    required double warnMax,
  }) {
    if (value >= normalMin && value <= normalMax) return HealthStatus.normal;
    if (value >= warnMin && value <= warnMax) return HealthStatus.warning;
    return HealthStatus.critical;
  }

  static HealthTone toneFor(HealthStatus status) => switch (status) {
    HealthStatus.normal => HealthTone.normal,
    HealthStatus.warning => HealthTone.warning,
    HealthStatus.critical => HealthTone.critical,
    HealthStatus.unknown => HealthTone.neutral,
  };

  static HealthStatus statusForMetric(
    HealthMetricId metric, {
    int? intValue,
    double? doubleValue,
    int? systolic,
    int? diastolic,
    HealthReferenceThresholds thresholds = defaultThresholds,
  }) {
    switch (metric) {
      case HealthMetricId.heartRate:
        final value = intValue ?? doubleValue?.round();
        if (value == null) return HealthStatus.unknown;
        if (value < thresholds.heartRateCriticalBelow ||
            value > thresholds.heartRateCriticalAbove) {
          return HealthStatus.critical;
        }
        if (value >= thresholds.heartRateNormalMin &&
            value <= thresholds.heartRateNormalMax) {
          return HealthStatus.normal;
        }
        return HealthStatus.warning;
      case HealthMetricId.bloodPressure:
        if (systolic == null || diastolic == null) return HealthStatus.unknown;
        if (systolic > thresholds.systolicCriticalAbove ||
            diastolic > thresholds.diastolicCriticalAbove) {
          return HealthStatus.critical;
        }
        if (systolic < thresholds.systolicNormalBelow &&
            diastolic < thresholds.diastolicNormalBelow &&
            systolic >= 90 &&
            diastolic >= 60) {
          return HealthStatus.normal;
        }
        return HealthStatus.warning;
      case HealthMetricId.oxygen:
        final value = intValue ?? doubleValue?.round();
        if (value == null) return HealthStatus.unknown;
        if (value < thresholds.oxygenCriticalBelow) {
          return HealthStatus.critical;
        }
        if (value < thresholds.oxygenNormalMin) return HealthStatus.warning;
        return HealthStatus.normal;
      case HealthMetricId.temperature:
        final value = doubleValue ?? intValue?.toDouble();
        if (value == null) return HealthStatus.unknown;
        if (value < thresholds.temperatureCriticalBelow ||
            value >= thresholds.temperatureCriticalAbove) {
          return HealthStatus.critical;
        }
        if (value >= thresholds.temperatureNormalMin &&
            value <= thresholds.temperatureNormalMax) {
          return HealthStatus.normal;
        }
        return HealthStatus.warning;
      case HealthMetricId.sleep:
        final value = doubleValue ?? intValue?.toDouble();
        if (value == null) return HealthStatus.unknown;
        if (value <= thresholds.sleepCriticalBelow ||
            value > thresholds.sleepCriticalAbove) {
          return HealthStatus.critical;
        }
        if (value >= thresholds.sleepNormalMin &&
            value <= thresholds.sleepNormalMax) {
          return HealthStatus.normal;
        }
        return HealthStatus.warning;
      case HealthMetricId.mood:
        final value = intValue ?? doubleValue?.round();
        if (value == null) return HealthStatus.unknown;
        // Mood is self-reported and cannot support a severity/diagnosis from
        // this number alone. Lower scores prompt a check-in, never Critical.
        return value >= thresholds.moodNormalMin
            ? HealthStatus.normal
            : HealthStatus.warning;
      default:
        return HealthStatus.unknown;
    }
  }
}
