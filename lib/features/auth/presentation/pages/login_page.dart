import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import 'signup_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isFormValid = email.isNotEmpty &&
          _isValidEmail(email) &&
          password.isNotEmpty &&
          password.length >= 6;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Email alanı boş bırakılamaz');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Geçerli bir email adresi giriniz');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorText = 'Şifre alanı boş bırakılamaz');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorText = 'Şifre en az 6 karakter olmalıdır');
      return;
    }

    // Hata mesajını temizle
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    // Login işlemini başlat
    context
        .read<AuthCubit>()
        .signIn(
          email: email,
          password: password,
        )
        .then((_) {
      // AuthCubit içinde durum değişikliği dinlendiği için
      // burada bir şey yapmaya gerek yok
      setState(() => _isLoading = false);
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _errorText = _getErrorMessage(e);
      });
      // Hata bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorText ?? 'Giriş yapılırken bir hata oluştu'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  String _getErrorMessage(dynamic e) {
    final l10n = AppLocalizations.of(context)!;
    if (e is FirebaseAuthException) {
      if (e.code == 'user-not-found') {
        return 'Bu email ile kayıtlı kullanıcı bulunamadı';
      } else if (e.code == 'wrong-password') {
        return 'Hatalı şifre';
      } else {
        return 'Kimlik doğrulama hatası: ${e.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (state.status == AuthStatus.error) {
          setState(() {
            _isLoading = false;
            _errorText = state.errorMessage;
          });
          // Hata bildirimi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  state.errorMessage ?? 'Giriş yapılırken bir hata oluştu'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo Icon
                const Icon(
                  Icons.eco_outlined,
                  size: 60,
                  color: AppColors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.login,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Email TextField
                _CustomTextField(
                  controller: _emailController,
                  hintText: l10n.email,
                  prefixIcon: const Text(
                    '@',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password TextField
                _CustomTextField(
                  controller: _passwordController,
                  hintText: l10n.password,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textLight,
                  ),
                  isPassword: true,
                  errorText: _errorText,
                ),
                const SizedBox(height: 24),
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading || !_isFormValid ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isLoading ? 'Giriş yapılıyor...' : l10n.login),
                ),
                const SizedBox(height: 16),
                // Back Button
                TextButton(
                  onPressed: () {},
                  child: Text(
                    AppText.back,
                    style: const TextStyle(
                      color: AppColors.white,
                    ),
                  ),
                ),

                // Sign Up Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final String? errorText;

  const _CustomTextField({
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textFieldBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: prefixIcon,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorText: errorText,
        ),
        controller: controller,
      ),
    );
  }
}
