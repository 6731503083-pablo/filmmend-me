import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sign In', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your details to continue your cinematic journey.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              AdaptiveTextField(
                placeholder: 'name@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              AdaptiveTextField(
                placeholder: 'Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: AdaptiveButton(
                  onPressed: () {},
                  label: 'Forgot Password?',
                  style: AdaptiveButtonStyle.plain,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AdaptiveButton(
                  onPressed: () {
                    // Mock login action
                    isLoggedIn = true;
                    context.go(RouteNames.home);
                  },
                  label: 'Sign In',
                  style: AdaptiveButtonStyle.filled,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  AdaptiveButton(
                    onPressed: () {
                      context.go(RouteNames.register);
                    },
                    label: 'Register',
                    style: AdaptiveButtonStyle.plain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
