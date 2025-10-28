
part of 'user_management_bloc.dart';

@immutable
abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object> get props => [];
}

class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<UserModel> users;

  const UserManagementLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError(this.message);

  @override
  List<Object> get props => [message];
}
