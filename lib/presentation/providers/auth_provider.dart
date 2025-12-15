import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';

/// Enum untuk auth state
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Auth Provider using ChangeNotifier
class AuthProvider with ChangeNotifier {

  AuthProvider({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    _initialize();
  }
  final AuthRepository _authRepository;

  // State
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;
  String? get userPhotoUrl => _user?.photoURL;

  /// Initialize provider - check current auth state
  void _initialize() {
    _user = _authRepository.getCurrentUser();
    _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      _state = user != null ? AuthState.authenticated : AuthState.unauthenticated;
      notifyListeners();
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      debugPrint('🔐 Provider: Starting Google Sign-In...');
      final user = await _authRepository.signInWithGoogle();
      
      _user = user;
      _setState(AuthState.authenticated);
      
      debugPrint('✅ Provider: Sign-In successful');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Provider: AuthException: $e');
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    } catch (e) {
      debugPrint('❌ Provider: Unexpected error: $e');
      _errorMessage = 'Terjadi kesalahan tak terduga';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      debugPrint('🚪 Provider: Signing out...');
      await _authRepository.signOut();
      
      _user = null;
      _setState(AuthState.unauthenticated);
      
      debugPrint('✅ Provider: Sign-Out successful');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Provider: Sign-Out failed: $e');
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    } catch (e) {
      debugPrint('❌ Provider: Unexpected error during sign-out: $e');
      _errorMessage = 'Gagal keluar';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      debugPrint('🗑️ Provider: Deleting account...');
      await _authRepository.deleteAccount();
      
      _user = null;
      _setState(AuthState.unauthenticated);
      
      debugPrint('✅ Provider: Account deleted');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Provider: Delete account failed: $e');
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    } catch (e) {
      debugPrint('❌ Provider: Unexpected error deleting account: $e');
      _errorMessage = 'Gagal menghapus akun';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }

  /// Set state and notify listeners
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Check if user is logged in
  bool checkAuthStatus() {
    _user = _authRepository.getCurrentUser();
    _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    notifyListeners();
    return _user != null;
  }
}