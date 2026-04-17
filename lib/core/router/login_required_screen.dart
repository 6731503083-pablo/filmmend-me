import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

class LoginRequiredScreen extends StatelessWidget {
  const LoginRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Required')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            const Text('Please log in to access this feature'),
            const SizedBox(height: 24),
            AdaptiveButton(
              onPressed: () => context.push(RouteNames.login),
              label: 'Go to Login',
              style: AdaptiveButtonStyle.filled,
            ),
          ],
        ),
      ),
    );
  }
}
