import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../data/models/alert_item.dart';
import '../../../data/models/health_status.dart' show AlertSeverity;
import '../../../data/repositories/alert_repository.dart';
import '../../../data/repositories/health_data_repository.dart';

class AlertsState extends Equatable {
  const AlertsState({
    this.loading = true,
    this.alerts = const [],
    this.filter = AlertFilter.all,
    this.selectedId,
  });

  final bool loading;
  final List<AlertItem> alerts;
  final AlertFilter filter;
  final String? selectedId;

  AlertsState copyWith({
    bool? loading,
    List<AlertItem>? alerts,
    AlertFilter? filter,
    String? selectedId,
    bool clearSelectedId = false,
  }) {
    return AlertsState(
      loading: loading ?? this.loading,
      alerts: alerts ?? this.alerts,
      filter: filter ?? this.filter,
      selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
    );
  }

  AlertItem? get selected {
    final id = selectedId ?? (alerts.isNotEmpty ? alerts.first.id : null);
    if (id == null) return null;
    for (final alert in alerts) {
      if (alert.id == id) return alert;
    }
    return null;
  }

  List<AlertItem> get filtered {
    if (filter == AlertFilter.unread) {
      return alerts.where((a) => a.isUnread).toList();
    }
    if (filter == AlertFilter.critical) {
      return alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    }
    return alerts;
  }

  @override
  List<Object?> get props => [loading, alerts, filter, selectedId];
}

enum AlertFilter { all, unread, critical }

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit({
    AlertRepository? repository,
    HealthDataRepository? healthRepository,
  }) : _repo = repository ?? const AlertRepository(),
       _health = healthRepository,
       super(const AlertsState());

  final AlertRepository _repo;
  final HealthDataRepository? _health;
  StreamSubscription<DailyHealthRecord?>? _recordSub;
  StreamSubscription<List<AlertItem>>? _alertsSub;
  int? _userId;
  int _watchGeneration = 0;

  /// Clears any previous alerts until a user is bound. This prevents mock or
  /// previous-user alerts from leaking into a fresh account.
  void load() {
    _recordSub?.cancel();
    _alertsSub?.cancel();
    _recordSub = null;
    _alertsSub = null;
    _userId = null;
    _watchGeneration++;
    emit(const AlertsState(loading: false));
  }

  /// Subscribes to the current user's latest record. Alerts are only read from
  /// SQLite after that record has been finalized with the completion button.
  void bind(int userId) {
    final health = _health;
    if (health == null) {
      emit(
        state.copyWith(loading: false, alerts: const [], clearSelectedId: true),
      );
      return;
    }
    if (_userId == userId) return;

    _userId = userId;
    _watchGeneration++;
    _recordSub?.cancel();
    _alertsSub?.cancel();
    _alertsSub = null;
    emit(
      state.copyWith(loading: true, alerts: const [], clearSelectedId: true),
    );

    _recordSub = health
        // In-progress edits reopen today's record. Keep the last completed
        // record's persisted notifications visible until a new check-in is
        // completed, rather than briefly clearing the Alerts screen.
        .watchLatestCompletedRecord(userId)
        .listen(
          (record) async {
            final generation = ++_watchGeneration;
            await _alertsSub?.cancel();
            _alertsSub = null;
            if (isClosed ||
                _userId != userId ||
                generation != _watchGeneration) {
              return;
            }

            if (record == null) {
              emit(
                state.copyWith(
                  loading: false,
                  alerts: const [],
                  clearSelectedId: true,
                ),
              );
              return;
            }

            try {
              // Idempotent: re-syncing the same completed record updates the
              // existing rows and keeps their read state.
              await _repo.syncForRecord(record);
              if (isClosed ||
                  _userId != userId ||
                  generation != _watchGeneration) {
                return;
              }

              _alertsSub = _repo
                  .watchForRecord(record.id)
                  .listen(
                    (alerts) {
                      if (isClosed || generation != _watchGeneration) return;
                      final keepSelection = alerts.any(
                        (alert) => alert.id == state.selectedId,
                      );
                      emit(
                        state.copyWith(
                          loading: false,
                          alerts: alerts,
                          selectedId: keepSelection ? state.selectedId : null,
                          clearSelectedId: !keepSelection,
                        ),
                      );
                    },
                    onError: (_) {
                      if (isClosed || generation != _watchGeneration) return;
                      emit(
                        state.copyWith(
                          loading: false,
                          alerts: const [],
                          clearSelectedId: true,
                        ),
                      );
                    },
                  );
            } catch (_) {
              if (isClosed ||
                  _userId != userId ||
                  generation != _watchGeneration) {
                return;
              }
              emit(
                state.copyWith(
                  loading: false,
                  alerts: const [],
                  clearSelectedId: true,
                ),
              );
            }
          },
          onError: (_) {
            emit(
              state.copyWith(
                loading: false,
                alerts: const [],
                clearSelectedId: true,
              ),
            );
          },
        );
  }

  void setFilter(AlertFilter filter) => emit(state.copyWith(filter: filter));

  void select(String id) => emit(state.copyWith(selectedId: id));

  Future<void> markRead(String id) async {
    final next = state.alerts
        .map((a) => a.id == id ? a.copyWith(isUnread: false) : a)
        .toList();
    emit(state.copyWith(alerts: next));
    try {
      await _repo.markRead(id);
    } catch (_) {
      // Keep the local read state even if a transient database write fails.
    }
  }

  @override
  Future<void> close() {
    _recordSub?.cancel();
    _alertsSub?.cancel();
    return super.close();
  }
}
