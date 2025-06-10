// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:unmute/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The initial state before any authentication checks have been made.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// The state when an async authentication operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The state when the user is successfully authenticated.
/// It holds the authenticated user's data.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// The state when there is no authenticated user.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// The state when an error has occurred during an authentication process.
/// It holds the error message to be displayed to the user.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
