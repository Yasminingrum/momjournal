/// Sign In With Google Use Case
/// 
/// Use case untuk Google Sign-In
/// Location: lib/domain/usecases/auth/sign_in_with_google.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<User> execute() async {
    try {
      final user = await repository.signInWithGoogle();
      print('✅ UseCase: User signed in: ${user.email}');
      return user;
    } catch (e) {
      print('❌ UseCase: Sign in failed: $e');
      rethrow;
    }
  }
}