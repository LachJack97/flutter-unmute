import 'package:unmute/features/auth/domain/repositories/auth_repository.dart';

class SignUpUser {
  final AuthRepository repository;

  SignUpUser(this.repository);

  Future<void> call({
    required String email,
    required String password,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
    );
  }
}
