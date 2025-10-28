
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/user_model.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UserRepository _userRepository;

  UserManagementBloc({required UserRepository userRepository}) 
      : _userRepository = userRepository,
        super(UserManagementLoading()) {

    on<LoadUsers>(_onLoadUsers);
    on<UpdateUserRole>(_onUpdateUserRole);
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserManagementState> emit) async {
    emit(UserManagementLoading());
    try {
      final users = await _userRepository.getAllUsers();
      emit(UserManagementLoaded(users));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  void _onUpdateUserRole(UpdateUserRole event, Emitter<UserManagementState> emit) async {
    try {
      await _userRepository.updateUserRole(event.userId, event.newRole);
      // Sau khi cập nhật, tải lại danh sách người dùng
      add(LoadUsers());
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }
}
