import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

class HealthDataRepository {
  HealthDataRepository(this._db);
  final AppDatabase _db;

  Future<DailyHealthRecord?> getTodayRecord(int userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final query = _db.select(_db.dailyHealthRecords)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.recordDate.isBiggerOrEqualValue(start) &
            t.recordDate.isSmallerThanValue(end),
      );
    query
      ..orderBy([
        (t) => OrderingTerm.desc(t.lastUpdated),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1);
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<DailyHealthRecord?> getRecordById(int userId, int recordId) {
    return (_db.select(_db.dailyHealthRecords)
          ..where((t) => t.id.equals(recordId) & t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Stream<DailyHealthRecord?> watchTodayRecord(int userId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final query = _db.select(_db.dailyHealthRecords)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.recordDate.isBiggerOrEqualValue(start) &
            t.recordDate.isSmallerThanValue(end),
      );
    query
      ..orderBy([
        (t) => OrderingTerm.desc(t.lastUpdated),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1);
    return query.watch().map((rows) => rows.isEmpty ? null : rows.first);
  }

  /// The most recent record saved by this user. The Dashboard uses this instead
  /// of "today only" so a restart restores the latest saved reading even when
  /// the last check-in was on an earlier day.
  Future<DailyHealthRecord?> getLatestRecord(int userId) async {
    final rows = await _latestQuery(userId).get();
    return rows.isEmpty ? null : rows.first;
  }

  Stream<DailyHealthRecord?> watchLatestRecord(int userId) {
    return _latestQuery(userId)
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  /// The most recent *completed* check-in. The Dashboard uses this so an
  /// in-progress partial entry never replaces the last finalized snapshot.
  Future<DailyHealthRecord?> getLatestCompletedRecord(int userId) async {
    final rows = await _latestCompletedQuery(userId).get();
    return rows.isEmpty ? null : rows.first;
  }

  Stream<DailyHealthRecord?> watchLatestCompletedRecord(int userId) {
    return _latestCompletedQuery(userId)
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Selectable<DailyHealthRecord> _latestQuery(int userId) {
    return _db.select(_db.dailyHealthRecords)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.recordDate),
        (t) => OrderingTerm.desc(t.lastUpdated),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1);
  }

  Selectable<DailyHealthRecord> _latestCompletedQuery(int userId) {
    return _db.select(_db.dailyHealthRecords)
      ..where((t) => t.userId.equals(userId) & t.completedAt.isNotNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.recordDate),
        (t) => OrderingTerm.desc(t.lastUpdated),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1);
  }

  /// Historical rows for Trends. Results are oldest-first and scoped to one
  /// user, so records can never leak between accounts.
  Future<List<DailyHealthRecord>> getRecords(
    int userId, {
    DateTime? start,
    DateTime? end,
    bool completedOnly = false,
  }) async {
    final query = _db.select(_db.dailyHealthRecords)
      ..where((t) => t.userId.equals(userId));
    if (completedOnly) {
      query.where((t) => t.completedAt.isNotNull());
    }
    if (start != null) {
      query.where((t) => t.recordDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where((t) => t.recordDate.isSmallerThanValue(end));
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.recordDate),
      (t) => OrderingTerm.asc(t.lastUpdated),
      (t) => OrderingTerm.asc(t.id),
    ]);
    return query.get();
  }

  Future<int?> upsertTodayRecord(
    int userId, {
    int? recordId,
    bool createNewRecord = false,
    int? systolic,
    int? diastolic,
    int? heartRate,
    int? oxygenSaturation,
    double? temperature,
    double? sleepHours,
    int? mood,
    String? symptoms,
    String? exercise,
    String? food,
    String? hydration,
    String? measurementContext,
    int? completedSteps,
    bool finalize = false,
  }) async {
    final hasAnyValue =
        systolic != null ||
        diastolic != null ||
        heartRate != null ||
        oxygenSaturation != null ||
        temperature != null ||
        sleepHours != null ||
        mood != null ||
        (symptoms != null && symptoms.isNotEmpty) ||
        (exercise != null && exercise.isNotEmpty) ||
        (food != null && food.isNotEmpty) ||
        (hydration != null && hydration.isNotEmpty);
    if (!hasAnyValue) return null;

    final now = DateTime.now();
    final recordDate = DateTime(now.year, now.month, now.day);

    // A transaction serializes concurrent saves from fast typing, so two
    // inserts for the same user/day cannot race into duplicate records.
    return _db.transaction(() async {
      final latestToday = await getTodayRecord(userId);
      final nowMillis = now.millisecondsSinceEpoch;
      final latestMillis = latestToday?.lastUpdated.millisecondsSinceEpoch;
      final savedAt = latestMillis != null && nowMillis <= latestMillis
          ? DateTime.fromMillisecondsSinceEpoch(latestMillis + 1)
          : DateTime.fromMillisecondsSinceEpoch(nowMillis);
      final existing = recordId == null
          ? (createNewRecord ? null : await getTodayRecord(userId))
          : await (_db.select(_db.dailyHealthRecords)..where(
                  (t) => t.id.equals(recordId) & t.userId.equals(userId),
                ))
                .getSingleOrNull();
      if (existing == null) {
        return _db
            .into(_db.dailyHealthRecords)
            .insert(
              DailyHealthRecordsCompanion.insert(
                userId: userId,
                recordDate: recordDate,
                systolic: Value(systolic),
                diastolic: Value(diastolic),
                heartRate: Value(heartRate),
                oxygenSaturation: Value(oxygenSaturation),
                temperature: Value(temperature),
                sleepHours: Value(sleepHours),
                mood: Value(mood),
                symptoms: Value(symptoms),
                exercise: Value(exercise),
                food: Value(food),
                hydration: Value(hydration),
                measurementContext: Value(measurementContext),
                completedSteps: Value(completedSteps ?? 0),
                completedAt: finalize
                    ? Value(savedAt)
                    : const Value<DateTime?>(null),
                lastUpdated: savedAt,
              ),
            );
      } else {
        await (_db.update(
          _db.dailyHealthRecords,
        )..where((t) => t.id.equals(existing.id))).write(
          DailyHealthRecordsCompanion(
            systolic: Value(systolic ?? existing.systolic),
            diastolic: Value(diastolic ?? existing.diastolic),
            heartRate: Value(heartRate ?? existing.heartRate),
            oxygenSaturation: Value(
              oxygenSaturation ?? existing.oxygenSaturation,
            ),
            temperature: Value(temperature ?? existing.temperature),
            sleepHours: Value(sleepHours ?? existing.sleepHours),
            mood: Value(mood ?? existing.mood),
            symptoms: Value(symptoms ?? existing.symptoms),
            exercise: Value(exercise ?? existing.exercise),
            food: Value(food ?? existing.food),
            hydration: Value(hydration ?? existing.hydration),
            measurementContext: Value(
              measurementContext ?? existing.measurementContext,
            ),
            completedSteps: Value(completedSteps ?? existing.completedSteps),
            // Any edit re-opens the check-in; the final button must be pressed
            // again before alerts are regenerated.
            completedAt: finalize
                ? Value(savedAt)
                : const Value<DateTime?>(null),
            lastUpdated: Value(savedAt),
          ),
        );
        return existing.id;
      }
    });
  }
}
