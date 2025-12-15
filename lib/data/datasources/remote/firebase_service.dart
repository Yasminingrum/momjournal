// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service untuk mengelola koneksi dan instance Firebase
class FirebaseService {
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();

  // Firebase instances
  late FirebaseAuth? _auth;
  late FirebaseFirestore? _firestore;
  late FirebaseStorage? _storage;
  
  bool _isInitialized = false;

  /// Initialize Firebase
  /// 
  /// Harus dipanggil sebelum menggunakan Firebase services
  /// Biasanya dipanggil di main.dart
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      await Firebase.initializeApp();
      
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // Enable offline persistence untuk Firestore
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  /// Get FirebaseAuth instance
  FirebaseAuth get auth {
    _checkInitialization();
    return _auth!;
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore {
    _checkInitialization();
    return _firestore!;
  }

  /// Get Firebase Storage instance
  FirebaseStorage get storage {
    _checkInitialization();
    return _storage!;
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Get current user ID
  String? get currentUserId => _auth?.currentUser?.uid;

  /// Check if user is logged in
  bool get isUserLoggedIn => _auth?.currentUser != null;

  /// Get user collection reference
  CollectionReference get usersCollection => firestore.collection('users');

  /// Get schedules collection reference for current user
  CollectionReference? get schedulesCollection {
    if (currentUserId == null) {
      return null;
    }
    return usersCollection.doc(currentUserId).collection('schedules');
  }

  /// Get journals collection reference for current user
  CollectionReference? get journalsCollection {
    if (currentUserId == null) {
      return null;
    }
    return usersCollection.doc(currentUserId).collection('journals');
  }

  /// Get photos collection reference for current user
  CollectionReference? get photosCollection {
    if (currentUserId == null) {
      return null;
    }
    return usersCollection.doc(currentUserId).collection('photos');
  }

  /// Get storage reference for user photos
  Reference? get userPhotosRef {
    if (currentUserId == null) {
      return null;
    }
    return storage.ref().child('users/$currentUserId/photos');
  }

  /// Check if Firebase is initialized, throw if not
  void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception(
        'Firebase not initialized. Call FirebaseService().initialize() first.',
      );
    }
  }

  /// Batch write helper
  WriteBatch getBatch() => firestore.batch();

  /// Transaction helper
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler,
  ) async => firestore.runTransaction(transactionHandler);

  /// Enable/disable network for Firestore
  Future<void> enableNetwork() async {
    try {
      await firestore.enableNetwork();
      debugPrint('✅ Firestore network enabled');
    } catch (e) {
      debugPrint('❌ Failed to enable Firestore network: $e');
    }
  }

  Future<void> disableNetwork() async {
    try {
      await firestore.disableNetwork();
      debugPrint('✅ Firestore network disabled');
    } catch (e) {
      debugPrint('❌ Failed to disable Firestore network: $e');
    }
  }

  /// Clear Firestore persistence (for testing)
  Future<void> clearPersistence() async {
    try {
      await firestore.clearPersistence();
      debugPrint('✅ Firestore persistence cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear Firestore persistence: $e');
    }
  }

  /// Terminate Firebase (for testing)
  Future<void> terminate() async {
    try {
      await firestore.terminate();
      _isInitialized = false;
      debugPrint('✅ Firebase terminated');
    } catch (e) {
      debugPrint('❌ Failed to terminate Firebase: $e');
    }
  }
}

/// Firebase Error Handler
class FirebaseErrorHandler {
  // Private constructor to prevent instantiation
  FirebaseErrorHandler._();
  
  /// Convert Firebase exception to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      return _getFirestoreErrorMessage(error);
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  static String _getAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'Pengguna tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan.';
      case 'account-exists-with-different-credential':
        return 'Akun sudah ada dengan kredensial berbeda.';
      case 'invalid-credential':
        return 'Kredensial tidak valid.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return 'Terjadi kesalahan autentikasi: ${error.message}';
    }
  }

  static String _getFirestoreErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Akses ditolak. Periksa izin Anda.';
      case 'unavailable':
        return 'Layanan tidak tersedia. Coba lagi nanti.';
      case 'not-found':
        return 'Data tidak ditemukan.';
      case 'already-exists':
        return 'Data sudah ada.';
      case 'resource-exhausted':
        return 'Kuota terlampaui. Coba lagi nanti.';
      case 'failed-precondition':
        return 'Kondisi tidak terpenuhi.';
      case 'aborted':
        return 'Operasi dibatalkan.';
      case 'out-of-range':
        return 'Nilai di luar jangkauan.';
      case 'unimplemented':
        return 'Fitur belum tersedia.';
      case 'internal':
        return 'Kesalahan internal server.';
      case 'data-loss':
        return 'Kehilangan data. Hubungi dukungan.';
      case 'unauthenticated':
        return 'Silakan login terlebih dahulu.';
      default:
        return 'Terjadi kesalahan: ${error.message}';
    }
  }
}

/// Firebase Connection Monitor
class FirebaseConnectionMonitor {
  // Private constructor to prevent instantiation
  FirebaseConnectionMonitor._();
  
  static Stream<bool> get connectionStream => FirebaseService()
        .firestore
        .collection('.info')
        .doc('connected')
        .snapshots()
        .map((snapshot) => snapshot.exists && snapshot.data()?['connected'] == true);

  static Future<bool> checkConnection() async {
    try {
      final snapshot = await FirebaseService()
          .firestore
          .collection('.info')
          .doc('connected')
          .get();
      
      return snapshot.exists && snapshot.data()?['connected'] == true;
    } catch (e) {
      return false;
    }
  }
}