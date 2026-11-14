import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrox/core/database/app_database.dart';
import 'package:astrox/core/helper/health_status_helper.dart';
import 'package:astrox/data/models/health_metric_id.dart';
import 'package:astrox/data/models/health_status.dart';
import 'package:astrox/data/repositories/alert_repository.dart';
import 'package:astrox/data/repositories/health_data_repository.dart';
import 'package:astrox/features/alerts/cubit/alerts_cubit.dart';
import 'package:astrox/features/daily_check_in/cubit/daily_check_in_cubit.dart';
import 'package:astrox/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:astrox/features/trends/cubit/trends_cubit.dart';

void main() {
  late Directory directory;
  late File databaseFile;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('astrox_flow_');
    databaseFile = File(
      '${directory.path}${Platform.pathSeparator}astrox.sqlite',
    );
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test(
    'new check-in is empty while explicit edits restore saved values',
    () async {
      final db = AppDatabase(connection: NativeDatabase(databaseFile));
      final repository = HealthDataRepository(db);
      final userId = await _insertUser(db, 'Check-in User');

      final cubit = DailyCheckInCubit(
        healthRepository: repository,
        userId: userId,
      );
      await cubit.load();
      expect(cubit.state.loading, isFalse);

      cubit.setValue('bp_sys', '118');
      cubit.setValue('bp_dia', '76');
      cubit.setValue(HealthMetricId.heartRate.name, '72');
      cubit.setValue(HealthMetricId.temperature.name, '36.6');
      cubit.setValue(HealthMetricId.sleep.name, '7.5');
      cubit.setValue(HealthMetricId.mood.name, '4');
      cubit.setValue(HealthMetricId.exercise.name, '30');
      cubit.setValue('context', 'resting');

      while (!cubit.state.finished) {
        await cubit.next();
      }

      final saved = await repository.getTodayRecord(userId);
      expect(saved, isNotNull);
      expect(saved!.systolic, 118);
      expect(saved.diastolic, 76);
      expect(saved.heartRate, 72);
      expect(saved.temperature, 36.6);
      expect(saved.sleepHours, 7.5);
      expect(saved.mood, 4);
      expect(saved.exercise, '30');
      expect(saved.measurementContext, 'resting');
      await cubit.close();
      await db.close();

      final reopened = AppDatabase(connection: NativeDatabase(databaseFile));
      final reopenedRepository = HealthDataRepository(reopened);
      final savedRecord = await reopenedRepository.getLatestRecord(userId);
      expect(savedRecord, isNotNull);
      final reloaded = DailyCheckInCubit(
        healthRepository: reopenedRepository,
        userId: userId,
      );
      await reloaded.load();

      expect(reloaded.state.values, isEmpty);

      final editCubit = DailyCheckInCubit(
        healthRepository: reopenedRepository,
        userId: userId,
        recordId: savedRecord!.id,
      );
      await editCubit.load();

      expect(editCubit.state.values['bp_sys'], '118');
      expect(editCubit.state.values['bp_dia'], '76');
      expect(editCubit.state.values['heartRate'], '72');
      expect(editCubit.state.values['temperature'], '36.6');
      expect(editCubit.state.values['sleep'], '7.5');
      expect(editCubit.state.values['mood'], '4');
      expect(editCubit.state.values['exercise'], '30');
      expect(editCubit.state.values['context'], 'resting');

      await reloaded.close();
      await editCubit.close();
      await reopened.close();
    },
  );

  test('partial check-in saves only available values', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Partial User');

    final cubit = DailyCheckInCubit(
      healthRepository: repository,
      userId: userId,
    );
    await cubit.load();
    cubit.setValue(HealthMetricId.heartRate.name, '81');
    while (!cubit.state.finished) {
      await cubit.next();
    }

    final saved = await repository.getTodayRecord(userId);
    expect(saved, isNotNull);
    expect(saved!.heartRate, 81);
    expect(saved.systolic, isNull);
    expect(saved.diastolic, isNull);
    expect(saved.temperature, isNull);
    expect(saved.sleepHours, isNull);
    expect(saved.mood, isNull);

    await cubit.close();
    await db.close();
  });

  test(
    'starting a new check-in preserves the earlier same-day record',
    () async {
      final db = AppDatabase(connection: NativeDatabase(databaseFile));
      final repository = HealthDataRepository(db);
      final userId = await _insertUser(db, 'Repeat Check-in User');
      await repository.upsertTodayRecord(userId, heartRate: 64, finalize: true);

      final cubit = DailyCheckInCubit(
        healthRepository: repository,
        userId: userId,
      );
      await cubit.load();
      expect(cubit.state.values, isEmpty);
      cubit.setValue(HealthMetricId.heartRate.name, '88');
      while (!cubit.state.finished) {
        await cubit.next();
      }

      final history = await repository.getRecords(userId);
      expect(history, hasLength(2));
      expect(history.map((record) => record.heartRate), containsAll([64, 88]));
      expect(
        (await repository.getLatestCompletedRecord(userId))!.heartRate,
        88,
      );

      await cubit.close();
      await db.close();
    },
  );

  test('abnormal but plausible readings are accepted and classified', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Abnormal User');

    final cubit = DailyCheckInCubit(
      healthRepository: repository,
      userId: userId,
    );
    await cubit.load();

    cubit.setValue('bp_sys', '200');
    cubit.setValue('bp_dia', '120');
    cubit.setValue(HealthMetricId.heartRate.name, '140');
    cubit.setValue(HealthMetricId.temperature.name, '50');
    cubit.setValue(HealthMetricId.sleep.name, '24');
    cubit.setValue(HealthMetricId.mood.name, '1');
    cubit.setValue(HealthMetricId.exercise.name, '1440');

    while (!cubit.state.finished) {
      await cubit.next();
      expect(cubit.state.error, isNull);
    }

    final saved = await repository.getTodayRecord(userId);
    expect(saved, isNotNull);
    expect(saved!.systolic, 200);
    expect(saved.diastolic, 120);
    expect(saved.heartRate, 140);
    expect(saved.temperature, 50);
    expect(saved.sleepHours, 24);
    expect(saved.mood, 1);
    expect(saved.exercise, '1440');
    expect(saved.completedAt, isNotNull);

    expect(
      HealthStatusHelper.statusForMetric(
        HealthMetricId.temperature,
        doubleValue: saved.temperature,
      ),
      HealthStatus.critical,
    );
    expect(
      HealthStatusHelper.statusForMetric(
        HealthMetricId.bloodPressure,
        systolic: saved.systolic,
        diastolic: saved.diastolic,
      ),
      HealthStatus.critical,
    );

    await cubit.close();
    await db.close();
  });

  test('impossible and non-numeric readings are rejected', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Invalid User');

    final cubit = DailyCheckInCubit(
      healthRepository: repository,
      userId: userId,
    );
    await cubit.load();
    cubit.setValue(HealthMetricId.heartRate.name, '70');
    cubit.setValue(HealthMetricId.temperature.name, '100');
    await cubit.next();

    expect(cubit.state.error, 'Enter a valid temperature.');
    expect(cubit.state.finished, isFalse);

    cubit.setValue('bp_sys', '80');
    cubit.setValue('bp_dia', '120');
    cubit.setValue(HealthMetricId.temperature.name, '36.6');
    await cubit.next();

    expect(cubit.state.error, contains('higher than diastolic'));

    final saved = await repository.getTodayRecord(userId);
    expect(saved?.heartRate, 70);
    expect(saved?.temperature, 36.6);
    // The impossible pair is not persisted while the check-in is incomplete.
    expect(saved?.systolic, isNull);
    expect(saved?.diastolic, isNull);

    await cubit.close();
    await db.close();
  });

  test(
    'invalid blood pressure blocks finishing and does not overwrite data',
    () async {
      final db = AppDatabase(connection: NativeDatabase(databaseFile));
      final repository = HealthDataRepository(db);
      final userId = await _insertUser(db, 'Validation User');

      final cubit = DailyCheckInCubit(
        healthRepository: repository,
        userId: userId,
      );
      await cubit.load();
      cubit.setValue(HealthMetricId.heartRate.name, '70');
      cubit.setValue('bp_sys', '120');

      await cubit.next();

      expect(cubit.state.error, isNotNull);
      expect(cubit.state.currentIndex, 0);
      // The valid systolic value was preserved as partial progress, but the
      // incomplete pair cannot finish the check-in.
      final saved = await repository.getTodayRecord(userId);
      expect(saved?.systolic, 120);
      expect(saved?.diastolic, isNull);

      await cubit.close();
      await db.close();
    },
  );

  test('dashboard reloads the latest saved record after a restart', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Dashboard User');
    await repository.upsertTodayRecord(
      userId,
      systolic: 122,
      diastolic: 78,
      heartRate: 68,
      sleepHours: 7.5,
      mood: 4,
      finalize: true,
    );

    final firstCubit = DashboardCubit(repository: repository, userId: userId);
    final firstState = firstCubit.stream.firstWhere(
      (state) => !state.loading && state.snapshot != null,
    );
    firstCubit.load();
    final dashboard = await firstState;
    expect(dashboard.snapshot, isNotNull);
    expect(
      dashboard.snapshot!.metrics
          .firstWhere((m) => m.metric == HealthMetricId.heartRate)
          .value,
      68,
    );
    expect(dashboard.healthScore?.overall, isNotNull);
    await firstCubit.close();
    await db.close();

    final reopened = AppDatabase(connection: NativeDatabase(databaseFile));
    final reopenedRepository = HealthDataRepository(reopened);
    final restartedCubit = DashboardCubit(
      repository: reopenedRepository,
      userId: userId,
    );
    final restartedState = restartedCubit.stream.firstWhere(
      (state) => !state.loading && state.snapshot != null,
    );
    restartedCubit.load();
    final restarted = await restartedState;

    expect(
      restarted.snapshot!.metrics
          .firstWhere((m) => m.metric == HealthMetricId.heartRate)
          .value,
      68,
    );
    expect(restarted.snapshot!.bloodPressure?.systolic, 122);
    expect(restarted.healthScore?.overall, dashboard.healthScore?.overall);
    await restartedCubit.close();
    await reopened.close();
  });

  test('dashboard ignores an in-progress partial check-in', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Completed Dashboard User');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: yesterday,
            heartRate: const Value(64),
            completedAt: Value(yesterday),
            lastUpdated: yesterday,
          ),
        );
    await repository.upsertTodayRecord(userId, heartRate: 145);

    final partial = await repository.getTodayRecord(userId);
    expect(partial?.completedAt, isNull);

    final cubit = DashboardCubit(repository: repository, userId: userId);
    final stateFuture = cubit.stream.firstWhere(
      (state) => !state.loading && state.snapshot != null,
    );
    cubit.load();
    final state = await stateFuture;

    final heartRate = state.snapshot!.metrics.firstWhere(
      (metric) => metric.metric == HealthMetricId.heartRate,
    );
    expect(heartRate.value, 64);
    expect(state.alerts, isEmpty);

    await cubit.close();
    await db.close();
  });

  test('alerts wait for completion, persist, and never duplicate', () async {
    var db = AppDatabase(connection: NativeDatabase(databaseFile));
    var repository = HealthDataRepository(db);
    var alertRepository = AlertRepository(db);
    final userId = await _insertUser(db, 'Alerts User');

    await repository.upsertTodayRecord(userId, heartRate: 140);
    final partial = await repository.getTodayRecord(userId);
    expect(partial?.completedAt, isNull);

    final cubit = AlertsCubit(
      repository: alertRepository,
      healthRepository: repository,
    );
    final partialStateFuture = cubit.stream.firstWhere(
      (state) => !state.loading,
    );
    final completedStateFuture = cubit.stream.firstWhere(
      (state) => !state.loading && state.alerts.isNotEmpty,
    );
    cubit.bind(userId);

    final partialState = await partialStateFuture;
    expect(partialState.alerts, isEmpty);

    await repository.upsertTodayRecord(userId, heartRate: 140, finalize: true);
    final completedState = await completedStateFuture;

    expect(completedState.alerts, hasLength(1));
    expect(completedState.alerts.first.metric, HealthMetricId.heartRate);
    expect(completedState.alerts.first.readingText, '140 bpm');

    final savedRecord = await repository.getTodayRecord(userId);
    expect(savedRecord?.completedAt, isNotNull);

    // Re-syncing the same finalized record does not create a duplicate.
    await alertRepository.syncForRecord(savedRecord!);
    final stored = await alertRepository.watchForRecord(savedRecord.id).first;
    expect(stored, hasLength(1));

    await cubit.markRead(stored.first.id);
    expect(cubit.state.alerts.first.isUnread, isFalse);

    await cubit.close();
    await db.close();

    // Reopen the database: the alert and its read state survive.
    db = AppDatabase(connection: NativeDatabase(databaseFile));
    repository = HealthDataRepository(db);
    alertRepository = AlertRepository(db);
    final reopenedCubit = AlertsCubit(
      repository: alertRepository,
      healthRepository: repository,
    );
    final reopenedStateFuture = reopenedCubit.stream.firstWhere(
      (state) => !state.loading && state.alerts.isNotEmpty,
    );
    reopenedCubit.bind(userId);
    final reopenedState = await reopenedStateFuture;

    expect(reopenedState.alerts, hasLength(1));
    expect(reopenedState.alerts.first.isUnread, isFalse);

    await reopenedCubit.close();
    await db.close();
  });

  test('trends reads real SQLite history instead of mock series', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Trends User');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final fortyDaysAgo = today.subtract(const Duration(days: 40));
    final tomorrow = today.add(const Duration(days: 1));

    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: fortyDaysAgo,
            heartRate: const Value(50),
            completedAt: Value(fortyDaysAgo),
            lastUpdated: fortyDaysAgo,
          ),
        );
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: yesterday,
            heartRate: const Value(62),
            completedAt: Value(yesterday),
            lastUpdated: yesterday,
          ),
        );
    await repository.upsertTodayRecord(userId, heartRate: 70, finalize: true);
    await repository.upsertTodayRecord(
      userId,
      heartRate: 75,
      systolic: 130,
      diastolic: 80,
      createNewRecord: true,
      finalize: true,
    );
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: tomorrow,
            heartRate: const Value(99),
            completedAt: Value(tomorrow),
            lastUpdated: tomorrow,
          ),
        );

    final cubit = TrendsCubit(
      healthRepository: repository,
      userId: userId,
      initialMetric: HealthMetricId.heartRate,
    );
    final state = await cubit.stream.firstWhere((state) => !state.loading);

    expect(state.points, hasLength(3));
    expect(state.points.map((p) => p.value), [62, 70, 75]);
    expect(state.records, hasLength(3));

    final thirtyDays = cubit.stream.firstWhere(
      (next) => !next.loading && next.range == TrendRange.days30,
    );
    cubit.selectRange(TrendRange.days30);
    expect((await thirtyDays).points.map((p) => p.value), [62, 70, 75]);

    final wholeMission = cubit.stream.firstWhere(
      (next) => !next.loading && next.range == TrendRange.wholeMission,
    );
    cubit.selectRange(TrendRange.wholeMission);
    final wholeMissionState = await wholeMission;
    expect(wholeMissionState.points.map((p) => p.value), [50, 62, 70, 75]);

    final pressureTrend = cubit.stream.firstWhere(
      (next) => !next.loading && next.metric == HealthMetricId.bloodPressure,
    );
    cubit.selectMetric(HealthMetricId.bloodPressure);
    final pressureState = await pressureTrend;
    expect(pressureState.points, hasLength(1));
    expect(pressureState.points.single.value, 130);
    expect(pressureState.points.single.secondaryValue, 80);

    expect(state.availableMetrics, contains(HealthMetricId.oxygen));
    expect(state.availableMetrics, isNot(contains(HealthMetricId.weight)));
    cubit.selectMetric(HealthMetricId.weight);
    expect(cubit.state.metric, HealthMetricId.bloodPressure);

    await cubit.close();
    await db.close();
  });
}

Future<int> _insertUser(AppDatabase db, String username) {
  return db
      .into(db.users)
      .insert(
        UsersCompanion.insert(
          username: username,
          astronautId: Value(username.toUpperCase().replaceAll(' ', '-')),
          createdAt: DateTime.now(),
        ),
      );
}
