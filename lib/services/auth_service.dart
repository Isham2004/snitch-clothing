import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'firebase_error_handler.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AppException('Unable to create account. Please try again.');
      }
      try {
        await user.updateDisplayName(name.trim());
      } catch (e) {
        debugPrint('[Auth] updateDisplayName failed: $e');
      }

      final profile = UserProfile(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: '',
        address: '',
        avatarUrl: '',
      );

      try {
        await _firestore.collection('users').doc(user.uid).set({
          ...profile.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('[Auth] Profile doc write failed (will retry later): $e');
      }

      return profile;
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorHandler.fromAuthException(e));
    }
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AppException('Sign in failed. Please try again.');
      }
      return await _ensureProfile(user);
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorHandler.fromAuthException(e));
    }
  }

  Future<UserProfile> _ensureProfile(User user) async {
    final fallback = UserProfile(
      id: user.uid,
      name: user.displayName ?? (user.email?.split('@').first ?? 'User'),
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      address: '',
      avatarUrl: user.photoURL ?? '',
    );
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final snap = await docRef.get();
      if (snap.exists && snap.data() != null) {
        return UserProfile.fromMap(user.uid, snap.data()!);
      }
      try {
        await docRef.set({
          ...fallback.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('[Auth] Failed to create profile doc: $e');
      }
      return fallback;
    } catch (e) {
      debugPrint('[Auth] _ensureProfile read failed: $e');
      return fallback;
    }
  }

  Future<UserProfile?> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _ensureProfile(user);
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorHandler.fromAuthException(e));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AppException('You must be signed in to change your password.');
    }
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorHandler.fromAuthException(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
