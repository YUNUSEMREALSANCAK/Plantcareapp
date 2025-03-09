import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit(this._authRepository) : super(AuthState.initial()) {
    // Uygulama başladığında mevcut kullanıcı durumunu kontrol et
    _checkCurrentUser();

    // Kullanıcı durumunu dinle
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    });
  }

  // Mevcut kullanıcı durumunu kontrol et
  Future<void> _checkCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Kullanıcı oturumu açık
      emit(AuthState.authenticated(currentUser));
    } else {
      // Kullanıcı oturumu kapalı
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(AuthState.loading());
    try {
      final userCredential = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      // Kullanıcı profil bilgilerini güncelle
      await userCredential.user?.updateDisplayName(fullName);

      // Kullanıcı e-posta doğrulaması gönder
      await userCredential.user?.sendEmailVerification();

      emit(AuthState.authenticated(userCredential.user!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthState.loading());
    try {
      final userCredential = await _authRepository.signIn(
        email: email,
        password: password,
      );

      // Kullanıcı kimliği doğrulandı
      emit(AuthState.authenticated(userCredential.user!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  // Kullanıcının kimlik doğrulama durumunu kontrol et
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }
}
