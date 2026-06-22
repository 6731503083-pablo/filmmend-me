import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';

import '../core/firebase/google_auth_config.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Firebase user (null if logged out)
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email & password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _getUserModel(credential.user!);
  }

  /// Register with email, password & display name
  Future<UserModel> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;
    await user.updateDisplayName(displayName.trim());
    await user.sendEmailVerification();

    // Create user document in Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrl': null,
    });

    return UserModel(
      uid: user.uid,
      email: email.trim(),
      displayName: displayName.trim(),
      photoUrl: null,
      createdAt: DateTime.now(),
    );
  }

  /// Sign in with Google. Returns null when the user cancels the picker.
  /// Google accounts skip email verification.
  Future<UserModel?> signInWithGoogle() async {
    if (kIsWeb) {
      final credential = await _auth.signInWithPopup(GoogleAuthProvider());
      return _ensureUserDocument(credential.user!);
    }

    final googleSignIn = _createGoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return _ensureUserDocument(userCredential.user!);
  }

  GoogleSignIn _createGoogleSignIn() {
    const scopes = ['email', 'profile'];
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        GoogleAuthConfig.webClientId.isNotEmpty) {
      return GoogleSignIn(
        clientId: GoogleAuthConfig.webClientId,
        scopes: scopes,
      );
    }
    return GoogleSignIn(scopes: scopes);
  }

  Future<UserModel> _ensureUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      final displayName = _googleDisplayName(user);
      await userDoc.set({
        'displayName': displayName,
        'email': user.email?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': user.photoURL,
      });
      return UserModel(
        uid: user.uid,
        email: user.email?.trim() ?? '',
        displayName: displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
    }

    return UserModel.fromFirestore(snapshot);
  }

  String _googleDisplayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Film Lover';
  }

  /// Resend email verification
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found. Please log in again.',
      );
    }
    await user.sendEmailVerification();
  }

  /// Reload current user to refresh emailVerified and profile fields
  Future<User?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    return _auth.currentUser;
  }

  /// Sign out (signs out of both Firebase Auth and Google Sign-In)
  Future<void> signOut() async {
    try {
      await _createGoogleSignIn().signOut();
    } catch (_) {
      // Google Sign-In may not be active; proceed with Firebase sign-out.
    }
    await _auth.signOut();
  }

  /// Delete account and associated data.
  /// Auth user is deleted first so a failed delete does not leave an
  /// orphaned account whose Firestore data has already been wiped.
  Future<void> deleteAccountAndData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found.',
      );
    }
    final userDoc = _firestore.collection('users').doc(user.uid);
    await user.delete();
    await _deleteCollection(userDoc.collection('watchlist'));
    await userDoc.delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection, {
    int batchSize = 200,
  }) async {
    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Get UserModel from Firebase User (reads Firestore for extra fields)
  Future<UserModel> _getUserModel(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    // Fallback if no Firestore doc yet (e.g. legacy user)
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Film Lover',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Get current user model (call when you need fresh data)
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    return _getUserModel(user);
  }

  /// Format Firebase Auth error codes into user-friendly messages
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email. Try signing in with email instead.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
