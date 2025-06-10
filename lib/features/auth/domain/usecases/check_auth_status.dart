import 'package:unmute/features/auth/domain/entities/user_entity.dart';
import 'package:unmute/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<UserEntity?> call() async {
    return await repository.checkAuthStatus();
  }
}
// This use case checks the authentication status of the user.
// It returns a UserEntity if the user is authenticated, or null if not.
// It uses the AuthRepository to perform the actual check.
// This allows for easy testing and separation of concerns in the codebase.
// The use case can be injected into the AuthBloc or any other part of the app
// that needs to check the authentication status.
// This is useful for initializing the app state, redirecting users,
// or displaying the appropriate UI based on the user's authentication status.
