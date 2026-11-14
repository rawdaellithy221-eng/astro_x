import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helper/health_input_validator.dart';
import '../../../data/models/check_in_step.dart';
import '../../../data/models/health_metric_id.dart';
import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/health_data_repository.dart';

class DailyCheckInState extends Equatable {
  const DailyCheckInState({
    this.loading = true,
    this.steps = const [],
    this.currentIndex = 0,
    this.values = const {},
    this.finished = false,
    this.error,
  });

  final bool loading;
  final List<CheckInStep> steps;
  final int currentIndex;
  final Map<String, String> values;
  final bool finished;
  final String? error;

  CheckInStep? get currentStep => steps.isEmpty || currentIndex >= steps.length
      ? null
      : steps[currentIndex];

  DailyCheckInState copyWith({
    bool? loading,
    List<CheckInStep>? steps,
    int? currentIndex,
    Map<String, String>? values,
    bool? finished,
    String? error,
    bool clearError = false,
  }) {
    return DailyCheckInState(
      loading: loading ?? this.loading,
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      values: values ?? this.values,
      finished: finished ?? this.finished,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    loading,
    steps,
    currentIndex,
    values,
    finished,
    error,
  ];
}

class DailyCheckInCubit extends Cubit<DailyCheckInState> {
  DailyCheckInCubit({
    CheckInRepository? repository,
    HealthDataRepository? healthRepository,
    this._userId,
    int? recordId,
  }) : _repo = repository ?? const CheckInRepository(),
       _health = healthRepository,
       super(const DailyCheckInState()) {
    _recordId = recordId;
  }

  final CheckInRepository _repo;
  final HealthDataRepository? _health;
  final int? _userId;
  int? _recordId;
  Future<void> _saveChain = Future<void>.value();

