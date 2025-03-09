import 'package:flutter/material.dart';
import '../../../../core/constants/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _fullNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _fullNameController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    setState(() {
      _isFormValid = email.isNotEmpty &&
          _isValidEmail(email) &&
          password.isNotEmpty &&
          password.length >= 6 &&
          fullName.isNotEmpty;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  void _handleSignUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Email alanı boş bırakılamaz');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Geçerli bir email adresi giriniz');
      return;
    }

    if (fullName.isEmpty) {
      setState(() => _errorText = 'Ad Soyad alanı boş bırakılamaz');
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

    // Kayıt işlemini başlat
    context.read<AuthCubit>().signUp(
          email: email,
          password: password,
          fullName: fullName,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          setState(() => _isLoading = false);
          // Başarılı kayıt bildirimi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Hesabınız başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          // Kısa bir gecikme sonrası ana sayfaya yönlendir
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacementNamed('/home');
          });
        } else if (state.status == AuthStatus.error) {
          setState(() {
            _isLoading = false;
            _errorText = state.errorMessage;
          });
          // Hata bildirimi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state.status == AuthStatus.loading) {
          setState(() => _isLoading = true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Logo Icon
                        const Icon(
                          Icons.local_florist_outlined,
                          size: 60,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.register,
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
                          prefixIcon: const Text('@'),
                        ),
                        const SizedBox(height: 16),
                        // Full Name TextField
                        _CustomTextField(
                          controller: _fullNameController,
                          hintText: AppText.fullName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        const SizedBox(height: 16),
                        // Password TextField
                        _CustomTextField(
                          controller: _passwordController,
                          hintText: l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          isPassword: true,
                          errorText: _errorText,
                        ),
                        const SizedBox(height: 24),
                        // Signup Button
                        ElevatedButton(
                          onPressed: _isLoading || !_isFormValid
                              ? null
                              : _handleSignUp,
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
                          child: Text(
                              _isLoading ? 'Kayıt yapılıyor...' : l10n.signUp),
                        ),
                      ],
                    ),
                    // Back Button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppText.back,
                        style: const TextStyle(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget prefixIcon;
  final bool isPassword;
  final String? errorText;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
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
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: prefixIcon,
          ),
          suffixIcon: errorText != null
              ? Container(
                  margin: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
