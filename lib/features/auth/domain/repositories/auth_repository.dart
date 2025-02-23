import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profil bilgilerini güncelle
      await userCredential.user?.updateDisplayName(fullName);

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Bu email adresi zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz email adresi.';
        case 'weak-password':
          return 'Şifre çok zayıf.';
        case 'user-not-found':
          return 'Kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Hatalı şifre.';
        default:
          return 'Bir hata oluştu: ${e.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu.';
  }
}
