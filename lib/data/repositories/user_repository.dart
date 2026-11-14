import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/user_profile.dart';

class UserRepository {
  const UserRepository(this._db);

  final AppDatabase _db;

  /// Finds a user by a normalized Astronaut ID or creates the local profile.
  /// The transaction and SQLite unique index prevent duplicate profiles.
  Future<UserProfile> findOrCreate({
    required String username,
    required String astronautId,
  }) async {
    final normalizedId = astronautId.trim().toUpperCase();
    final normalizedName = username.trim();
    if (normalizedId.isEmpty || normalizedName.isEmpty) {
      throw ArgumentError('Username and Astronaut ID are required.');
    }

    return _db.transaction(() async {
      final users = await _db.select(_db.users).get();
      for (final row in users) {
        if (row.astronautId?.trim().toUpperCase() == normalizedId) {
          return UserProfile(
            id: row.id,
            username: row.username,
            astronautId: row.astronautId ?? normalizedId,
          );
        }
      }

      final id = await _db
          .into(_db.users)
          .insert(
            UsersCompanion.insert(
              username: normalizedName,
              astronautId: Value(normalizedId),
              createdAt: DateTime.now(),
            ),
          );
      return UserProfile(
        id: id,
        username: normalizedName,
        astronautId: normalizedId,
      );
    });
  }
}
