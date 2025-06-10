import 'package:unmute/features/auth/domain/entities/user_entity.dart';
import 'package:unmute/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<UserEntity> call(
      {required String email, required String password}) async {
    return await repository.loginWithEmailAndPassword(
        email: email, password: password);
  }
}

// This use case handles the login functionality for the user.
// It takes an email and password as parameters and uses the AuthRepository
