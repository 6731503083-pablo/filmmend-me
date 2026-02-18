import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Filmmend Me',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find your perfect movie mood',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 64),
            AdaptiveButton(
              onPressed: () {
                context.go(RouteNames.home);
              },
              label: 'Get Started →',
              style: AdaptiveButtonStyle.filled,
            ),
            const SizedBox(height: 16),
            AdaptiveButton(
              onPressed: () {
                context.push(RouteNames.login);
              },
              label: 'Already have an account? Sign In',
              style: AdaptiveButtonStyle.plain,
            ),
          ],
        ),
      ),
    );
  }
}