  /// New check-ins start empty. An explicit record ID opts into editing that
  /// saved record without changing the default new-entry behavior.
  Future<void> load() async {
    emit(state.copyWith(loading: true, steps: _repo.steps(), clearError: true));

    final health = _health;
    final userId = _userId;
    if (health == null || userId == null) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Your user profile is still loading. Please try again.',
        ),
      );
      return;
    }

    try {
      final record = _recordId == null
          ? null
          : await health.getRecordById(userId, _recordId!);
      final values = <String, String>{};
      if (record != null) {
        void put(String key, Object? value) {
          if (value != null) values[key] = value.toString();
        }

        put('bp_sys', record.systolic);
        put('bp_dia', record.diastolic);
        put(HealthMetricId.heartRate.name, record.heartRate);
        put(HealthMetricId.oxygen.name, record.oxygenSaturation);
        put(HealthMetricId.temperature.name, record.temperature);
        put(HealthMetricId.sleep.name, record.sleepHours);
        put(HealthMetricId.mood.name, record.mood);
        put(HealthMetricId.exercise.name, record.exercise);
        put('context', record.measurementContext);
      }
      if (isClosed) return;
      emit(state.copyWith(loading: false, values: values, clearError: true));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: 'Could not load today\'s check-in. Please try again.',
        ),
      );
    }
  }

  void setValue(String key, String value) {
    final next = Map<String, String>.from(state.values);
    next[key] = value;
    emit(state.copyWith(values: next, clearError: true));
    _scheduleSave();
  }

  Future<void> next() async {
    final isLast = state.currentIndex >= state.steps.length - 1;
    if (isLast && !_hasAnyReading(state.values)) {
      emit(
        state.copyWith(
          error: 'Add at least one reading before finishing your check-in.',
        ),
      );
      return;
    }

    // The last button finalizes the check-in. Every earlier step only saves
    // partial progress, so alerts cannot fire while the form is still open.
    await _flushSave(validate: true, finalize: isLast);
    if (isClosed || state.error != null) return;

    if (state.currentIndex < state.steps.length - 1) {
      emit(
        state.copyWith(currentIndex: state.currentIndex + 1, clearError: true),
      );
    } else {
      emit(state.copyWith(finished: true, clearError: true));
    }
  }

  /// Moves past a step without finalizing. Values already typed are saved,
  /// but the daily record stays incomplete.
  Future<void> skip() async {
    if (state.currentIndex >= state.steps.length - 1) return;
    await _flushSave(validate: false);
    if (isClosed || state.error != null) return;
    emit(
      state.copyWith(currentIndex: state.currentIndex + 1, clearError: true),
    );
  }

  void back() {
    if (state.currentIndex > 0) {
      emit(
        state.copyWith(currentIndex: state.currentIndex - 1, clearError: true),
      );
    }
  }

  void restart() {
    _recordId = null;
    emit(
      state.copyWith(
        currentIndex: 0,
        values: const {},
        finished: false,
        clearError: true,
      ),
    );
  }

  bool _hasAnyReading(Map<String, String> values) {
    return values.entries.any(
      (entry) => entry.key != 'context' && entry.value.trim().isNotEmpty,
    );
  }

  /// Writes are chained instead of fired in parallel. Fast typing can trigger
  /// many saves, and serializing them keeps one daily record authoritative.
  void _scheduleSave() {
    _saveChain = _saveChain.then((_) async {
      try {
        await _save(validate: false);
        if (!isClosed && state.error != null) {
          emit(state.copyWith(clearError: true));
        }
      } catch (_) {
        if (!isClosed) {
          emit(
            state.copyWith(
              error: 'Your changes could not be saved. Please try again.',
            ),
          );
        }
      }
    });
  }

  Future<void> _flushSave({
    required bool validate,
    bool finalize = false,
  }) async {
    _saveChain = _saveChain.then((_) async {
      try {
        await _save(validate: validate, finalize: finalize);
        if (!isClosed && state.error != null) {
          emit(state.copyWith(clearError: true));
        }
      } catch (error) {
        if (!isClosed) {
          emit(
            state.copyWith(
              error: error is FormatException
                  ? error.message
                  : 'Your check-in could not be saved. Please try again.',
            ),
          );
        }
      }
    });
    await _saveChain;
  }

  Future<void> _save({required bool validate, bool finalize = false}) async {
    final health = _health;
    final userId = _userId;
    if (health == null || userId == null) {
      throw StateError('User session is not ready.');
    }

    final parsed = _parsedValues(validate: validate);
    final recordId = await health.upsertTodayRecord(
      userId,
      recordId: _recordId,
      createNewRecord: _recordId == null,
      systolic: parsed.systolic,
      diastolic: parsed.diastolic,
      heartRate: parsed.heartRate,
      oxygenSaturation: parsed.oxygenSaturation,
      temperature: parsed.temperature,
      sleepHours: parsed.sleepHours,
      mood: parsed.mood,
      exercise: parsed.exercise,
      measurementContext: parsed.measurementContext,
      completedSteps: finalize ? state.steps.length : null,
      finalize: finalize,
    );
    _recordId ??= recordId;
  }

  _ParsedCheckIn _parsedValues({required bool validate}) {
    final values = state.values;

    String text(String key) => values[key]?.trim() ?? '';

    final systolicText = text('bp_sys');
    final diastolicText = text('bp_dia');
    if (validate) {
      HealthInputValidator.validateBloodPressurePair(
        systolicText,
        diastolicText,
      );
    }

    var systolic = HealthInputValidator.parseInt(
      systolicText,
      min: HealthInputValidator.systolicMin,
      max: HealthInputValidator.systolicMax,
      label: 'systolic pressure',
      validate: validate,
    );
    var diastolic = HealthInputValidator.parseInt(
      diastolicText,
      min: HealthInputValidator.diastolicMin,
      max: HealthInputValidator.diastolicMax,
      label: 'diastolic pressure',
      validate: validate,
    );
    if (systolic != null && diastolic != null && systolic <= diastolic) {
      if (validate) {
        throw const FormatException(
          'Systolic pressure must be higher than diastolic pressure.',
        );
      }
      // Do not persist a physically impossible pair from an in-progress save.
      systolic = null;
      diastolic = null;
    }

    final exercise = text(HealthMetricId.exercise.name);
    if (exercise.isNotEmpty) {
      HealthInputValidator.exerciseMinutes(exercise, validate: validate);
    }

    return _ParsedCheckIn(
      systolic: systolic,
      diastolic: diastolic,
      heartRate: HealthInputValidator.parseInt(
        text(HealthMetricId.heartRate.name),
        min: HealthInputValidator.heartRateMin,
        max: HealthInputValidator.heartRateMax,
        label: 'heart rate',
        validate: validate,
      ),
      oxygenSaturation: HealthInputValidator.parseInt(
        text(HealthMetricId.oxygen.name),
        min: HealthInputValidator.oxygenMin,
        max: HealthInputValidator.oxygenMax,
        label: 'oxygen saturation percentage',
        validate: validate,
      ),
      temperature: HealthInputValidator.parseDouble(
        text(HealthMetricId.temperature.name),
        min: HealthInputValidator.temperatureMin,
        max: HealthInputValidator.temperatureMax,
        label: 'temperature',
        validate: validate,
      ),
      sleepHours: HealthInputValidator.parseDouble(
        text(HealthMetricId.sleep.name),
        min: HealthInputValidator.sleepMin,
        max: HealthInputValidator.sleepMax,
        label: 'sleep duration',
        validate: validate,
      ),
      mood: HealthInputValidator.parseInt(
        text(HealthMetricId.mood.name),
        min: HealthInputValidator.moodMin,
        max: HealthInputValidator.moodMax,
        label: 'mood score',
        validate: validate,
      ),
      exercise: exercise.isEmpty ? null : exercise,
      measurementContext: text('context').isEmpty ? null : text('context'),
    );
  }
}

class _ParsedCheckIn {
  const _ParsedCheckIn({
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.oxygenSaturation,
    this.temperature,
    this.sleepHours,
    this.mood,
    this.exercise,
    this.measurementContext,
  });

  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? oxygenSaturation;
  final double? temperature;
  final double? sleepHours;
  final int? mood;
  final String? exercise;
  final String? measurementContext;
}
