// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication status when the app starts.
class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

/// Event triggered when the user attempts to log in.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when the user attempts to register.
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

/// Event triggered when the user logs out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
