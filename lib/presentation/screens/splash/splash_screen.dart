import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/datasources/remote/firebase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      // ⭐ TEST: Check Firebase Auth connection
      final currentUser = _firebaseService.currentUser;
      print('Firebase Auth status: ${currentUser != null ? "Connected" : "Not signed in"}');
      
      // ⭐ TEST: Check Firestore connection
      await _firebaseService.firestore
          .collection('test')
          .doc('connection')
          .set({'timestamp': FieldValue.serverTimestamp()});
      print('✅ Firestore connection successful');
      
      // Navigate based on auth status
      if (mounted) {
        if (currentUser != null) {
          // User is signed in -> Navigate to HomeScreen
          print('User logged in: ${currentUser.email}');
          // Navigator.pushReplacement(...HomeScreen)
        } else {
          // User not signed in -> Navigate to LoginScreen
          print('User not logged in');
          // Navigator.pushReplacement(...LoginScreen)
        }
      }
      
    } catch (e) {
      print('❌ Firebase connection error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo here
            const Icon(Icons.book, size: 80, color: Colors.pink),
            const SizedBox(height: 20),
            const Text(
              'MomJournal',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.pink),
            const SizedBox(height: 20),
            const Text('Connecting to Firebase...'),
          ],
        ),
      ),
    );
  }
}