import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:astrox/core/database/app_database.dart';
import 'package:astrox/data/repositories/health_data_repository.dart';
import 'package:astrox/data/repositories/user_repository.dart';
import 'package:astrox/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:astrox/features/trends/cubit/trends_cubit.dart';

void main() {
  late Directory directory;
  late File databaseFile;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('astrox_users_');
    databaseFile = File('${directory.path}${Platform.pathSeparator}astrox.db');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('Astronaut IDs reuse profiles and keep health data isolated', () async {
    var db = AppDatabase(connection: NativeDatabase(databaseFile));
    var users = UserRepository(db);
    var health = HealthDataRepository(db);

    final first = await users.findOrCreate(
      username: 'First Crew Member',
      astronautId: ' ast-001 ',
    );
    final repeated = await users.findOrCreate(
      username: 'Changed Name',
      astronautId: 'AST-001',
    );
    final second = await users.findOrCreate(
      username: 'Second Crew Member',
      astronautId: 'AST-002',
    );

    expect(repeated.id, first.id);
    expect(repeated.username, 'First Crew Member');
    expect(second.id, isNot(first.id));
    expect(await health.getLatestCompletedRecord(second.id), isNull);

    final dashboardCubit = DashboardCubit(
      repository: health,
      userId: second.id,
    );
    final emptyDashboard = dashboardCubit.stream.firstWhere(
      (state) => !state.loading && state.snapshot != null,
    );
    dashboardCubit.load();
    final emptyState = await emptyDashboard;
    expect(emptyState.snapshot!.metrics, isEmpty);
    expect(emptyState.healthScore?.overall, isNull);
    await dashboardCubit.close();

    final emptyTrendsCubit = TrendsCubit(
      healthRepository: health,
      userId: second.id,
    );
    final emptyTrends = await emptyTrendsCubit.stream.firstWhere(
      (state) => !state.loading,
    );
    expect(emptyTrends.records, isEmpty);
    expect(emptyTrends.points, isEmpty);
    await emptyTrendsCubit.close();

    await health.upsertTodayRecord(first.id, heartRate: 64, finalize: true);
    await health.upsertTodayRecord(second.id, heartRate: 88, finalize: true);
    expect((await health.getLatestCompletedRecord(first.id))!.heartRate, 64);
    expect((await health.getLatestCompletedRecord(second.id))!.heartRate, 88);

    final firstTrendsCubit = TrendsCubit(
      healthRepository: health,
      userId: first.id,
    );
    final firstTrends = await firstTrendsCubit.stream.firstWhere(
      (state) => !state.loading,
    );
    final secondTrendsCubit = TrendsCubit(
      healthRepository: health,
      userId: second.id,
    );
    final secondTrends = await secondTrendsCubit.stream.firstWhere(
      (state) => !state.loading,
    );
    expect(firstTrends.points.map((point) => point.value), [64]);
    expect(secondTrends.points.map((point) => point.value), [88]);
    await firstTrendsCubit.close();
    await secondTrendsCubit.close();
    await db.close();

    db = AppDatabase(connection: NativeDatabase(databaseFile));
    users = UserRepository(db);
    health = HealthDataRepository(db);
    final reopenedFirst = await users.findOrCreate(
      username: 'Ignored Name',
      astronautId: 'AST-001',
    );
    expect(reopenedFirst.id, first.id);
    expect((await health.getLatestCompletedRecord(first.id))!.heartRate, 64);
    expect((await health.getLatestCompletedRecord(second.id))!.heartRate, 88);
    expect(await health.getRecords(first.id), hasLength(1));
    expect(await health.getRecords(second.id), hasLength(1));
    await db.close();
  });

  test('v3 duplicate profiles migrate without losing health records', () async {
    var db = AppDatabase(connection: NativeDatabase(databaseFile));
    await db.customStatement('DROP INDEX users_astronaut_id_unique');
    final firstId = await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            username: 'Original',
            astronautId: const Value('AST-DUP'),
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    final duplicateId = await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            username: 'Duplicate',
            astronautId: const Value(' ast-dup '),
            createdAt: DateTime(2026, 1, 2),
          ),
        );
    final health = HealthDataRepository(db);
    await health.upsertTodayRecord(firstId, heartRate: 64);
    await health.upsertTodayRecord(duplicateId, heartRate: 88);
    await db.customStatement('PRAGMA user_version = 3');
    await db.close();

    db = AppDatabase(connection: NativeDatabase(databaseFile));
    final profiles = await db.select(db.users).get();
    final records = await db.select(db.dailyHealthRecords).get();
    expect(profiles, hasLength(1));
    expect(profiles.single.id, firstId);
    expect(records, hasLength(2));
    expect(records.map((record) => record.userId).toSet(), {firstId});
    expect(records.map((record) => record.heartRate), containsAll([64, 88]));
    await db.close();
  });
}
