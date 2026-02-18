import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Join the Club',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover your next favorite movie based on your mood.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              AdaptiveTextField(
                placeholder: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AdaptiveButton(
                  onPressed: () {
                    // Mock register action
                    isLoggedIn = true;
                    context.go(RouteNames.home);
                  },
                  label: 'Register',
                  style: AdaptiveButtonStyle.filled,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  AdaptiveButton(
                    onPressed: () {
                      context.go(RouteNames.login);
                    },
                    label: 'Sign In',
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
