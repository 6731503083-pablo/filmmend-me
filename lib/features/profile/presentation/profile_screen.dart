import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: isLoggedIn
            ? _buildLoggedInView(context)
            : const LoginRequiredView(
                icon: Icons.person_outline,
                subtitle: 'Please log in to view your profile',
              ),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAvatar(),
        const SizedBox(height: 16),
        const Text(
          'Alex Johnson',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        _buildBadge(),
        const SizedBox(height: 8),
        const Text(
          'Member since 2021',
          style: TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 40),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[700],
          child: const Icon(Icons.person, size: 60, color: Colors.white54),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'MOVIE CRITIC',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Log Out',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log Out?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AdaptiveButton(
                onPressed: () {
                  isLoggedIn = false;
                  context.pop();
                  context.go(RouteNames.home);
                },
                label: 'Log Out',
                style: AdaptiveButtonStyle.filled,
              ),
            ),
            const SizedBox(height: 8),
            AdaptiveButton(
              onPressed: () => context.pop(),
              label: 'Cancel',
              style: AdaptiveButtonStyle.plain,
            ),
          ],
        ),
      ),
    );
  }
}
