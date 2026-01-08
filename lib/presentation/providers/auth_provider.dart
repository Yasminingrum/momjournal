import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';
import 'category_provider.dart';
import 'sync_provider.dart';

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
    SyncProvider? syncProvider,
    CategoryProvider? categoryProvider,
  }) : _authRepository = authRepository,
       _syncProvider = syncProvider,
       _categoryProvider = categoryProvider {
    _initialize();
  }
  final AuthRepository _authRepository;
  final SyncProvider? _syncProvider;
  final CategoryProvider? _categoryProvider;

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

  /// Sign out with auto sync
  Future<bool> signOut() async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      debugPrint('🚪 Provider: Signing out...');
      
      // ✅ AUTO SYNC CATEGORIES before logout
      if (_categoryProvider != null && _user != null) {
        debugPrint('🔄 Provider: Syncing categories before logout...');
        try {
          await _categoryProvider.syncToRemote(_user!.uid);
          debugPrint('✅ Provider: Categories synced');
        } catch (categoryError) {
          debugPrint('⚠️ Provider: Category sync failed but continuing: $categoryError');
        }
      }

      // ✅ Initialize default categories after login
      if (_categoryProvider != null && user != null) {
        debugPrint('📁 Provider: Initializing default categories...');
        try {
          final uid = _user!.uid;
            await _categoryProvider.initializeDefaultCategories(uid);
            await _categoryProvider.loadCategories(uid);
          debugPrint('✅ Provider: Categories initialized');
        } catch (categoryError) {
          debugPrint('⚠️ Provider: Category initialization failed but continuing: $categoryError');
        }
      }
      
      // ✅ AUTO SYNC DATA before logout
      if (_syncProvider != null) {
        debugPrint('🔄 Provider: Auto sync data before logout...');
        try {
          await _syncProvider.syncAll();
          debugPrint('✅ Provider: Data sync completed');
        } catch (syncError) {
          debugPrint('⚠️ Provider: Data sync failed but continuing logout: $syncError');
          // Continue with logout even if sync fails
        }
      }
      
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