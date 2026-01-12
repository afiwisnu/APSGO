import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Untuk web, bisa skip clientId jika tidak mau konfigurasi OAuth
    // Atau tambahkan clientId dari Google Console jika diperlukan
    scopes: ['email'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream untuk monitoring auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login dengan email dan password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register user baru
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    if (kIsWeb) {
      // Di web, hanya sign out dari Firebase
      await _auth.signOut();
    } else {
      // Di mobile, sign out dari Firebase dan Google
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    }
  }

  // Login dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Di web, Google Sign In memerlukan konfigurasi tambahan
      // Jadi untuk sementara di web, lempar error yang informatif
      if (kIsWeb) {
        throw 'Login dengan Google belum tersedia untuk versi web. Silakan gunakan email dan password.';
      }

      // Trigger the authentication flow (hanya untuk mobile)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw 'Login dibatalkan';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      throw e.toString();
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
