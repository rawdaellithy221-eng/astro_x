import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrox/core/database/app_database.dart';
import 'package:astrox/data/repositories/health_data_repository.dart';

void main() {
  late Directory directory;
  late File databaseFile;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('astrox_persistence_');
    databaseFile = File(
      '${directory.path}${Platform.pathSeparator}astrox.sqlite',
    );
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('saved readings survive closing and reopening the database', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Persistence User');

    await repository.upsertTodayRecord(
      userId,
      systolic: 118,
      diastolic: 76,
      heartRate: 72,
      temperature: 36.6,
      sleepHours: 7.5,
      mood: 4,
      exercise: '30',
      measurementContext: 'resting',
    );
    await db.close();

    final reopened = AppDatabase(connection: NativeDatabase(databaseFile));
    final reopenedRepository = HealthDataRepository(reopened);
    final record = await reopenedRepository.getLatestRecord(userId);

    expect(record, isNotNull);
    expect(record!.heartRate, 72);
    expect(record.systolic, 118);
    expect(record.diastolic, 76);
    expect(record.temperature, 36.6);
    expect(record.sleepHours, 7.5);
    expect(record.mood, 4);
    expect(record.exercise, '30');
    expect(record.measurementContext, 'resting');

    final history = await reopenedRepository.getRecords(userId);
    expect(history, hasLength(1));

    await reopened.close();
  });

  test('updating today keeps one row and preserves omitted fields', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Update User');

    await repository.upsertTodayRecord(
      userId,
      systolic: 118,
      diastolic: 76,
      heartRate: 72,
    );
    await repository.upsertTodayRecord(userId, heartRate: 80);

    final history = await repository.getRecords(userId);
    expect(history, hasLength(1));
    expect(history.single.heartRate, 80);
    expect(history.single.systolic, 118);
    expect(history.single.diastolic, 76);

    await db.close();
  });

  test('latest record and history never leak between users', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final firstUser = await _insertUser(db, 'First User');
    final secondUser = await _insertUser(db, 'Second User');

    await repository.upsertTodayRecord(firstUser, heartRate: 61);
    await repository.upsertTodayRecord(secondUser, heartRate: 92);

    expect((await repository.getLatestRecord(firstUser))!.heartRate, 61);
    expect((await repository.getLatestRecord(secondUser))!.heartRate, 92);
    expect(await repository.getRecords(firstUser), hasLength(1));
    expect(await repository.getRecords(secondUser), hasLength(1));

    await db.close();
  });

  test('latest record is the newest day, not only today', () async {
    final db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'History User');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: yesterday,
            heartRate: const Value(60),
            lastUpdated: yesterday,
          ),
        );
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: today,
            heartRate: const Value(75),
            lastUpdated: now,
          ),
        );

    expect((await repository.getLatestRecord(userId))!.heartRate, 75);

    final lastSevenDays = await repository.getRecords(
      userId,
      start: today.subtract(const Duration(days: 6)),
    );
    expect(lastSevenDays.map((row) => row.heartRate), [60, 75]);

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
