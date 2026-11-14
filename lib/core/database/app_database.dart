import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get astronautId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class DailyHealthRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get recordDate => dateTime()();
  IntColumn get systolic => integer().nullable()();
  IntColumn get diastolic => integer().nullable()();
  IntColumn get heartRate => integer().nullable()();
  IntColumn get oxygenSaturation => integer().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get sleepHours => real().nullable()();
  IntColumn get mood => integer().nullable()();
  TextColumn get symptoms => text().nullable()();
  TextColumn get exercise => text().nullable()();
  TextColumn get food => text().nullable()();
  TextColumn get hydration => text().nullable()();
  TextColumn get measurementContext => text().nullable()();
  IntColumn get completedSteps => integer().withDefault(const Constant(0))();

  /// Set only when the user presses the final completion button. Partial
  /// saves keep this null so alerts are not generated while the check-in is
  /// still in progress.
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get lastUpdated => dateTime()();
}

/// Final alerts generated from one completed daily record.
///
/// The deterministic [id] (record + metric) is the duplicate guard: syncing the
/// same completed record again updates the existing row instead of creating a
/// second notification.
class HealthAlerts extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get recordId => integer().references(DailyHealthRecords, #id)();
  TextColumn get metric => text()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get severity => text()();
  TextColumn get readingText => text().nullable()();
  TextColumn get guidance => text()();
  IntColumn get systolic => integer().nullable()();
  IntColumn get diastolic => integer().nullable()();
  IntColumn get heartRate => integer().nullable()();
  IntColumn get oxygen => integer().nullable()();
  BoolColumn get isUnread => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, DailyHealthRecords, HealthAlerts])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? connection})
    : super(connection ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await m.database.customStatement(
        'CREATE UNIQUE INDEX users_astronaut_id_unique '
        'ON users(lower(trim(astronaut_id))) '
        'WHERE astronaut_id IS NOT NULL AND length(trim(astronaut_id)) > 0',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(
          dailyHealthRecords,
          dailyHealthRecords.measurementContext,
        );
      }
      if (from < 3) {
        await m.addColumn(dailyHealthRecords, dailyHealthRecords.completedAt);
        await m.createTable(healthAlerts);
        // Records written before this migration had no completion marker.
        // Treat them as completed so existing Dashboard data and alerts are
        // preserved after the upgrade.
        await m.database.customStatement(
          'UPDATE daily_health_records '
          'SET completed_at = last_updated '
          'WHERE completed_at IS NULL',
        );
      }
      if (from < 4) {
        // Older builds could create the same profile more than once. Move
        // every dependent record to the oldest profile for that ID before
        // removing duplicate profile rows; no health or alert rows are lost.
        await m.database.customStatement('''
          UPDATE daily_health_records
          SET user_id = (
            SELECT MIN(owner.id) FROM users AS owner
            WHERE lower(trim(owner.astronaut_id)) = (
              SELECT lower(trim(duplicate.astronaut_id))
              FROM users AS duplicate
              WHERE duplicate.id = daily_health_records.user_id
            )
          )
          WHERE user_id IN (
            SELECT duplicate.id FROM users AS duplicate
            WHERE duplicate.astronaut_id IS NOT NULL
              AND length(trim(duplicate.astronaut_id)) > 0
              AND duplicate.id <> (
                SELECT MIN(owner.id) FROM users AS owner
                WHERE lower(trim(owner.astronaut_id)) =
                  lower(trim(duplicate.astronaut_id))
              )
          )
        ''');
        await m.database.customStatement('''
          UPDATE health_alerts
          SET user_id = (
            SELECT MIN(owner.id) FROM users AS owner
            WHERE lower(trim(owner.astronaut_id)) = (
              SELECT lower(trim(duplicate.astronaut_id))
              FROM users AS duplicate
              WHERE duplicate.id = health_alerts.user_id
            )
          )
          WHERE user_id IN (
            SELECT duplicate.id FROM users AS duplicate
            WHERE duplicate.astronaut_id IS NOT NULL
              AND length(trim(duplicate.astronaut_id)) > 0
              AND duplicate.id <> (
                SELECT MIN(owner.id) FROM users AS owner
                WHERE lower(trim(owner.astronaut_id)) =
                  lower(trim(duplicate.astronaut_id))
              )
          )
        ''');
        await m.database.customStatement('''
          DELETE FROM users
          WHERE astronaut_id IS NOT NULL
            AND length(trim(astronaut_id)) > 0
            AND id <> (
              SELECT MIN(owner.id) FROM users AS owner
              WHERE lower(trim(owner.astronaut_id)) =
                lower(trim(users.astronaut_id))
            )
        ''');
        await m.database.customStatement(
          'CREATE UNIQUE INDEX users_astronaut_id_unique '
          'ON users(lower(trim(astronaut_id))) '
          'WHERE astronaut_id IS NOT NULL AND length(trim(astronaut_id)) > 0',
        );
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'astrox');
  }
}
