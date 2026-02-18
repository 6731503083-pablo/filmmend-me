import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
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
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sign in to continue your cinematic journey',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 50),
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
                            text: 'Sign In',
                            onPressed: _handleSignIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          GestureDetector(
            onTap: () => context.push(RouteNames.register),
            child: const Text(
              'Sign Up',
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
