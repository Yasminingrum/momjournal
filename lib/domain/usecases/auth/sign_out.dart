library;

import '../../../data/repositories/auth_repository.dart';

class SignOutUseCase {

  SignOutUseCase(this.repository);
  final AuthRepository repository;

  Future<void> execute() async {
    try {
      await repository.signOut();
    } catch (e) {
      rethrow;
    }
  }
}