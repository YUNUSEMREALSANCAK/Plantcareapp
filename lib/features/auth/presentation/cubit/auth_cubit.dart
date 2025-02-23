import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit(this._authRepository) : super(AuthState.initial()) {
    // Kullanıcı durumunu dinle
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    });
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
      emit(AuthState.authenticated(userCredential.user!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(AuthState.unauthenticated());
  }
}
