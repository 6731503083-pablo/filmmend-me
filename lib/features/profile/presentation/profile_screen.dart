import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/firebase/firebase_safe.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

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
      body: StreamBuilder<User?>(
        stream: safeAuthStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: LoginRequiredView(
                icon: Icons.person_outline,
                subtitle: 'Please log in to view your profile',
              ),
            );
          }
          return FutureBuilder<UserModel?>(
            future: AuthService().getCurrentUserModel(),
            builder: (context, modelSnap) {
              if (modelSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final model = modelSnap.data;
              return Center(child: _buildLoggedInView(context, user, model));
            },
          );
        },
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, User user, UserModel? model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAvatar(),
        const SizedBox(height: 16),
        Text(
          model?.displayName ?? user.displayName ?? 'Film Fan',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        _buildBadge(),
        const SizedBox(height: 8),
        Text(
          model?.memberSince ?? '',
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 6),
        Text(
          user.email ?? '',
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(height: 40),
        _buildLogoutButton(context),
        const SizedBox(height: 16),
        _buildDeleteButton(context),
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


  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => _showDeleteAccountDialog(context),
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        label: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Account?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will permanently delete your account and watchlist data. This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AdaptiveButton(
                    onPressed: isDeleting
                        ? null
                        : () async {
                            setState(() => isDeleting = true);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await AuthService().deleteAccountAndData();
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Account deleted.'),
                                ),
                              );
                              context.go(RouteNames.home);
                            } on FirebaseAuthException catch (e) {
                              if (!context.mounted) return;
                              setState(() => isDeleting = false);
                              if (e.code == 'requires-recent-login') {
                                Navigator.of(context).pop();
                                await AuthService().signOut();
                                if (!context.mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please log in again to confirm account deletion.',
                                    ),
                                  ),
                                );
                                context.go(RouteNames.login);
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not delete account. Please try again.',
                                    ),
                                  ),
                                );
                              }
                            } catch (_) {
                              if (!context.mounted) return;
                              setState(() => isDeleting = false);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Could not delete account.'),
                                ),
                              );
                            }
                          },
                    label: isDeleting ? 'Deleting...' : 'Delete Account',
                    style: AdaptiveButtonStyle.filled,
                  ),
                ),
                const SizedBox(height: 8),
                AdaptiveButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.of(context).pop(),
                  label: 'Cancel',
                  style: AdaptiveButtonStyle.plain,
                ),
              ],
            ),
          ),
        );
      },
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
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    context.pop();
                    context.go(RouteNames.home);
                  }
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
