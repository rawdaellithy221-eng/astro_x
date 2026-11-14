import '../../data/models/health_metric_id.dart';
import '../../data/models/time_series_point.dart';
import '../database/app_database.dart';

/// Maps saved SQLite rows to the chart model used by Trends.
///
/// A metric with no saved value is skipped, never replaced with a placeholder
/// or mock reading. Multiple check-ins on one calendar day remain separate
/// historical points and are sorted by their saved timestamp.
abstract final class HealthHistoryHelper {
  static List<TimeSeriesPoint> pointsFor(
    List<DailyHealthRecord> records,
    HealthMetricId metric,
  ) {
    final ordered = records.toList()
      ..sort((a, b) {
        final dateOrder = _dateFor(a).compareTo(_dateFor(b));
        return dateOrder != 0 ? dateOrder : a.id.compareTo(b.id);
      });

    final points = <TimeSeriesPoint>[];
    for (final record in ordered) {
      final value = valueFor(record, metric);
      if (value == null) continue;
      points.add(
        TimeSeriesPoint(
          date: _dateFor(record),
          value: value,
          secondaryValue: secondaryValueFor(record, metric),
        ),
      );
    }
    return points;
  }

  static DateTime _dateFor(DailyHealthRecord record) {
    return record.completedAt ?? record.lastUpdated;
  }

  static List<TimeSeriesPoint> lastDays(
    List<TimeSeriesPoint> points,
    int days, {
    DateTime? now,
  }) {
    final end = now ?? DateTime.now();
    final cutoff = DateTime(
      end.year,
      end.month,
      end.day,
    ).subtract(Duration(days: days - 1));
    return points.where((point) => !point.date.isBefore(cutoff)).toList();
  }

  static double? valueFor(DailyHealthRecord record, HealthMetricId metric) {
    return switch (metric) {
      HealthMetricId.heartRate => record.heartRate?.toDouble(),
      HealthMetricId.bloodPressure =>
        record.systolic != null && record.diastolic != null
            ? record.systolic!.toDouble()
            : null,
      HealthMetricId.oxygen => record.oxygenSaturation?.toDouble(),
      HealthMetricId.temperature => record.temperature,
      HealthMetricId.sleep => record.sleepHours,
      HealthMetricId.mood => record.mood?.toDouble(),
      HealthMetricId.exercise => exerciseMinutes(record.exercise),
      HealthMetricId.weight => null,
    };
  }

  static double? secondaryValueFor(
    DailyHealthRecord record,
    HealthMetricId metric,
  ) {
    if (metric == HealthMetricId.bloodPressure &&
        record.systolic != null &&
        record.diastolic != null) {
      return record.diastolic!.toDouble();
    }
    return null;
  }

  static double? exerciseMinutes(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(text);
    if (match == null) return null;
    final value = double.tryParse(match.group(0)!);
    if (value == null || value <= 0) return null;
    return value;
  }
}
