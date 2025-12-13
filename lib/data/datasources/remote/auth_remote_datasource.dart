

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/core/errors/exceptions.dart';
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
  final FirebaseService _firebaseService;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDatasourceImpl({
    FirebaseService? firebaseService,
    GoogleSignIn? googleSignIn,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth get _auth => _firebaseService.auth;
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  @override
  Future<User> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');
      
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        print('❌ User canceled Google Sign-In');
        throw AuthenticationException ('Login dibatalkan');
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw AuthenticationException ('Gagal mendapatkan token autentikasi');
      }

      print('✅ Got authentication tokens');

      // Create credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthenticationException ('Gagal masuk ke Firebase');
      }

      print('✅ Signed in to Firebase: ${userCredential.user!.uid}');

      // Check if user document exists, create if not
      final bool userExists = await userExistsInFirestore(userCredential.user!.uid);
      
      if (!userExists) {
        print('📝 Creating new user document...');
        await createUserDocument(userCredential.user!);
      } else {
        print('✅ User document already exists');
        await updateUserLastLogin(userCredential.user!.uid);
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthenticationException (FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error during Google Sign-In: $e');
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException ('Gagal masuk dengan Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('🚪 Signing out...');
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Error during sign out: $e');
      throw AuthenticationException ('Gagal keluar: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Future<bool> userExistsInFirestore(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('❌ Error checking user existence: $e');
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

      print('✅ User document created');
    } catch (e) {
      print('❌ Error creating user document: $e');
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

      print('✅ Last login updated');
    } catch (e) {
      print('❌ Error updating last login: $e');
      // Non-critical error, don't throw
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      final User? user = getCurrentUser();
      if (user == null) {
        throw AuthenticationException ('Tidak ada pengguna yang masuk');
      }

      print('🗑️ Deleting user account: ${user.uid}');

      // Delete user data from Firestore
      await _deleteUserData(user.uid);

      // Delete user from Firebase Auth
      await user.delete();

      // Sign out from Google
      await _googleSignIn.signOut();

      print('✅ User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException during deletion: ${e.code}');
      
      if (e.code == 'requires-recent-login') {
        throw AuthenticationException (
          'Untuk keamanan, silakan login ulang sebelum menghapus akun',
        );
      }
      
      throw AuthenticationException (FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      print('❌ Error deleting account: $e');
      if (e is AuthenticationException) rethrow;
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
      
      for (var doc in schedulesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete journals
      final journalsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('journals')
          .get();
      
      for (var doc in journalsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete photos metadata
      final photosSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('photos')
          .get();
      
      for (var doc in photosSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));

      // Commit batch
      await batch.commit();

      print('✅ User data deleted from Firestore');

      // Delete photos from Storage
      await _deleteUserPhotos(uid);
    } catch (e) {
      print('❌ Error deleting user data: $e');
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
      
      for (var item in listResult.items) {
        await item.delete();
      }

      print('✅ User photos deleted from Storage');
    } catch (e) {
      print('❌ Error deleting photos: $e');
      // Non-critical, don't throw
    }
  }

  /// Re-authenticate user (needed for sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    try {
      print('🔐 Re-authenticating...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthenticationException ('Re-autentikasi dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User? user = getCurrentUser();
      if (user == null) {
        throw AuthenticationException ('Tidak ada pengguna yang masuk');
      }

      await user.reauthenticateWithCredential(credential);

      print('✅ Re-authenticated successfully');
    } catch (e) {
      print('❌ Re-authentication failed: $e');
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException ('Gagal re-autentikasi: $e');
    }
  }
}