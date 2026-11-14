import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/helper/health_status_helper.dart';
import '../models/alert_item.dart';
import '../models/health_metric_id.dart';
import '../models/health_status.dart';

/// Builds and persists alerts from the readings the user actually saved.
///
/// One alert per metric at most, so a condition can never be duplicated. A
/// metric with no reading, or with a Normal status, produces no alert.
class AlertRepository {
  const AlertRepository([this._db]);

  final AppDatabase? _db;

  List<AlertItem> generate(DailyHealthRecord? record) {
    if (record == null) return const [];

    final alerts = <AlertItem>[];

    void addIfAbnormal({
      required HealthMetricId metric,
      required HealthStatus status,
      required String title,
      required String summary,
      required String readingText,
      required List<String> guidance,
      int? systolic,
      int? diastolic,
      int? heartRate,
      int? oxygen,
    }) {
      if (status != HealthStatus.warning && status != HealthStatus.critical) {
        return;
      }
      alerts.add(
        AlertItem(
          id: 'alert-${record.id}-${metric.name}',
          title: title,
          summary: summary,
          severity: status == HealthStatus.critical
              ? AlertSeverity.critical
              : AlertSeverity.warning,
          createdAt: record.lastUpdated,
          guidance: guidance,
          metric: metric,
          readingText: readingText,
          systolic: systolic,
          diastolic: diastolic,
          heartRate: heartRate,
          oxygen: oxygen,
        ),
      );
    }

    if (record.heartRate != null) {
      final status = HealthStatusHelper.statusForMetric(
        HealthMetricId.heartRate,
        intValue: record.heartRate,
      );
      addIfAbnormal(
        metric: HealthMetricId.heartRate,
        status: status,
        title: status == HealthStatus.critical
            ? 'Heart rate alert'
            : 'Heart rate outside usual range',
        summary: 'Resting heart rate is ${record.heartRate} bpm.',
        readingText: '${record.heartRate} bpm',
        heartRate: record.heartRate,
        guidance: const [
          'Sit or float still for five minutes and re-check.',
          'Protect tonight\'s sleep and keep hydrated.',
          'Flag the medical officer if the reading stays outside your range.',
        ],
      );
    }

    if (record.systolic != null && record.diastolic != null) {
      final status = HealthStatusHelper.statusForMetric(
        HealthMetricId.bloodPressure,
        systolic: record.systolic,
        diastolic: record.diastolic,
      );
      addIfAbnormal(
        metric: HealthMetricId.bloodPressure,
        status: status,
        title: status == HealthStatus.critical
            ? 'Blood pressure alert'
            : 'Blood pressure outside usual range',
        summary: 'Reading is ${record.systolic}/${record.diastolic} mmHg.',
        readingText: '${record.systolic}/${record.diastolic} mmHg',
        systolic: record.systolic,
        diastolic: record.diastolic,
        guidance: const [
          'Rest for five minutes and measure again on a relaxed arm.',
          'Drink fluids if you feel dizzy.',
          'Flag the medical officer if the second reading stays outside your range.',
        ],
      );
    }

    if (record.oxygenSaturation != null) {
      final status = HealthStatusHelper.statusForMetric(
        HealthMetricId.oxygen,
        intValue: record.oxygenSaturation,
      );
      addIfAbnormal(
        metric: HealthMetricId.oxygen,
        status: status,
        title: status == HealthStatus.critical
            ? 'Oxygen saturation alert'
            : 'Oxygen saturation below usual range',
        summary: 'SpO2 is ${record.oxygenSaturation}%.',
        readingText: '${record.oxygenSaturation}%',
        oxygen: record.oxygenSaturation,
        guidance: const [
          'Sit still and re-check the sensor placement.',
          'Avoid strenuous activity until the reading settles.',
          'Flag the medical officer if the reading remains low.',
        ],
      );
    }

    if (record.temperature != null) {
      final status = HealthStatusHelper.statusForMetric(
        HealthMetricId.temperature,
        doubleValue: record.temperature,
      );
      addIfAbnormal(
        metric: HealthMetricId.temperature,
        status: status,
        title: status == HealthStatus.critical
            ? 'Temperature alert'
            : 'Temperature outside usual range',
        summary: 'Body temperature is ${_oneDecimal(record.temperature!)} °C.',
        readingText: '${_oneDecimal(record.temperature!)} °C',
        guidance: const [
          'Re-check with the assigned thermometer.',
          'Keep fluids up and rest if you feel unwell.',
          'Flag the medical officer if the temperature keeps rising.',
        ],
      );
    }

    if (record.sleepHours != null) {
      final status = HealthStatusHelper.statusForMetric(
        HealthMetricId.sleep,
        doubleValue: record.sleepHours,
      );
      addIfAbnormal(
        metric: HealthMetricId.sleep,
        status: status,
        title: status == HealthStatus.critical
            ? 'Very short sleep'
            : 'Sleep outside usual range',
        summary: 'You logged ${_oneDecimal(record.sleepHours!)} h of sleep.',
        readingText: '${_oneDecimal(record.sleepHours!)} h',
        guidance: const [
          'Dim cabin lights earlier and protect the wind-down window.',
          'Re-check resting heart rate tomorrow morning.',
        ],
      );
    }

    if (record.mood != null) {
      final status = HealthStatusHelper.statusForMetric(
        HealthMetricId.mood,
        intValue: record.mood,
      );
      addIfAbnormal(
        metric: HealthMetricId.mood,
        status: status,
        title: status == HealthStatus.critical
            ? 'Low mood score'
            : 'Mood outside usual range',
        summary: 'Mood is ${record.mood}/5 today.',
        readingText: '${record.mood}/5',
        guidance: const [
          'Talk to your crew and note what changed today.',
          'Keep the daily check-in routine going.',
        ],
      );
    }

    // Critical alerts are listed first so the Dashboard surfaces them.
    alerts.sort((a, b) {
      final aCritical = a.severity == AlertSeverity.critical ? 0 : 1;
      final bCritical = b.severity == AlertSeverity.critical ? 0 : 1;
      return aCritical.compareTo(bCritical);
    });
    return alerts;
  }

