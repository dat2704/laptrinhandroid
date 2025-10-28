
part of 'user_management_bloc.dart';

@immutable
abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện để tải danh sách người dùng
class LoadUsers extends UserManagementEvent {}

// Sự kiện để cập nhật vai trò của người dùng
class UpdateUserRole extends UserManagementEvent {
  final String userId;
  final String newRole;

  const UpdateUserRole(this.userId, this.newRole);

  @override
  List<Object> get props => [userId, newRole];
}
