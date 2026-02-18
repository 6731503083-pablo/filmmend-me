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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
    return Scaffold(
      body: GradientBackground(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const GlassBackButton(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Join us and discover movies that match your mood',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 50),
                          AppTextField(
                            controller: _nameController,
                            hint: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _emailController,
                            hint: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            text: 'Sign Up',
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSignInLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          GestureDetector(
            onTap: () => context.go(RouteNames.login),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
