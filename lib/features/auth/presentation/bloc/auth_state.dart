// lib/features/auth/presentation/bloc/auth_state.dart

part of 'auth_bloc.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.loading() = _Loading;

  // This is the single, correct line for the authenticated state.
  const factory AuthState.authenticated({required UserEntity user}) =
      _Authenticated;

  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.error({required String message}) = _Error;
}
