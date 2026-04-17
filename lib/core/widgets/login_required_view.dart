import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import 'gradient_button.dart';

class LoginRequiredView extends StatelessWidget {
  final IconData icon;
  final String subtitle;

  const LoginRequiredView({
    super.key,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Login Required',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Sign In',
              onPressed: () => context.push(RouteNames.login),
            ),
          ],
        ),
      ),
    );
  }
}
