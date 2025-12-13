/// Sign Out Use Case
/// 
/// Use case untuk logout
/// Location: lib/domain/usecases/auth/sign_out.dart
library;

import '../../../data/repositories/auth_repository.dart';

class SignOutUseCase {

  SignOutUseCase(this.repository);
  final AuthRepository repository;

  Future<void> execute() async {
    try {
      await repository.signOut();
      print('✅ UseCase: User signed out successfully');
    } catch (e) {
      print('❌ UseCase: Sign out failed: $e');
      rethrow;
    }
  }
}