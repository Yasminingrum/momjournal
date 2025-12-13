/// Get Current User Use Case
/// 
/// Use case untuk mendapatkan current user
/// Location: lib/domain/usecases/auth/get_current_user.dart
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

class GetCurrentUserUseCase {

  GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  User? execute() => repository.getCurrentUser();

  bool isUserLoggedIn() => repository.isUserLoggedIn();

  String? getUserId() => repository.getUserId();
}