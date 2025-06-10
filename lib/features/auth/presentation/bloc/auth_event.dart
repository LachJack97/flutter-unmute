part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkStatus() = _AuthCheckStatusRequested;

  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = _AuthLoginRequested;

  // --- ADD THIS NEW EVENT ---
  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
  }) = _AuthSignUpRequested;

  const factory AuthEvent.logoutRequested() = _AuthLogoutRequested;
}
