
part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện nội bộ để xử lý thay đổi từ Firebase Auth stream
class _AuthStateChanged extends AuthEvent {
  final User? firebaseUser;

  const _AuthStateChanged(this.firebaseUser);

  @override
  List<Object?> get props => [firebaseUser];
}

// Sự kiện khi người dùng yêu cầu đăng nhập
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// Sự kiện khi người dùng yêu cầu đăng ký
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// Sự kiện khi người dùng yêu cầu đăng xuất
class SignOutRequested extends AuthEvent {}

// Sự kiện khi người dùng yêu cầu cập nhật hồ sơ
class ProfileUpdateRequested extends AuthEvent {
  final String userId;
  final String? displayName;
  final String? address;

  const ProfileUpdateRequested({
    required this.userId,
    this.displayName,
    this.address,
  });

  @override
  List<Object?> get props => [userId, displayName, address];
}
