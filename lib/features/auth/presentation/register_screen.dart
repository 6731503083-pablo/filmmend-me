import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    isLoggedIn = true;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const MovieMosaicHeader(heightFactor: 0.46),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FilmmendBrandLogo(imageSize: 30, fontSize: 22),
                        const SizedBox(height: 20),
                        const Text(
                          'Sign Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Create an account to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AuthField(
                          controller: _usernameController,
                          hint: 'Username',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AccentButton(text: 'Sign Up', onPressed: _handleRegister),
                        const SizedBox(height: 22),
                        _buildSignInLink(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return GestureDetector(
      onTap: () => context.go(RouteNames.login),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          children: [
            TextSpan(text: 'Already have an account? Go to the '),
            TextSpan(
              text: 'Login Page',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
