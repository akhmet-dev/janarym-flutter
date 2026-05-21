import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_text.dart';
import '../providers/onboarding_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = OnboardingProvider.shared.currentLanguage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.15),
                      ),
                      child: const Icon(Icons.visibility, color: AppTheme.primary, size: 40),
                    ),
                    const SizedBox(height: 20),

                    Text('Жанарым', style: AppTheme.heading1),
                    const SizedBox(height: 8),
                    Text(
                      AppText.pick('Дауыстық AI ассистент', 'Голосовой AI ассистент', language: lang),
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 40),

                    // Name field (signup only)
                    if (!_isLogin)
                      _buildTextField(
                        controller: _nameController,
                        hint: AppText.pick('Атыңыз', 'Ваше имя', language: lang),
                        icon: Icons.person_outline,
                      ),
                    if (!_isLogin) const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      hint: AppText.pick('Құпия сөз', 'Пароль', language: lang),
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 8),

                    // Error message
                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          auth.errorMessage!,
                          style: AppTheme.caption.copyWith(color: AppTheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : Text(
                                _isLogin
                                    ? AppText.pick('Кіру', 'Войти', language: lang)
                                    : AppText.pick('Тіркелу', 'Регистрация', language: lang),
                                style: AppTheme.button.copyWith(color: Colors.black),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle login/signup
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? AppText.pick('Аккаунт жоқ? Тіркелу', 'Нет аккаунта? Зарегистрироваться', language: lang)
                            : AppText.pick('Аккаунт бар? Кіру', 'Есть аккаунт? Войти', language: lang),
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.primary),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        color: AppTheme.overlayLight,
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: AppTheme.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textDisabled),
          prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _submit() {
    final auth = context.read<AuthProvider>();
    if (_isLogin) {
      auth.signInWithEmail(_emailController.text.trim(), _passwordController.text);
    } else {
      auth.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }
}
