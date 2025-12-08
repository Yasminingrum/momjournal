/// Auth Repository
/// 
/// Repository layer for authentication operations
/// Location: lib/data/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../../core/errors/exceptions.dart';

/// Interface untuk Auth Repository
abstract class AuthRepository {
  /// Sign in with Google
  Future<User> signInWithGoogle();
  
  /// Sign out
  Future<void> signOut();
  
  /// Get current user
  User? getCurrentUser();
  
  /// Check if user is logged in
  bool isUserLoggedIn();
  
  /// Get user ID
  String? getUserId();
  
  /// Delete account
  Future<void> deleteAccount();
  
  /// Stream untuk auth state changes
  Stream<User?> get authStateChanges;
}

/// Implementation dari Auth Repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<User> signInWithGoogle() async {
    try {
      print('🔐 Repository: Starting Google Sign-In...');
      final user = await _remoteDatasource.signInWithGoogle();
      print('✅ Repository: Sign-In successful');
      return user;
    } on AuthException {
      rethrow;
    } catch (e) {
      print('❌ Repository: Sign-In failed: $e');
      throw AuthException('Gagal masuk: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('🚪 Repository: Signing out...');
      await _remoteDatasource.signOut();
      print('✅ Repository: Sign-Out successful');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('❌ Repository: Sign-Out failed: $e');
      throw AuthException('Gagal keluar: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return _remoteDatasource.getCurrentUser();
  }

  @override
  bool isUserLoggedIn() {
    return getCurrentUser() != null;
  }

  @override
  String? getUserId() {
    return getCurrentUser()?.uid;
  }

  @override
  Future<void> deleteAccount() async {
    try {
      print('🗑️ Repository: Deleting account...');
      await _remoteDatasource.deleteUserAccount();
      print('✅ Repository: Account deleted');
    } on AuthException {
      rethrow;
    } catch (e) {
      print('❌ Repository: Failed to delete account: $e');
      throw AuthException('Gagal menghapus akun: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    // This will be provided by FirebaseAuth directly
    return FirebaseAuth.instance.authStateChanges();
  }
}