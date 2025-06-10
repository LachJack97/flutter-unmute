import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the app starts to check the initial auth status.
class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

/// Dispatched when the user taps the login button.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Dispatched when the user taps the register button.
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

/// Dispatched when the user taps the logout button.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
