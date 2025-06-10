import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unmute/features/auth/domain/entities/user_entity.dart';
import 'package:unmute/features/auth/domain/usecases/check_auth_status.dart';
import 'package:unmute/features/auth/domain/usecases/login_user.dart';
import 'package:unmute/features/auth/domain/usecases/logout_user.dart';
import 'package:unmute/features/auth/domain/usecases/sign_up_user.dart';

// These 'part' directives link this file to the generated code and other parts.
part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/// Manages the authentication state of the application, handling events for
/// login, logout, sign-up, and session status checks.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Dependencies on the use cases from the Domain Layer.
  final CheckAuthStatus _checkAuthStatus;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final SignUpUser _signUpUser;

  /// The BLoC's constructor requires the use cases to be provided.
  /// This is called Dependency Injection and makes the BLoC testable and
  /// decoupled from the data layer.
  AuthBloc({
    required CheckAuthStatus checkAuthStatus,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required SignUpUser signUpUser,
  })  : _checkAuthStatus = checkAuthStatus,
        _loginUser = loginUser,
        _logoutUser = logoutUser,
        _signUpUser = signUpUser,
        super(const AuthState.initial()) {
    // Register the event handlers for each type of event.
    on<_AuthCheckStatusRequested>(_onCheckStatus);
    on<_AuthLoginRequested>(_onLogin);
    on<_AuthSignUpRequested>(_onSignUpRequested);
    on<_AuthLogoutRequested>(_onLogout);
  }

  /// Handles the initial check to see if a user session already exists.
  Future<void> _onCheckStatus(
    _AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _checkAuthStatus();
      if (user != null) {
        emit(AuthState.authenticated(user: user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      // If checking status fails, assume unauthenticated.
      emit(const AuthState.unauthenticated());
    }
  }

  /// Handles the user login event.
  Future<void> _onLogin(
    _AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user =
          await _loginUser(email: event.email, password: event.password);
      emit(AuthState.authenticated(user: user));
    } catch (e) {
      emit(AuthState.error(
          message: e.toString().replaceFirst('Exception: ', '')));
      // After an error, revert to the unauthenticated state so the UI can
      // show the login form again.
      emit(const AuthState.unauthenticated());
    }
  }

  /// Handles the new user sign-up event.
  Future<void> _onSignUpRequested(
    _AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _signUpUser(
        email: event.email,
        password: event.password,
      );
      // After a successful sign-up, the user is not yet logged in due to
      // email confirmation. We emit a success message via the error state
      // for the UI to display, then revert to unauthenticated.
      emit(const AuthState.error(
          message:
              'Success! Please check your email to confirm your account.'));
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(
          message: e.toString().replaceFirst('Exception: ', '')));
      emit(const AuthState.unauthenticated());
    }
  }

  /// Handles the user logout event.
  Future<void> _onLogout(
    _AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _logoutUser();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      // If logout fails, we can't guarantee the user is logged out.
      // It's safer to keep them in an authenticated state but show an error.
      final currentUser = state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
      if (currentUser != null) {
        // Revert to the authenticated state.
        emit(AuthState.authenticated(user: currentUser));
      }
      // Then show the error.
      emit(AuthState.error(
          message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
