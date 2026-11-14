// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _astronautIdMeta = const VerificationMeta(
    'astronautId',
  );
  @override
  late final GeneratedColumn<String> astronautId = GeneratedColumn<String>(
    'astronaut_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, username, astronautId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('astronaut_id')) {
      context.handle(
        _astronautIdMeta,
        astronautId.isAcceptableOrUnknown(
          data['astronaut_id']!,
          _astronautIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      astronautId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}astronaut_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String username;
  final String? astronautId;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.username,
    this.astronautId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || astronautId != null) {
      map['astronaut_id'] = Variable<String>(astronautId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      astronautId: astronautId == null && nullToAbsent
          ? const Value.absent()
          : Value(astronautId),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      astronautId: serializer.fromJson<String?>(json['astronautId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'astronautId': serializer.toJson<String?>(astronautId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    int? id,
    String? username,
    Value<String?> astronautId = const Value.absent(),
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    astronautId: astronautId.present ? astronautId.value : this.astronautId,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      astronautId: data.astronautId.present
          ? data.astronautId.value
          : this.astronautId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('astronautId: $astronautId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, astronautId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.astronautId == this.astronautId &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String?> astronautId;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.astronautId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    this.astronautId = const Value.absent(),
    required DateTime createdAt,
  }) : username = Value(username),
       createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? astronautId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (astronautId != null) 'astronaut_id': astronautId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String?>? astronautId,
    Value<DateTime>? createdAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      astronautId: astronautId ?? this.astronautId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (astronautId.present) {
      map['astronaut_id'] = Variable<String>(astronautId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('astronautId: $astronautId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyHealthRecordsTable extends DailyHealthRecords
    with TableInfo<$DailyHealthRecordsTable, DailyHealthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oxygenSaturationMeta = const VerificationMeta(
    'oxygenSaturation',
  );
  @override
  late final GeneratedColumn<int> oxygenSaturation = GeneratedColumn<int>(
    'oxygen_saturation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta(
    'sleepHours',
  );
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseMeta = const VerificationMeta(
    'exercise',
  );
  @override
  late final GeneratedColumn<String> exercise = GeneratedColumn<String>(
    'exercise',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodMeta = const VerificationMeta('food');
  @override
  late final GeneratedColumn<String> food = GeneratedColumn<String>(
    'food',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hydrationMeta = const VerificationMeta(
    'hydration',
  );
  @override
  late final GeneratedColumn<String> hydration = GeneratedColumn<String>(
    'hydration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measurementContextMeta =
      const VerificationMeta('measurementContext');
  @override
  late final GeneratedColumn<String> measurementContext =
      GeneratedColumn<String>(
        'measurement_context',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _completedStepsMeta = const VerificationMeta(
    'completedSteps',
  );
  @override
  late final GeneratedColumn<int> completedSteps = GeneratedColumn<int>(
    'completed_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    recordDate,
    systolic,
    diastolic,
    heartRate,
    oxygenSaturation,
    temperature,
    sleepHours,
    mood,
    symptoms,
    exercise,
    food,
    hydration,
    measurementContext,
    completedSteps,
    completedAt,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_health_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyHealthRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('oxygen_saturation')) {
      context.handle(
        _oxygenSaturationMeta,
        oxygenSaturation.isAcceptableOrUnknown(
          data['oxygen_saturation']!,
          _oxygenSaturationMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(
        _sleepHoursMeta,
        sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('exercise')) {
      context.handle(
        _exerciseMeta,
        exercise.isAcceptableOrUnknown(data['exercise']!, _exerciseMeta),
      );
    }
    if (data.containsKey('food')) {
      context.handle(
        _foodMeta,
        food.isAcceptableOrUnknown(data['food']!, _foodMeta),
      );
    }
    if (data.containsKey('hydration')) {
      context.handle(
        _hydrationMeta,
        hydration.isAcceptableOrUnknown(data['hydration']!, _hydrationMeta),
      );
    }
    if (data.containsKey('measurement_context')) {
      context.handle(
        _measurementContextMeta,
        measurementContext.isAcceptableOrUnknown(
          data['measurement_context']!,
          _measurementContextMeta,
        ),
      );
    }
    if (data.containsKey('completed_steps')) {
      context.handle(
        _completedStepsMeta,
        completedSteps.isAcceptableOrUnknown(
          data['completed_steps']!,
          _completedStepsMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyHealthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHealthRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      ),
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      ),
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      oxygenSaturation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oxygen_saturation'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      sleepHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_hours'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      ),
      exercise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise'],
      ),
      food: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food'],
      ),
      hydration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hydration'],
      ),
      measurementContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_context'],
      ),
      completedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_steps'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $DailyHealthRecordsTable createAlias(String alias) {
    return $DailyHealthRecordsTable(attachedDatabase, alias);
  }
}

class DailyHealthRecord extends DataClass
    implements Insertable<DailyHealthRecord> {
  final int id;
  final int userId;
  final DateTime recordDate;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? oxygenSaturation;
  final double? temperature;
  final double? sleepHours;
  final int? mood;
  final String? symptoms;
  final String? exercise;
  final String? food;
  final String? hydration;
  final String? measurementContext;
  final int completedSteps;

  /// Set only when the user presses the final completion button. Partial
  /// saves keep this null so alerts are not generated while the check-in is
  /// still in progress.
  final DateTime? completedAt;
  final DateTime lastUpdated;
  const DailyHealthRecord({
    required this.id,
    required this.userId,
    required this.recordDate,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.oxygenSaturation,
    this.temperature,
    this.sleepHours,
    this.mood,
    this.symptoms,
    this.exercise,
    this.food,
    this.hydration,
    this.measurementContext,
    required this.completedSteps,
    this.completedAt,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['record_date'] = Variable<DateTime>(recordDate);
    if (!nullToAbsent || systolic != null) {
      map['systolic'] = Variable<int>(systolic);
    }
    if (!nullToAbsent || diastolic != null) {
      map['diastolic'] = Variable<int>(diastolic);
    }
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || oxygenSaturation != null) {
      map['oxygen_saturation'] = Variable<int>(oxygenSaturation);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || sleepHours != null) {
      map['sleep_hours'] = Variable<double>(sleepHours);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    if (!nullToAbsent || symptoms != null) {
      map['symptoms'] = Variable<String>(symptoms);
    }
    if (!nullToAbsent || exercise != null) {
      map['exercise'] = Variable<String>(exercise);
    }
    if (!nullToAbsent || food != null) {
      map['food'] = Variable<String>(food);
    }
    if (!nullToAbsent || hydration != null) {
      map['hydration'] = Variable<String>(hydration);
    }
    if (!nullToAbsent || measurementContext != null) {
      map['measurement_context'] = Variable<String>(measurementContext);
    }
    map['completed_steps'] = Variable<int>(completedSteps);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  DailyHealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return DailyHealthRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      recordDate: Value(recordDate),
      systolic: systolic == null && nullToAbsent
          ? const Value.absent()
          : Value(systolic),
      diastolic: diastolic == null && nullToAbsent
          ? const Value.absent()
          : Value(diastolic),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      oxygenSaturation: oxygenSaturation == null && nullToAbsent
          ? const Value.absent()
          : Value(oxygenSaturation),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      sleepHours: sleepHours == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepHours),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      symptoms: symptoms == null && nullToAbsent
          ? const Value.absent()
          : Value(symptoms),
      exercise: exercise == null && nullToAbsent
          ? const Value.absent()
          : Value(exercise),
      food: food == null && nullToAbsent ? const Value.absent() : Value(food),
      hydration: hydration == null && nullToAbsent
          ? const Value.absent()
          : Value(hydration),
      measurementContext: measurementContext == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementContext),
      completedSteps: Value(completedSteps),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory DailyHealthRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHealthRecord(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      systolic: serializer.fromJson<int?>(json['systolic']),
      diastolic: serializer.fromJson<int?>(json['diastolic']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      oxygenSaturation: serializer.fromJson<int?>(json['oxygenSaturation']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      sleepHours: serializer.fromJson<double?>(json['sleepHours']),
      mood: serializer.fromJson<int?>(json['mood']),
      symptoms: serializer.fromJson<String?>(json['symptoms']),
      exercise: serializer.fromJson<String?>(json['exercise']),
      food: serializer.fromJson<String?>(json['food']),
      hydration: serializer.fromJson<String?>(json['hydration']),
      measurementContext: serializer.fromJson<String?>(
        json['measurementContext'],
      ),
      completedSteps: serializer.fromJson<int>(json['completedSteps']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'systolic': serializer.toJson<int?>(systolic),
      'diastolic': serializer.toJson<int?>(diastolic),
      'heartRate': serializer.toJson<int?>(heartRate),
      'oxygenSaturation': serializer.toJson<int?>(oxygenSaturation),
      'temperature': serializer.toJson<double?>(temperature),
      'sleepHours': serializer.toJson<double?>(sleepHours),
      'mood': serializer.toJson<int?>(mood),
      'symptoms': serializer.toJson<String?>(symptoms),
      'exercise': serializer.toJson<String?>(exercise),
      'food': serializer.toJson<String?>(food),
      'hydration': serializer.toJson<String?>(hydration),
      'measurementContext': serializer.toJson<String?>(measurementContext),
      'completedSteps': serializer.toJson<int>(completedSteps),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  DailyHealthRecord copyWith({
    int? id,
    int? userId,
    DateTime? recordDate,
    Value<int?> systolic = const Value.absent(),
    Value<int?> diastolic = const Value.absent(),
    Value<int?> heartRate = const Value.absent(),
    Value<int?> oxygenSaturation = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<double?> sleepHours = const Value.absent(),
    Value<int?> mood = const Value.absent(),
    Value<String?> symptoms = const Value.absent(),
    Value<String?> exercise = const Value.absent(),
    Value<String?> food = const Value.absent(),
    Value<String?> hydration = const Value.absent(),
    Value<String?> measurementContext = const Value.absent(),
    int? completedSteps,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? lastUpdated,
  }) => DailyHealthRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    recordDate: recordDate ?? this.recordDate,
    systolic: systolic.present ? systolic.value : this.systolic,
    diastolic: diastolic.present ? diastolic.value : this.diastolic,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    oxygenSaturation: oxygenSaturation.present
        ? oxygenSaturation.value
        : this.oxygenSaturation,
    temperature: temperature.present ? temperature.value : this.temperature,
    sleepHours: sleepHours.present ? sleepHours.value : this.sleepHours,
    mood: mood.present ? mood.value : this.mood,
    symptoms: symptoms.present ? symptoms.value : this.symptoms,
    exercise: exercise.present ? exercise.value : this.exercise,
    food: food.present ? food.value : this.food,
    hydration: hydration.present ? hydration.value : this.hydration,
    measurementContext: measurementContext.present
        ? measurementContext.value
        : this.measurementContext,
    completedSteps: completedSteps ?? this.completedSteps,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  DailyHealthRecord copyWithCompanion(DailyHealthRecordsCompanion data) {
    return DailyHealthRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      oxygenSaturation: data.oxygenSaturation.present
          ? data.oxygenSaturation.value
          : this.oxygenSaturation,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      sleepHours: data.sleepHours.present
          ? data.sleepHours.value
          : this.sleepHours,
      mood: data.mood.present ? data.mood.value : this.mood,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      exercise: data.exercise.present ? data.exercise.value : this.exercise,
      food: data.food.present ? data.food.value : this.food,
      hydration: data.hydration.present ? data.hydration.value : this.hydration,
      measurementContext: data.measurementContext.present
          ? data.measurementContext.value
          : this.measurementContext,
      completedSteps: data.completedSteps.present
          ? data.completedSteps.value
          : this.completedSteps,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recordDate: $recordDate, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('heartRate: $heartRate, ')
          ..write('oxygenSaturation: $oxygenSaturation, ')
          ..write('temperature: $temperature, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('mood: $mood, ')
          ..write('symptoms: $symptoms, ')
          ..write('exercise: $exercise, ')
          ..write('food: $food, ')
          ..write('hydration: $hydration, ')
          ..write('measurementContext: $measurementContext, ')
          ..write('completedSteps: $completedSteps, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    recordDate,
    systolic,
    diastolic,
    heartRate,
    oxygenSaturation,
    temperature,
    sleepHours,
    mood,
    symptoms,
    exercise,
    food,
    hydration,
    measurementContext,
    completedSteps,
    completedAt,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHealthRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.recordDate == this.recordDate &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.heartRate == this.heartRate &&
          other.oxygenSaturation == this.oxygenSaturation &&
          other.temperature == this.temperature &&
          other.sleepHours == this.sleepHours &&
          other.mood == this.mood &&
          other.symptoms == this.symptoms &&
          other.exercise == this.exercise &&
          other.food == this.food &&
          other.hydration == this.hydration &&
          other.measurementContext == this.measurementContext &&
          other.completedSteps == this.completedSteps &&
          other.completedAt == this.completedAt &&
          other.lastUpdated == this.lastUpdated);
}

class DailyHealthRecordsCompanion extends UpdateCompanion<DailyHealthRecord> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> recordDate;
  final Value<int?> systolic;
  final Value<int?> diastolic;
  final Value<int?> heartRate;
  final Value<int?> oxygenSaturation;
  final Value<double?> temperature;
  final Value<double?> sleepHours;
  final Value<int?> mood;
  final Value<String?> symptoms;
  final Value<String?> exercise;
  final Value<String?> food;
  final Value<String?> hydration;
  final Value<String?> measurementContext;
  final Value<int> completedSteps;
  final Value<DateTime?> completedAt;
  final Value<DateTime> lastUpdated;
  const DailyHealthRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.oxygenSaturation = const Value.absent(),
    this.temperature = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.mood = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.exercise = const Value.absent(),
    this.food = const Value.absent(),
    this.hydration = const Value.absent(),
    this.measurementContext = const Value.absent(),
    this.completedSteps = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  DailyHealthRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime recordDate,
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.oxygenSaturation = const Value.absent(),
    this.temperature = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.mood = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.exercise = const Value.absent(),
    this.food = const Value.absent(),
    this.hydration = const Value.absent(),
    this.measurementContext = const Value.absent(),
    this.completedSteps = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime lastUpdated,
  }) : userId = Value(userId),
       recordDate = Value(recordDate),
       lastUpdated = Value(lastUpdated);
  static Insertable<DailyHealthRecord> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? recordDate,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? heartRate,
    Expression<int>? oxygenSaturation,
    Expression<double>? temperature,
    Expression<double>? sleepHours,
    Expression<int>? mood,
    Expression<String>? symptoms,
    Expression<String>? exercise,
    Expression<String>? food,
    Expression<String>? hydration,
    Expression<String>? measurementContext,
    Expression<int>? completedSteps,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (recordDate != null) 'record_date': recordDate,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (heartRate != null) 'heart_rate': heartRate,
      if (oxygenSaturation != null) 'oxygen_saturation': oxygenSaturation,
      if (temperature != null) 'temperature': temperature,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (mood != null) 'mood': mood,
      if (symptoms != null) 'symptoms': symptoms,
      if (exercise != null) 'exercise': exercise,
      if (food != null) 'food': food,
      if (hydration != null) 'hydration': hydration,
      if (measurementContext != null) 'measurement_context': measurementContext,
      if (completedSteps != null) 'completed_steps': completedSteps,
      if (completedAt != null) 'completed_at': completedAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  DailyHealthRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? recordDate,
    Value<int?>? systolic,
    Value<int?>? diastolic,
    Value<int?>? heartRate,
    Value<int?>? oxygenSaturation,
    Value<double?>? temperature,
    Value<double?>? sleepHours,
    Value<int?>? mood,
    Value<String?>? symptoms,
    Value<String?>? exercise,
    Value<String?>? food,
    Value<String?>? hydration,
    Value<String?>? measurementContext,
    Value<int>? completedSteps,
    Value<DateTime?>? completedAt,
    Value<DateTime>? lastUpdated,
  }) {
    return DailyHealthRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recordDate: recordDate ?? this.recordDate,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      temperature: temperature ?? this.temperature,
      sleepHours: sleepHours ?? this.sleepHours,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      exercise: exercise ?? this.exercise,
      food: food ?? this.food,
      hydration: hydration ?? this.hydration,
      measurementContext: measurementContext ?? this.measurementContext,
      completedSteps: completedSteps ?? this.completedSteps,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (oxygenSaturation.present) {
      map['oxygen_saturation'] = Variable<int>(oxygenSaturation.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (exercise.present) {
      map['exercise'] = Variable<String>(exercise.value);
    }
    if (food.present) {
      map['food'] = Variable<String>(food.value);
    }
    if (hydration.present) {
      map['hydration'] = Variable<String>(hydration.value);
    }
    if (measurementContext.present) {
      map['measurement_context'] = Variable<String>(measurementContext.value);
    }
    if (completedSteps.present) {
      map['completed_steps'] = Variable<int>(completedSteps.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recordDate: $recordDate, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('heartRate: $heartRate, ')
          ..write('oxygenSaturation: $oxygenSaturation, ')
          ..write('temperature: $temperature, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('mood: $mood, ')
          ..write('symptoms: $symptoms, ')
          ..write('exercise: $exercise, ')
          ..write('food: $food, ')
          ..write('hydration: $hydration, ')
          ..write('measurementContext: $measurementContext, ')
          ..write('completedSteps: $completedSteps, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $HealthAlertsTable extends HealthAlerts
    with TableInfo<$HealthAlertsTable, HealthAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<int> recordId = GeneratedColumn<int>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
    'metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingTextMeta = const VerificationMeta(
    'readingText',
  );
  @override
  late final GeneratedColumn<String> readingText = GeneratedColumn<String>(
    'reading_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guidanceMeta = const VerificationMeta(
    'guidance',
  );
  @override
  late final GeneratedColumn<String> guidance = GeneratedColumn<String>(
    'guidance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oxygenMeta = const VerificationMeta('oxygen');
  @override
  late final GeneratedColumn<int> oxygen = GeneratedColumn<int>(
    'oxygen',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUnreadMeta = const VerificationMeta(
    'isUnread',
  );
  @override
  late final GeneratedColumn<bool> isUnread = GeneratedColumn<bool>(
    'is_unread',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unread" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    recordId,
    metric,
    title,
    summary,
    severity,
    readingText,
    guidance,
    systolic,
    diastolic,
    heartRate,
    oxygen,
    isUnread,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('metric')) {
      context.handle(
        _metricMeta,
        metric.isAcceptableOrUnknown(data['metric']!, _metricMeta),
      );
    } else if (isInserting) {
      context.missing(_metricMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('reading_text')) {
      context.handle(
        _readingTextMeta,
        readingText.isAcceptableOrUnknown(
          data['reading_text']!,
          _readingTextMeta,
        ),
      );
    }
    if (data.containsKey('guidance')) {
      context.handle(
        _guidanceMeta,
        guidance.isAcceptableOrUnknown(data['guidance']!, _guidanceMeta),
      );
    } else if (isInserting) {
      context.missing(_guidanceMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('oxygen')) {
      context.handle(
        _oxygenMeta,
        oxygen.isAcceptableOrUnknown(data['oxygen']!, _oxygenMeta),
      );
    }
    if (data.containsKey('is_unread')) {
      context.handle(
        _isUnreadMeta,
        isUnread.isAcceptableOrUnknown(data['is_unread']!, _isUnreadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_id'],
      )!,
      metric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      readingText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_text'],
      ),
      guidance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guidance'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      ),
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      ),
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      oxygen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oxygen'],
      ),
      isUnread: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unread'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HealthAlertsTable createAlias(String alias) {
    return $HealthAlertsTable(attachedDatabase, alias);
  }
}

class HealthAlert extends DataClass implements Insertable<HealthAlert> {
  final String id;
  final int userId;
  final int recordId;
  final String metric;
  final String title;
  final String summary;
  final String severity;
  final String? readingText;
  final String guidance;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? oxygen;
  final bool isUnread;
  final DateTime createdAt;
  final DateTime updatedAt;
  const HealthAlert({
    required this.id,
    required this.userId,
    required this.recordId,
    required this.metric,
    required this.title,
    required this.summary,
    required this.severity,
    this.readingText,
    required this.guidance,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.oxygen,
    required this.isUnread,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<int>(userId);
    map['record_id'] = Variable<int>(recordId);
    map['metric'] = Variable<String>(metric);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || readingText != null) {
      map['reading_text'] = Variable<String>(readingText);
    }
    map['guidance'] = Variable<String>(guidance);
    if (!nullToAbsent || systolic != null) {
      map['systolic'] = Variable<int>(systolic);
    }
    if (!nullToAbsent || diastolic != null) {
      map['diastolic'] = Variable<int>(diastolic);
    }
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || oxygen != null) {
      map['oxygen'] = Variable<int>(oxygen);
    }
    map['is_unread'] = Variable<bool>(isUnread);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HealthAlertsCompanion toCompanion(bool nullToAbsent) {
    return HealthAlertsCompanion(
      id: Value(id),
      userId: Value(userId),
      recordId: Value(recordId),
      metric: Value(metric),
      title: Value(title),
      summary: Value(summary),
      severity: Value(severity),
      readingText: readingText == null && nullToAbsent
          ? const Value.absent()
          : Value(readingText),
      guidance: Value(guidance),
      systolic: systolic == null && nullToAbsent
          ? const Value.absent()
          : Value(systolic),
      diastolic: diastolic == null && nullToAbsent
          ? const Value.absent()
          : Value(diastolic),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      oxygen: oxygen == null && nullToAbsent
          ? const Value.absent()
          : Value(oxygen),
      isUnread: Value(isUnread),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HealthAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthAlert(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      recordId: serializer.fromJson<int>(json['recordId']),
      metric: serializer.fromJson<String>(json['metric']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      severity: serializer.fromJson<String>(json['severity']),
      readingText: serializer.fromJson<String?>(json['readingText']),
      guidance: serializer.fromJson<String>(json['guidance']),
      systolic: serializer.fromJson<int?>(json['systolic']),
      diastolic: serializer.fromJson<int?>(json['diastolic']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      oxygen: serializer.fromJson<int?>(json['oxygen']),
      isUnread: serializer.fromJson<bool>(json['isUnread']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<int>(userId),
      'recordId': serializer.toJson<int>(recordId),
      'metric': serializer.toJson<String>(metric),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'severity': serializer.toJson<String>(severity),
      'readingText': serializer.toJson<String?>(readingText),
      'guidance': serializer.toJson<String>(guidance),
      'systolic': serializer.toJson<int?>(systolic),
      'diastolic': serializer.toJson<int?>(diastolic),
      'heartRate': serializer.toJson<int?>(heartRate),
      'oxygen': serializer.toJson<int?>(oxygen),
      'isUnread': serializer.toJson<bool>(isUnread),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HealthAlert copyWith({
    String? id,
    int? userId,
    int? recordId,
    String? metric,
    String? title,
    String? summary,
    String? severity,
    Value<String?> readingText = const Value.absent(),
    String? guidance,
    Value<int?> systolic = const Value.absent(),
    Value<int?> diastolic = const Value.absent(),
    Value<int?> heartRate = const Value.absent(),
    Value<int?> oxygen = const Value.absent(),
    bool? isUnread,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HealthAlert(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    recordId: recordId ?? this.recordId,
    metric: metric ?? this.metric,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    severity: severity ?? this.severity,
    readingText: readingText.present ? readingText.value : this.readingText,
    guidance: guidance ?? this.guidance,
    systolic: systolic.present ? systolic.value : this.systolic,
    diastolic: diastolic.present ? diastolic.value : this.diastolic,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    oxygen: oxygen.present ? oxygen.value : this.oxygen,
    isUnread: isUnread ?? this.isUnread,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HealthAlert copyWithCompanion(HealthAlertsCompanion data) {
    return HealthAlert(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      metric: data.metric.present ? data.metric.value : this.metric,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      severity: data.severity.present ? data.severity.value : this.severity,
      readingText: data.readingText.present
          ? data.readingText.value
          : this.readingText,
      guidance: data.guidance.present ? data.guidance.value : this.guidance,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      oxygen: data.oxygen.present ? data.oxygen.value : this.oxygen,
      isUnread: data.isUnread.present ? data.isUnread.value : this.isUnread,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthAlert(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recordId: $recordId, ')
          ..write('metric: $metric, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('severity: $severity, ')
          ..write('readingText: $readingText, ')
          ..write('guidance: $guidance, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('heartRate: $heartRate, ')
          ..write('oxygen: $oxygen, ')
          ..write('isUnread: $isUnread, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    recordId,
    metric,
    title,
    summary,
    severity,
    readingText,
    guidance,
    systolic,
    diastolic,
    heartRate,
    oxygen,
    isUnread,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthAlert &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.recordId == this.recordId &&
          other.metric == this.metric &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.severity == this.severity &&
          other.readingText == this.readingText &&
          other.guidance == this.guidance &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.heartRate == this.heartRate &&
          other.oxygen == this.oxygen &&
          other.isUnread == this.isUnread &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HealthAlertsCompanion extends UpdateCompanion<HealthAlert> {
  final Value<String> id;
  final Value<int> userId;
  final Value<int> recordId;
  final Value<String> metric;
  final Value<String> title;
  final Value<String> summary;
  final Value<String> severity;
  final Value<String?> readingText;
  final Value<String> guidance;
  final Value<int?> systolic;
  final Value<int?> diastolic;
  final Value<int?> heartRate;
  final Value<int?> oxygen;
  final Value<bool> isUnread;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HealthAlertsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.recordId = const Value.absent(),
    this.metric = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.severity = const Value.absent(),
    this.readingText = const Value.absent(),
    this.guidance = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.oxygen = const Value.absent(),
    this.isUnread = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthAlertsCompanion.insert({
    required String id,
    required int userId,
    required int recordId,
    required String metric,
    required String title,
    required String summary,
    required String severity,
    this.readingText = const Value.absent(),
    required String guidance,
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.oxygen = const Value.absent(),
    this.isUnread = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       recordId = Value(recordId),
       metric = Value(metric),
       title = Value(title),
       summary = Value(summary),
       severity = Value(severity),
       guidance = Value(guidance),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HealthAlert> custom({
    Expression<String>? id,
    Expression<int>? userId,
    Expression<int>? recordId,
    Expression<String>? metric,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? severity,
    Expression<String>? readingText,
    Expression<String>? guidance,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? heartRate,
    Expression<int>? oxygen,
    Expression<bool>? isUnread,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (recordId != null) 'record_id': recordId,
      if (metric != null) 'metric': metric,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (severity != null) 'severity': severity,
      if (readingText != null) 'reading_text': readingText,
      if (guidance != null) 'guidance': guidance,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (heartRate != null) 'heart_rate': heartRate,
      if (oxygen != null) 'oxygen': oxygen,
      if (isUnread != null) 'is_unread': isUnread,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthAlertsCompanion copyWith({
    Value<String>? id,
    Value<int>? userId,
    Value<int>? recordId,
    Value<String>? metric,
    Value<String>? title,
    Value<String>? summary,
    Value<String>? severity,
    Value<String?>? readingText,
    Value<String>? guidance,
    Value<int?>? systolic,
    Value<int?>? diastolic,
    Value<int?>? heartRate,
    Value<int?>? oxygen,
    Value<bool>? isUnread,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HealthAlertsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recordId: recordId ?? this.recordId,
      metric: metric ?? this.metric,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      severity: severity ?? this.severity,
      readingText: readingText ?? this.readingText,
      guidance: guidance ?? this.guidance,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      oxygen: oxygen ?? this.oxygen,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<int>(recordId.value);
    }
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (readingText.present) {
      map['reading_text'] = Variable<String>(readingText.value);
    }
    if (guidance.present) {
      map['guidance'] = Variable<String>(guidance.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (oxygen.present) {
      map['oxygen'] = Variable<int>(oxygen.value);
    }
    if (isUnread.present) {
      map['is_unread'] = Variable<bool>(isUnread.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthAlertsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recordId: $recordId, ')
          ..write('metric: $metric, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('severity: $severity, ')
          ..write('readingText: $readingText, ')
          ..write('guidance: $guidance, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('heartRate: $heartRate, ')
          ..write('oxygen: $oxygen, ')
          ..write('isUnread: $isUnread, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $DailyHealthRecordsTable dailyHealthRecords =
      $DailyHealthRecordsTable(this);
  late final $HealthAlertsTable healthAlerts = $HealthAlertsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    dailyHealthRecords,
    healthAlerts,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String username,
      Value<String?> astronautId,
      required DateTime createdAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String?> astronautId,
      Value<DateTime> createdAt,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get astronautId => $composableBuilder(
    column: $table.astronautId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get astronautId => $composableBuilder(
    column: $table.astronautId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get astronautId => $composableBuilder(
    column: $table.astronautId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> astronautId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                astronautId: astronautId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                Value<String?> astronautId = const Value.absent(),
                required DateTime createdAt,
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                astronautId: astronautId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$DailyHealthRecordsTableCreateCompanionBuilder =
    DailyHealthRecordsCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime recordDate,
      Value<int?> systolic,
      Value<int?> diastolic,
      Value<int?> heartRate,
      Value<int?> oxygenSaturation,
      Value<double?> temperature,
      Value<double?> sleepHours,
      Value<int?> mood,
      Value<String?> symptoms,
      Value<String?> exercise,
      Value<String?> food,
      Value<String?> hydration,
      Value<String?> measurementContext,
      Value<int> completedSteps,
      Value<DateTime?> completedAt,
      required DateTime lastUpdated,
    });
typedef $$DailyHealthRecordsTableUpdateCompanionBuilder =
    DailyHealthRecordsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> recordDate,
      Value<int?> systolic,
      Value<int?> diastolic,
      Value<int?> heartRate,
      Value<int?> oxygenSaturation,
      Value<double?> temperature,
      Value<double?> sleepHours,
      Value<int?> mood,
      Value<String?> symptoms,
      Value<String?> exercise,
      Value<String?> food,
      Value<String?> hydration,
      Value<String?> measurementContext,
      Value<int> completedSteps,
      Value<DateTime?> completedAt,
      Value<DateTime> lastUpdated,
    });

class $$DailyHealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyHealthRecordsTable> {
  $$DailyHealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get food => $composableBuilder(
    column: $table.food,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hydration => $composableBuilder(
    column: $table.hydration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyHealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyHealthRecordsTable> {
  $$DailyHealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get food => $composableBuilder(
    column: $table.food,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hydration => $composableBuilder(
    column: $table.hydration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyHealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyHealthRecordsTable> {
  $$DailyHealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<int> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get exercise =>
      $composableBuilder(column: $table.exercise, builder: (column) => column);

  GeneratedColumn<String> get food =>
      $composableBuilder(column: $table.food, builder: (column) => column);

  GeneratedColumn<String> get hydration =>
      $composableBuilder(column: $table.hydration, builder: (column) => column);

  GeneratedColumn<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$DailyHealthRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyHealthRecordsTable,
          DailyHealthRecord,
          $$DailyHealthRecordsTableFilterComposer,
          $$DailyHealthRecordsTableOrderingComposer,
          $$DailyHealthRecordsTableAnnotationComposer,
          $$DailyHealthRecordsTableCreateCompanionBuilder,
          $$DailyHealthRecordsTableUpdateCompanionBuilder,
          (
            DailyHealthRecord,
            BaseReferences<
              _$AppDatabase,
              $DailyHealthRecordsTable,
              DailyHealthRecord
            >,
          ),
          DailyHealthRecord,
          PrefetchHooks Function()
        > {
  $$DailyHealthRecordsTableTableManager(
    _$AppDatabase db,
    $DailyHealthRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyHealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyHealthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyHealthRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<int?> systolic = const Value.absent(),
                Value<int?> diastolic = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> oxygenSaturation = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> exercise = const Value.absent(),
                Value<String?> food = const Value.absent(),
                Value<String?> hydration = const Value.absent(),
                Value<String?> measurementContext = const Value.absent(),
                Value<int> completedSteps = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => DailyHealthRecordsCompanion(
                id: id,
                userId: userId,
                recordDate: recordDate,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
                oxygenSaturation: oxygenSaturation,
                temperature: temperature,
                sleepHours: sleepHours,
                mood: mood,
                symptoms: symptoms,
                exercise: exercise,
                food: food,
                hydration: hydration,
                measurementContext: measurementContext,
                completedSteps: completedSteps,
                completedAt: completedAt,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime recordDate,
                Value<int?> systolic = const Value.absent(),
                Value<int?> diastolic = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> oxygenSaturation = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> exercise = const Value.absent(),
                Value<String?> food = const Value.absent(),
                Value<String?> hydration = const Value.absent(),
                Value<String?> measurementContext = const Value.absent(),
                Value<int> completedSteps = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime lastUpdated,
              }) => DailyHealthRecordsCompanion.insert(
                id: id,
                userId: userId,
                recordDate: recordDate,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
                oxygenSaturation: oxygenSaturation,
                temperature: temperature,
                sleepHours: sleepHours,
                mood: mood,
                symptoms: symptoms,
                exercise: exercise,
                food: food,
                hydration: hydration,
                measurementContext: measurementContext,
                completedSteps: completedSteps,
                completedAt: completedAt,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyHealthRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyHealthRecordsTable,
      DailyHealthRecord,
      $$DailyHealthRecordsTableFilterComposer,
      $$DailyHealthRecordsTableOrderingComposer,
      $$DailyHealthRecordsTableAnnotationComposer,
      $$DailyHealthRecordsTableCreateCompanionBuilder,
      $$DailyHealthRecordsTableUpdateCompanionBuilder,
      (
        DailyHealthRecord,
        BaseReferences<
          _$AppDatabase,
          $DailyHealthRecordsTable,
          DailyHealthRecord
        >,
      ),
      DailyHealthRecord,
      PrefetchHooks Function()
    >;
typedef $$HealthAlertsTableCreateCompanionBuilder =
    HealthAlertsCompanion Function({
      required String id,
      required int userId,
      required int recordId,
      required String metric,
      required String title,
      required String summary,
      required String severity,
      Value<String?> readingText,
      required String guidance,
      Value<int?> systolic,
      Value<int?> diastolic,
      Value<int?> heartRate,
      Value<int?> oxygen,
      Value<bool> isUnread,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HealthAlertsTableUpdateCompanionBuilder =
    HealthAlertsCompanion Function({
      Value<String> id,
      Value<int> userId,
      Value<int> recordId,
      Value<String> metric,
      Value<String> title,
      Value<String> summary,
      Value<String> severity,
      Value<String?> readingText,
      Value<String> guidance,
      Value<int?> systolic,
      Value<int?> diastolic,
      Value<int?> heartRate,
      Value<int?> oxygen,
      Value<bool> isUnread,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HealthAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthAlertsTable> {
  $$HealthAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingText => $composableBuilder(
    column: $table.readingText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guidance => $composableBuilder(
    column: $table.guidance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oxygen => $composableBuilder(
    column: $table.oxygen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnread => $composableBuilder(
    column: $table.isUnread,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthAlertsTable> {
  $$HealthAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingText => $composableBuilder(
    column: $table.readingText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guidance => $composableBuilder(
    column: $table.guidance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oxygen => $composableBuilder(
    column: $table.oxygen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnread => $composableBuilder(
    column: $table.isUnread,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthAlertsTable> {
  $$HealthAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get readingText => $composableBuilder(
    column: $table.readingText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guidance =>
      $composableBuilder(column: $table.guidance, builder: (column) => column);

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<int> get oxygen =>
      $composableBuilder(column: $table.oxygen, builder: (column) => column);

  GeneratedColumn<bool> get isUnread =>
      $composableBuilder(column: $table.isUnread, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HealthAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthAlertsTable,
          HealthAlert,
          $$HealthAlertsTableFilterComposer,
          $$HealthAlertsTableOrderingComposer,
          $$HealthAlertsTableAnnotationComposer,
          $$HealthAlertsTableCreateCompanionBuilder,
          $$HealthAlertsTableUpdateCompanionBuilder,
          (
            HealthAlert,
            BaseReferences<_$AppDatabase, $HealthAlertsTable, HealthAlert>,
          ),
          HealthAlert,
          PrefetchHooks Function()
        > {
  $$HealthAlertsTableTableManager(_$AppDatabase db, $HealthAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> recordId = const Value.absent(),
                Value<String> metric = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> readingText = const Value.absent(),
                Value<String> guidance = const Value.absent(),
                Value<int?> systolic = const Value.absent(),
                Value<int?> diastolic = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> oxygen = const Value.absent(),
                Value<bool> isUnread = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthAlertsCompanion(
                id: id,
                userId: userId,
                recordId: recordId,
                metric: metric,
                title: title,
                summary: summary,
                severity: severity,
                readingText: readingText,
                guidance: guidance,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
                oxygen: oxygen,
                isUnread: isUnread,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int userId,
                required int recordId,
                required String metric,
                required String title,
                required String summary,
                required String severity,
                Value<String?> readingText = const Value.absent(),
                required String guidance,
                Value<int?> systolic = const Value.absent(),
                Value<int?> diastolic = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> oxygen = const Value.absent(),
                Value<bool> isUnread = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HealthAlertsCompanion.insert(
                id: id,
                userId: userId,
                recordId: recordId,
                metric: metric,
                title: title,
                summary: summary,
                severity: severity,
                readingText: readingText,
                guidance: guidance,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
                oxygen: oxygen,
                isUnread: isUnread,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthAlertsTable,
      HealthAlert,
      $$HealthAlertsTableFilterComposer,
      $$HealthAlertsTableOrderingComposer,
      $$HealthAlertsTableAnnotationComposer,
      $$HealthAlertsTableCreateCompanionBuilder,
      $$HealthAlertsTableUpdateCompanionBuilder,
      (
        HealthAlert,
        BaseReferences<_$AppDatabase, $HealthAlertsTable, HealthAlert>,
      ),
      HealthAlert,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$DailyHealthRecordsTableTableManager get dailyHealthRecords =>
      $$DailyHealthRecordsTableTableManager(_db, _db.dailyHealthRecords);
  $$HealthAlertsTableTableManager get healthAlerts =>
      $$HealthAlertsTableTableManager(_db, _db.healthAlerts);
}