  /// Regenerates alerts for a completed record and writes them to SQLite.
  ///
  /// Repeated calls are safe: the deterministic alert id maps to one row and
  /// an unchanged alert keeps its read state.
  Future<void> syncForRecord(DailyHealthRecord record) async {
    if (record.completedAt == null) return;
    final db = _db;
    if (db == null) return;
    await saveForRecord(record, generate(record));
  }

  Stream<List<AlertItem>> watchForRecord(int recordId) {
    final db = _db;
    if (db == null) return Stream.value(const []);

    final query = db.select(db.healthAlerts)
      ..where((t) => t.recordId.equals(recordId));

    return query.watch().map((rows) {
      final alerts = rows.map(_fromRow).toList();
      alerts.sort((a, b) {
        final aCritical = a.severity == AlertSeverity.critical ? 0 : 1;
        final bCritical = b.severity == AlertSeverity.critical ? 0 : 1;
        final bySeverity = aCritical.compareTo(bCritical);
        if (bySeverity != 0) return bySeverity;
        return b.createdAt.compareTo(a.createdAt);
      });
      return alerts;
    });
  }

  Future<void> saveForRecord(
    DailyHealthRecord record,
    List<AlertItem> alerts,
  ) async {
    final db = _db;
    if (db == null) return;

    await db.transaction(() async {
      final existing = await (db.select(
        db.healthAlerts,
      )..where((t) => t.recordId.equals(record.id))).get();
      final byId = {for (final row in existing) row.id: row};
      final keep = <String>{};
      final now = DateTime.now();

      for (final alert in alerts) {
        keep.add(alert.id);
        final row = byId[alert.id];
        final guidance = jsonEncode(alert.guidance);
        final metric = alert.metric?.name ?? 'unknown';

        if (row == null) {
          await db
              .into(db.healthAlerts)
              .insert(
                HealthAlertsCompanion.insert(
                  id: alert.id,
                  userId: record.userId,
                  recordId: record.id,
                  metric: metric,
                  title: alert.title,
                  summary: alert.summary,
                  severity: alert.severity.name,
                  readingText: Value(alert.readingText),
                  guidance: guidance,
                  systolic: Value(alert.systolic),
                  diastolic: Value(alert.diastolic),
                  heartRate: Value(alert.heartRate),
                  oxygen: Value(alert.oxygen),
                  isUnread: Value(alert.isUnread),
                  createdAt: alert.createdAt,
                  updatedAt: now,
                ),
              );
        } else {
          final contentChanged =
              row.title != alert.title ||
              row.summary != alert.summary ||
              row.severity != alert.severity.name ||
              row.readingText != alert.readingText ||
              row.guidance != guidance;

          await (db.update(
            db.healthAlerts,
          )..where((t) => t.id.equals(alert.id))).write(
            HealthAlertsCompanion(
              metric: Value(metric),
              title: Value(alert.title),
              summary: Value(alert.summary),
              severity: Value(alert.severity.name),
              readingText: Value(alert.readingText),
              guidance: Value(guidance),
              systolic: Value(alert.systolic),
              diastolic: Value(alert.diastolic),
              heartRate: Value(alert.heartRate),
              oxygen: Value(alert.oxygen),
              // A changed reading is a new notification. An unchanged sync
              // keeps the user's read/unread choice.
              isUnread: contentChanged
                  ? const Value(true)
                  : Value(row.isUnread),
              createdAt: contentChanged
                  ? Value(alert.createdAt)
                  : Value(row.createdAt),
              updatedAt: Value(now),
            ),
          );
        }
      }

      for (final row in existing) {
        if (!keep.contains(row.id)) {
          await (db.delete(
            db.healthAlerts,
          )..where((t) => t.id.equals(row.id))).go();
        }
      }
    });
  }

  Future<void> markRead(String id) async {
    final db = _db;
    if (db == null) return;
    await (db.update(db.healthAlerts)..where((t) => t.id.equals(id))).write(
      HealthAlertsCompanion(
        isUnread: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  static AlertItem _fromRow(HealthAlert row) {
    return AlertItem(
      id: row.id,
      title: row.title,
      summary: row.summary,
      severity: _severityFromName(row.severity),
      createdAt: row.createdAt,
      guidance: _decodeGuidance(row.guidance),
      isUnread: row.isUnread,
      metric: _metricFromName(row.metric),
      readingText: row.readingText,
      systolic: row.systolic,
      diastolic: row.diastolic,
      heartRate: row.heartRate,
      oxygen: row.oxygen,
    );
  }

  static AlertSeverity _severityFromName(String name) {
    for (final value in AlertSeverity.values) {
      if (value.name == name) return value;
    }
    return AlertSeverity.info;
  }

  static HealthMetricId? _metricFromName(String name) {
    for (final value in HealthMetricId.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static List<String> _decodeGuidance(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }

  static String _oneDecimal(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}
