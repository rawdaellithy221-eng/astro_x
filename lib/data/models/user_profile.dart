import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({required this.id, required this.username, required this.astronautId});

  final int id;
  final String username;
  final String astronautId;

  @override
  List<Object?> get props => [username, astronautId];
}