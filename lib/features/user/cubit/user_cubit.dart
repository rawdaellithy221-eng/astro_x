import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_repository.dart';

class UserState extends Equatable {
  const UserState({this.loading = true, this.user});

  final bool loading;
  final UserProfile? user;

  String get username => user?.username ?? 'ASTRO_01';
  String get astronautId => user?.astronautId ?? '';
  int? get userId => user?.id;

  String get initials {
    final name = username.trim();
    if (name.isEmpty) return 'A1';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  UserState copyWith({bool? loading, UserProfile? user}) {
    return UserState(loading: loading ?? this.loading, user: user ?? this.user);
  }

  @override
  List<Object?> get props => [loading, user];
}

class UserCubit extends Cubit<UserState> {
  UserCubit({UserRepository? repository, required this.database})
    : _repository = repository ?? UserRepository(database),
      super(const UserState(loading: false));

  final AppDatabase database;
  final UserRepository _repository;

  Future<void> register(String username, String astronautId) async {
    final user = await _repository.findOrCreate(
      username: username,
      astronautId: astronautId,
    );
    if (!isClosed) emit(UserState(loading: false, user: user));
  }
}
