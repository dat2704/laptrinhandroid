part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// State for successful sign-up or other one-off success actions
class AuthSuccess extends AuthState {}

// Common state for authenticated users
abstract class Authenticated extends AuthState {
  final User firebaseUser;
  final UserModel userModel;

  const Authenticated(this.firebaseUser, this.userModel);

  @override
  List<Object?> get props => [firebaseUser, userModel];
}

// Trạng thái đăng nhập với vai trò User
class AuthenticatedUser extends Authenticated {
  const AuthenticatedUser(User firebaseUser, UserModel userModel)
      : super(firebaseUser, userModel);
}

// Trạng thái đăng nhập với vai trò Admin
class AuthenticatedAdmin extends Authenticated {
  const AuthenticatedAdmin(User firebaseUser, UserModel userModel)
      : super(firebaseUser, userModel);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
