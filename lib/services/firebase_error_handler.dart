import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String fromAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Enable it in Firebase Console.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }

  static String fromException(Object e) {
    if (e is FirebaseAuthException) return fromAuthException(e);
    if (e is FirebaseException) {
      return e.message ?? 'Firebase error (${e.code}).';
    }
    return e.toString();
  }
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
