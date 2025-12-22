library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '/core/errors/exceptions.dart';
import '../datasources/local/hive_database.dart';
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
    HiveDatabase? hiveDatabase,
  })  : _remoteDatasource = remoteDatasource,
        _hiveDatabase = hiveDatabase ?? HiveDatabase();
  final AuthRemoteDatasource _remoteDatasource;
  final HiveDatabase _hiveDatabase;

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
      debugPrint('🚪 Repository: Starting sign-out process...');
      
      // Step 1: Sign out from Firebase & Google
      debugPrint('📤 Repository: Signing out from Firebase & Google...');
      await _remoteDatasource.signOut();
      debugPrint('✅ Repository: Remote sign-out successful');
      
      // Step 2: Clear all local data (Hive)
      debugPrint('🗑️ Repository: Clearing local data...');
      await _clearLocalData();
      debugPrint('✅ Repository: Local data cleared');
      
      debugPrint('✅ Repository: Sign-Out completed successfully');
    } on AuthorizationException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Repository: Sign-Out failed: $e');
      throw AuthorizationException('Gagal keluar: $e');
    }
  }
  
  /// Clear all local data from Hive database
  /// 
  /// This ensures user privacy and prevents data leakage between accounts
  Future<void> _clearLocalData() async {
    try {
      // Clear all Hive boxes
      await _hiveDatabase.clearAllData();
      
      debugPrint('✓ All local data cleared successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Failed to clear some local data: $e');
      // Don't throw error here - logout should still succeed even if
      // local data clearing fails (user can manually clear app data)
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