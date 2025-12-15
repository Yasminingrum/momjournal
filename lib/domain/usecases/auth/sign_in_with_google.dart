library;

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {

  SignInWithGoogleUseCase(this.repository);
  final AuthRepository repository;

  Future<User> execute() async {
    try {
      final user = await repository.signInWithGoogle();
      return user;
    } catch (e) {
      rethrow;
    }
  }
}