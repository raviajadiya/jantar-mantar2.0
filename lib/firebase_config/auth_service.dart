import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Authentication (e.g., Anonymous sign-in)
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get currentUid => _auth.currentUser?.uid;

  /// Anonymous Sign In
  Future<User?> signInAnonymously() async {
    try {
      if (_auth.currentUser != null) {
        debugPrint("[AuthService] Already signed in with UID: ${_auth.currentUser?.uid}");
        return _auth.currentUser;
      }

      debugPrint("[AuthService] Attempting Anonymous Sign-In...");
      UserCredential userCredential = await _auth.signInAnonymously();

      debugPrint("[AuthService] Signed in successfully with UID: ${userCredential.user?.uid}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        debugPrint(
          "[AuthService] Anonymous auth enable nathi! Firebase Console -> Authentication -> Sign-in method ma jaine Anonymous enable karo.",
        );
      } else {
        debugPrint("[AuthService] FirebaseAuthException [${e.code}]: ${e.message}");
      }
      return null;
    } catch (e) {
      debugPrint("[AuthService] Error during anonymous sign in: $e");
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint("[AuthService] User signed out.");
    } catch (e) {
      debugPrint("[AuthService] Sign out error: $e");
    }
  }
}

