/// Get Current User Use Case
/// 
/// Use case untuk mendapatkan current user
/// Location: lib/domain/usecases/auth/get_current_user.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  User? execute() {
    return repository.getCurrentUser();
  }

  bool isUserLoggedIn() {
    return repository.isUserLoggedIn();
  }

  String? getUserId() {
    return repository.getUserId();
  }
}