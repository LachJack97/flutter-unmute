import 'package:unmute/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Signs in a user with the given email and password.
  /// Throws an exception if the login fails.
  Future<UserEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> logout();

  /// Checks for the current authentication status.
  /// Returns a UserEntity if a session exists, otherwise returns null.
  Future<UserEntity?> checkAuthStatus();
}
