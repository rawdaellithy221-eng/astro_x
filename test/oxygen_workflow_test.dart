import 'dart:io';

import 'package:astrox/core/database/app_database.dart';
import 'package:astrox/core/helper/health_input_validator.dart';
import 'package:astrox/data/models/health_metric_id.dart';
import 'package:astrox/data/models/health_status.dart';
import 'package:astrox/data/models/time_series_point.dart';
import 'package:astrox/data/repositories/health_data_repository.dart';
import 'package:astrox/core/widgets/charts/line_chart_widget.dart';
import 'package:astrox/features/daily_check_in/cubit/daily_check_in_cubit.dart';
import 'package:astrox/features/daily_check_in/view/daily_check_in_screen.dart';
import 'package:astrox/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:astrox/features/trends/cubit/trends_cubit.dart';
import 'package:astrox/features/user/cubit/user_cubit.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  late Directory directory;
  late File databaseFile;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('astrox_oxygen_');
    databaseFile = File('${directory.path}${Platform.pathSeparator}astrox.db');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('check-in saves oxygen, dashboard classifies it, and reopening preserves it', () async {
    var db = AppDatabase(connection: NativeDatabase(databaseFile));
    final repository = HealthDataRepository(db);
    final userId = await _insertUser(db, 'Oxygen Crew', 'AST-O2');
    final otherUserId = await _insertUser(db, 'Other Crew', 'AST-OTHER');
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final fortyDaysAgo = DateTime.now().subtract(const Duration(days: 40));
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: DateTime(
              fortyDaysAgo.year,
              fortyDaysAgo.month,
              fortyDaysAgo.day,
            ),
            oxygenSaturation: const Value(91),
            completedAt: Value(fortyDaysAgo),
            lastUpdated: fortyDaysAgo,
          ),
        );
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: DateTime(
              yesterday.year,
              yesterday.month,
              yesterday.day,
            ),
            oxygenSaturation: const Value(93),
            completedAt: Value(yesterday),
            lastUpdated: yesterday,
          ),
        );

    final checkIn = DailyCheckInCubit(
      healthRepository: repository,
      userId: userId,
    );
    await checkIn.load();
    await checkIn.next(); // Blood pressure
    await checkIn.next(); // Heart rate
    await checkIn.next(); // Temperature
    expect(checkIn.state.currentStep?.metric, HealthMetricId.oxygen);
    checkIn.setValue(HealthMetricId.oxygen.name, '88');
    await checkIn.skip(); // Save oxygen, then move to sleep.

    final partial = await repository.getTodayRecord(userId);
    expect(partial?.oxygenSaturation, 88);
    expect(partial?.completedAt, isNull);

    await checkIn.skip(); // Sleep
    await checkIn.skip(); // Mood
    checkIn.setValue(HealthMetricId.exercise.name, '30');
    await checkIn.next(); // Finalize check-in.
    expect(checkIn.state.finished, isTrue);
    final completed = await repository.getTodayRecord(userId);
    expect(completed?.oxygenSaturation, 88);
    expect(completed?.completedAt, isNotNull);
    await db
        .into(db.dailyHealthRecords)
        .insert(
          DailyHealthRecordsCompanion.insert(
            userId: userId,
            recordDate: DateTime.now(),
            oxygenSaturation: const Value(74),
            lastUpdated: DateTime.now(),
          ),
        );

    final dashboard = DashboardCubit(repository: repository, userId: userId);
    final dashboardState = dashboard.stream.firstWhere(
      (state) => !state.loading && state.snapshot != null,
    );
    dashboard.load();
    final dashboardResult = await dashboardState;
    final oxygenReading = dashboardResult.snapshot!.metrics.singleWhere(
      (reading) => reading.metric == HealthMetricId.oxygen,
    );
    expect(oxygenReading.value, 88);
    expect(oxygenReading.status, HealthStatus.critical);

    final trends = TrendsCubit(
      healthRepository: repository,
      userId: userId,
      initialMetric: HealthMetricId.oxygen,
    );
    final sevenDayState = await trends.stream.firstWhere((s) => !s.loading);
    expect(sevenDayState.points.map((point) => point.value), [93, 88]);
    expect(
      sevenDayState.availableMetrics,
      isNot(contains(HealthMetricId.weight)),
    );
    expect(sevenDayState.availableMetrics, contains(HealthMetricId.oxygen));
    final thirtyDayResult = trends.stream.firstWhere(
      (s) => !s.loading && s.range == TrendRange.days30,
    );
    trends.selectRange(TrendRange.days30);
    expect((await thirtyDayResult).points.map((point) => point.value), [
      93,
      88,
    ]);
    final missionResult = trends.stream.firstWhere(
      (s) => !s.loading && s.range == TrendRange.wholeMission,
    );
    trends.selectRange(TrendRange.wholeMission);
    expect((await missionResult).points.map((point) => point.value), [
      91,
      93,
      88,
    ]);

    final otherTrends = TrendsCubit(
      healthRepository: repository,
      userId: otherUserId,
      initialMetric: HealthMetricId.oxygen,
    );
    final otherState = await otherTrends.stream.firstWhere((s) => !s.loading);
    expect(otherState.points, isEmpty);

    await checkIn.close();
    await dashboard.close();
    await trends.close();
    await otherTrends.close();
    await db.close();

    db = AppDatabase(connection: NativeDatabase(databaseFile));
    final reopenedRepository = HealthDataRepository(db);
    final reopened = await reopenedRepository.getLatestCompletedRecord(userId);
    expect(reopened?.oxygenSaturation, 88);
    expect(await reopenedRepository.getRecords(otherUserId), isEmpty);
    await db.close();
  });

  test(
    'schema already includes oxygen_saturation without a new migration',
    () async {
      final database = AppDatabase(connection: NativeDatabase.memory());
      expect(database.schemaVersion, 4);
      expect(
        database.dailyHealthRecords.oxygenSaturation.name,
        'oxygen_saturation',
      );
      await database.close();
    },
  );

  test('oxygen technical validation accepts abnormal values within 0–100', () {
    int? parse(String value) => HealthInputValidator.parseInt(
      value,
      min: HealthInputValidator.oxygenMin,
      max: HealthInputValidator.oxygenMax,
      label: 'oxygen saturation percentage',
      validate: true,
    );

    expect(parse('88'), 88);
    expect(parse('0'), 0);
    expect(() => parse('101'), throwsFormatException);
    expect(() => parse('not a number'), throwsFormatException);
  });

  testWidgets('Oxygen chart renders each reading as a visible point', (
    tester,
  ) async {
    final chartPoints = [
      TimeSeriesPoint(date: DateTime(2026, 11, 10), value: 97),
      TimeSeriesPoint(date: DateTime(2026, 11, 11), value: 97),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LineChartWidget(
            points: chartPoints,
            unit: '%',
            baselineMin: 95,
            baselineMax: 100,
            showPoints: true,
          ),
        ),
      ),
    );

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData.first.spots, hasLength(2));
    expect(chart.data.lineBarsData.first.spots.map((spot) => spot.y), [97, 97]);
    expect(chart.data.lineBarsData.first.dotData.show, isTrue);
    expect(chart.data.extraLinesData.horizontalLines, hasLength(2));
  });

  testWidgets('oxygen input and illustration fit desktop and tablet layouts', (
    tester,
  ) async {
    final db = AppDatabase(connection: NativeDatabase.memory());
    final userCubit = UserCubit(database: db);
    await userCubit.register('Layout Crew', 'AST-LAYOUT');
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await userCubit.close();
      await db.close();
    });

    for (final size in [const Size(1280, 900), const Size(720, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        BlocProvider<UserCubit>.value(
          value: userCubit,
          child: RepositoryProvider<AppDatabase>.value(
            value: db,
            child: MaterialApp(
              home: Scaffold(
                body: DailyCheckInScreen(key: ValueKey(size.width)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        final nextButton = find.text('Save and next');
        await tester.ensureVisible(nextButton);
        await tester.pumpAndSettle();
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
      expect(find.text('Oxygen saturation (SpO₂)'), findsWidgets);
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .any((field) => field.decoration?.suffixText == '%'),
        isTrue,
      );
      expect(find.byType(SvgPicture), findsWidgets);
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<int> _insertUser(AppDatabase db, String username, String astronautId) {
  return db
      .into(db.users)
      .insert(
        UsersCompanion.insert(
          username: username,
          astronautId: Value(astronautId),
          createdAt: DateTime.now(),
        ),
      );
}
