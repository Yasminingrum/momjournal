// ignore_for_file: lines_longer_than_80_chars

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '/core/errors/exceptions.dart';
import '../../models/user_model.dart';
import '../local/hive_database.dart';
import 'firebase_service.dart';

/// Interface untuk Auth Remote Datasource
abstract class AuthRemoteDatasource {
  /// Sign in dengan Google
  Future<User> signInWithGoogle();
  
  /// Sign out
  Future<void> signOut();
  
  /// Get current user
  User? getCurrentUser();
  
  /// Check if user exists in Firestore
  Future<bool> userExistsInFirestore(String uid);
  
  /// Create user document in Firestore
  Future<void> createUserDocument(User user);
  
  /// Update user last login
  Future<void> updateUserLastLogin(String uid);
  
  /// Delete user account
  Future<void> deleteUserAccount();
}

/// Implementation dari Auth Remote Datasource
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {

  AuthRemoteDatasourceImpl({
    FirebaseService? firebaseService,
    GoogleSignIn? googleSignIn,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn();
  final FirebaseService _firebaseService;
  final GoogleSignIn _googleSignIn;

  FirebaseAuth get _auth => _firebaseService.auth;
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  @override
  Future<User> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In...');
      
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('User canceled Google Sign-In');
        throw const AuthenticationException ('Login dibatalkan');
      }

      debugPrint('Google account selected: ${googleUser.email}');

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw const AuthenticationException ('Gagal mendapatkan token autentikasi');
      }

      debugPrint('Got authentication tokens');

      // Create credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      // FIXED: Using workaround for PigeonUserDetails bug
      await _auth.signInWithCredential(credential);
      final User? user = _auth.currentUser; 

      if (user == null) {
        throw const AuthenticationException ('Gagal masuk ke Firebase');
      }

      debugPrint('Signed in to Firebase: ${user.uid}');


      // ✅ CRITICAL: Save user to Hive local database
      try {
        final hiveDb = HiveDatabase();
        final userBox = hiveDb.userBox;
        
        final existingUser = userBox.get(user.uid);
        
        if (existingUser == null) {
          // Create new user model
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          await userBox.put(user.uid, newUser);
          debugPrint('✅ New user model created in Hive');
        } else {
          // Update existing user
          final updatedUser = existingUser.copyWith(
            email: user.email ?? existingUser.email,
            displayName: user.displayName ?? existingUser.displayName,
            photoUrl: user.photoURL ?? existingUser.photoUrl,
            lastLoginAt: DateTime.now(),
          );
          await userBox.put(user.uid, updatedUser);
          debugPrint('✅ User model updated in Hive');
        }
      } catch (hiveError) {
        debugPrint('❌ Failed to save user to Hive: $hiveError');
        // Don't throw - login can continue even if Hive save fails
      }
      // Check if user document exists, create if not
      final bool userExists = await userExistsInFirestore(user.uid);
      
      if (!userExists) {
        debugPrint('Creating new user document...');
        await createUserDocument(user);
      } else {
        debugPrint('User document already exists');
        await updateUserLastLogin(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthenticationException (FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException ('Gagal masuk dengan Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      debugPrint('Signing out...');
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      debugPrint('Signed out successfully');
    } catch (e) {
      debugPrint('Error during sign out: $e');
      throw AuthenticationException ('Gagal keluar: $e');
    }
  }

  @override
  User? getCurrentUser() => _auth.currentUser;

  @override
  Future<bool> userExistsInFirestore(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  @override
  Future<void> createUserDocument(User user) async {
    try {
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'childProfile': null, // Will be set up later
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);

      debugPrint('User document created');
    } catch (e) {
      debugPrint('Error creating user document: $e');
      throw DatabaseException('Gagal membuat profil pengguna: $e');
    }
  }

  @override
  Future<void> updateUserLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      debugPrint('Last login updated');
    } catch (e) {
      debugPrint('Error updating last login: $e');
      // Non-critical error, don't throw
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        throw const AuthenticationException ('Tidak ada pengguna yang masuk');
      }

      debugPrint('Deleting user account: ${user.uid}');

      // Delete user data from Firestore
      await _deleteUserData(user.uid);

      // Delete user from Firebase Auth
      await user.delete();

      // Sign out from Google
      await _googleSignIn.signOut();

      debugPrint('User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during deletion: ${e.code}');
      
      if (e.code == 'requires-recent-login') {
        throw const AuthenticationException (
          'Untuk keamanan, silakan login ulang sebelum menghapus akun',
        );
      }
      
      throw AuthenticationException (FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('Error deleting account: $e');
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException ('Gagal menghapus akun: $e');
    }
  }

  /// Helper: Delete all user data from Firestore
  Future<void> _deleteUserData(String uid) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Delete schedules
      final schedulesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .get();
      
      for (final doc in schedulesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete journals
      final journalsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('journals')
          .get();
      
      for (final doc in journalsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete photos metadata
      final photosSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('photos')
          .get();
      
      for (final doc in photosSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));

      // Commit batch
      await batch.commit();

      debugPrint('User data deleted from Firestore');

      // Delete photos from Storage
      await _deleteUserPhotos(uid);
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      throw DatabaseException('Gagal menghapus data pengguna: $e');
    }
  }

  /// Helper: Delete user photos from Firebase Storage
  Future<void> _deleteUserPhotos(String uid) async {
    try {
      final storageRef = _firebaseService.storage
          .ref()
          .child('users/$uid/photos');
      
      final listResult = await storageRef.listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }

      debugPrint('User photos deleted from Storage');
    } catch (e) {
      debugPrint('Error deleting photos: $e');
      // Non-critical, don't throw
    }
  }

  /// Re-authenticate user (needed for sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    try {
      debugPrint('Re-authenticating...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw const AuthenticationException ('Re-autentikasi dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User? user = getCurrentUser();
      if (user == null) {
        throw const AuthenticationException ('Tidak ada pengguna yang masuk');
      }

      await user.reauthenticateWithCredential(credential);

      debugPrint('Re-authenticated successfully');
    } catch (e) {
      debugPrint('Re-authentication failed: $e');
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException ('Gagal re-autentikasi: $e');
    }
  }
}