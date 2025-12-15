/// Auth Repository
/// 
/// Repository layer for authentication operations
/// Location: lib/data/repositories/auth_repository.dart
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '/core/errors/exceptions.dart';
import '../datasources/remote/auth_remote_datasource.dart';


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

  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;
  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<User> signInWithGoogle() async {
    try {
      debugPrint('🔐 Repository: Starting Google Sign-In...');
      final user = await _remoteDatasource.signInWithGoogle();
      debugPrint('✅ Repository: Sign-In successful');
      return user;
    } on AuthorizationException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Repository: Sign-In failed: $e');
      throw AuthorizationException('Gagal masuk: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      debugPrint('🚪 Repository: Signing out...');
      await _remoteDatasource.signOut();
      debugPrint('✅ Repository: Sign-Out successful');
    } on AuthorizationException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Repository: Sign-Out failed: $e');
      throw AuthorizationException('Gagal keluar: $e');
    }
  }

  @override
  User? getCurrentUser() => _remoteDatasource.getCurrentUser();

  @override
  bool isUserLoggedIn() => getCurrentUser() != null;

  @override
  String? getUserId() => getCurrentUser()?.uid;

  @override
  Future<void> deleteAccount() async {
    try {
      debugPrint('🗑️ Repository: Deleting account...');
      await _remoteDatasource.deleteUserAccount();
      debugPrint('✅ Repository: Account deleted');
    } on AuthorizationException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Repository: Failed to delete account: $e');
      throw AuthorizationException('Gagal menghapus akun: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();
}