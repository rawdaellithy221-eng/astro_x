import '../../data/mock/mock_health_baselines.dart';
import '../../data/models/health_baseline.dart';
import '../../data/models/health_metric_id.dart';
import '../../data/models/health_reading.dart';
import '../../data/models/health_status.dart';
import '../../data/models/selected_area_details.dart';

/// Static educational copy plus formatting of real saved readings.
///
/// Educational text is allowed to live here; actual values never are. Every
/// reading shown by the Dashboard is passed in from the repository snapshot.
abstract final class HealthContentHelper {
  static String title(HealthMetricId metric) {
    return switch (metric) {
      HealthMetricId.heartRate => 'Heart rate',
      HealthMetricId.bloodPressure => 'Blood pressure',
      HealthMetricId.oxygen => 'Oxygen (SpO2)',
      HealthMetricId.temperature => 'Temperature',
      HealthMetricId.sleep => 'Sleep last night',
      HealthMetricId.mood => 'Mood today',
      HealthMetricId.weight => 'Weight',
      HealthMetricId.exercise => 'Exercise',
    };
  }

  static String statusLabel(HealthStatus status) {
    return switch (status) {
      HealthStatus.normal => 'Normal',
      HealthStatus.warning => 'Warning',
      HealthStatus.critical => 'Critical',
      HealthStatus.unknown => 'Unavailable',
    };
  }

  static String description(HealthMetricId metric, HealthStatus status) {
    if (status == HealthStatus.unknown) {
      return 'No ${title(metric).toLowerCase()} reading has been saved yet.';
    }
    return switch (status) {
      HealthStatus.normal => 'This reading is within the app’s general reference band. It does not confirm that a condition is absent.',
      HealthStatus.warning => 'This reading is outside the app’s general reference band. Consider the measurement context and your care plan.',
      HealthStatus.critical => 'This reading is far outside the app’s general reference band. Recheck it and seek appropriate clinical guidance if concerned.',
      HealthStatus.unknown => '',
    };
  }

  static String readingText(HealthMetricId metric, HealthReading? reading) {
    if (reading == null) return 'No reading yet';
    return switch (metric) {
      HealthMetricId.bloodPressure =>
        'Current reading: ${reading.displayValue} mmHg',
      HealthMetricId.mood => 'Current reading: ${reading.value.round()}/5',
      HealthMetricId.sleep =>
        'Current reading: ${_oneDecimal(reading.value)} h',
      HealthMetricId.temperature =>
        'Current reading: ${_oneDecimal(reading.value)} °C',
      HealthMetricId.oxygen => 'Current reading: ${reading.value.round()}%',
      _ =>
        'Current reading: ${reading.displayValue} ${reading.unit ?? metric.unit}',
    };
  }

  static String baselineText(HealthMetricId metric) {
    final baseline = _baselineFor(metric);
    if (baseline == null) return 'No reference range';

    if (metric == HealthMetricId.bloodPressure &&
        baseline.secondaryMin != null &&
        baseline.secondaryMax != null) {
      final systolic = baseline.min == baseline.max
          ? _fmt(baseline.min)
          : '${_fmt(baseline.min)}–${_fmt(baseline.max)}';
      final diastolic = baseline.secondaryMin == baseline.secondaryMax
          ? _fmt(baseline.secondaryMin!)
          : '${_fmt(baseline.secondaryMin!)}–${_fmt(baseline.secondaryMax!)}';
      return 'Reference: $systolic/$diastolic mmHg';
    }

    final range = baseline.min == baseline.max
        ? _fmt(baseline.min)
        : '${_fmt(baseline.min)} to ${_fmt(baseline.max)}';
    final unit = _unitSuffix(metric);
    return 'Reference: $range${unit.isEmpty ? '' : ' $unit'}';
  }

  static String whyItMatters(HealthMetricId metric) {
    return switch (metric) {
      HealthMetricId.heartRate => 'A sustained rise in resting heart rate can follow short sleep or extra physical load.',
      HealthMetricId.bloodPressure => 'In weightlessness, fluid shifts toward the head and the heart works against less gravity.',
      HealthMetricId.oxygen =>
        'Cabin air quality and activity level can influence oxygen saturation.',
      HealthMetricId.temperature =>
        'Fever in a closed-loop cabin needs an early flag.',
      HealthMetricId.sleep =>
        'Short sleep can raise resting heart rate the next day.',
      HealthMetricId.mood =>
        'Mood streaks help separate isolation load from a medical change.',
      HealthMetricId.weight =>
        'Weight changes can reflect fluid shifts during long missions.',
      HealthMetricId.exercise =>
        'Regular load helps protect muscle and blood volume in microgravity.',
    };
  }

  static String recommendedAction(HealthMetricId metric, HealthStatus status) {
    if (status == HealthStatus.unknown) {
      return 'Complete today\'s check-in to record this metric.';
    }
    if (status == HealthStatus.critical) {
      return 'Re-check the reading and consider contacting your healthcare professional, especially if you feel unwell.';
    }
    if (status == HealthStatus.warning) {
      return 'Re-check later today and keep the daily check-in routine.';
    }
    return 'Continue routine monitoring and follow your individual care plan.';
  }

  static SelectedAreaDetails detailsFor(
    HealthMetricId metric,
    HealthStatus status,
    HealthReading? reading,
  ) {
    return SelectedAreaDetails(
      title: title(metric),
      statusLabel: statusLabel(status),
      description: description(metric, status),
      readings: [readingText(metric, reading)],
      baseline: baselineText(metric),
      whyInSpace: whyItMatters(metric),
      recommendedAction: recommendedAction(metric, status),
    );
  }

  static HealthBaseline? _baselineFor(HealthMetricId metric) {
    try {
      return MockHealthBaselines.forMetric(metric);
    } catch (_) {
      return null;
    }
  }

  static String _unitSuffix(HealthMetricId metric) {
    return switch (metric) {
      HealthMetricId.heartRate => 'bpm',
      HealthMetricId.bloodPressure => 'mmHg',
      HealthMetricId.oxygen => '%',
      HealthMetricId.temperature => '°C',
      HealthMetricId.sleep => 'h',
      HealthMetricId.mood => '',
      HealthMetricId.weight => 'kg',
      HealthMetricId.exercise => 'min',
    };
  }

  static String _oneDecimal(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  static String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}
