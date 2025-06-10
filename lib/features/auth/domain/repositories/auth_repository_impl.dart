import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unmute/features/auth/domain/entities/user_entity.dart';
import 'package:unmute/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  // We can provide the SupabaseClient, making this class easier to test.
  // If not provided, it defaults to the global instance.
  AuthRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<UserEntity?> checkAuthStatus() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser != null) {
      // Map the Supabase User model to our own UserEntity
      return UserEntity(id: currentUser.id, email: currentUser.email!);
    }
    // No active session
    return null;
  }

  @override
  Future<UserEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login failed: No user data received.');
      }

      return UserEntity(id: user.id, email: user.email!);
    } on AuthException catch (e) {
      // Catch specific Supabase auth exceptions and re-throw as a more
      // generic exception or a custom one.
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unknown error occurred during login: ${e.toString()}');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // Catch specific Supabase auth exceptions and re-throw as a more
      // generic exception or a custom one.
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unknown error occurred during sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    } catch (e) {
      throw Exception(
          'An unknown error occurred during logout: ${e.toString()}');
    }
  }
}
