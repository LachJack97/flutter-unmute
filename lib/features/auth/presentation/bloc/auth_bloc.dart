import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unmute/features/auth/domain/usecases/check_auth_status.dart';
import 'package:unmute/features/auth/domain/usecases/login_user.dart';
import 'package:unmute/features/auth/domain/usecases/logout_user.dart';
import 'package:unmute/features/auth/domain/usecases/sign_up_user.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatus _checkAuthStatus;
  final LoginUser _loginUser;
  final SignUpUser _signUpUser;
  final LogoutUser _logoutUser;

  AuthBloc({
    required CheckAuthStatus checkAuthStatus,
    required LoginUser loginUser,
    required SignUpUser signUpUser,
    required LogoutUser logoutUser,
  })  : _checkAuthStatus = checkAuthStatus,
        _loginUser = loginUser,
        _signUpUser = signUpUser,
        _logoutUser = logoutUser,
        super(const AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
      AuthAppStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await _checkAuthStatus();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user =
          await _loginUser(email: event.email, password: event.password);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _signUpUser(
        email: event.email,
        password: event.password,
      );
      // After registration, emit a success message via the error state
      // and revert to unauthenticated so they can go to the login page.
      emit(const AuthError(
          'Success! Please check your email to confirm your account.'));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _logoutUser();
    emit(const AuthUnauthenticated());
  }
}
