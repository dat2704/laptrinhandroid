
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/domain/models/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(AuthInitial()) {
    _userSubscription = _authRepository.user.listen((firebaseUser) {
      add(_AuthStateChanged(firebaseUser));
    });

    on<_AuthStateChanged>(_onAuthStateChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  void _onAuthStateChanged(
      _AuthStateChanged event, Emitter<AuthState> emit) async {
    final firebaseUser = event.firebaseUser;
    try {
      if (firebaseUser != null) {
        final userModel = await _userRepository.getUserData(firebaseUser.uid);

        if (userModel != null) {
          if (userModel.role == 'admin') {
            emit(AuthenticatedAdmin(firebaseUser, userModel));
          } else {
            emit(AuthenticatedUser(firebaseUser, userModel));
          }
        } else {
          await _authRepository.signOut();
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError("Lỗi khi kiểm tra trạng thái đăng nhập: ${e.toString()}"));
      emit(Unauthenticated());
    }
  }

  void _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(email: event.email, password: event.password);
      // The _onAuthStateChanged listener will handle the success state
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  void _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(email: event.email, password: event.password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onProfileUpdateRequested(
      ProfileUpdateRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(AuthLoading());
      try {
        final updateData = <String, dynamic>{};
        if (event.displayName != null) {
          updateData['displayName'] = event.displayName;
        }
        if (event.address != null) {
          updateData['address'] = event.address;
        }

        if (updateData.isNotEmpty) {
          await _userRepository.updateUserData(event.userId, updateData);
        }

        final updatedUserModel = await _userRepository.getUserData(event.userId);

        if (updatedUserModel != null) {
          if (updatedUserModel.role == 'admin') {
            emit(AuthenticatedAdmin(currentState.firebaseUser, updatedUserModel));
          } else {
            emit(AuthenticatedUser(currentState.firebaseUser, updatedUserModel));
          }
        } else {
          emit(const AuthError("Không thể tải lại dữ liệu người dùng sau khi cập nhật."));
          emit(currentState);
        }
      } catch (e) {
        emit(AuthError("Lỗi khi cập nhật hồ sơ: ${e.toString()}"));
        emit(currentState);
      }
    }
  }

  void _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
