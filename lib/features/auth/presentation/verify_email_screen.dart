import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/email_verification_tips.dart';
import '../../../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _pollTimer;
  bool _sending = false;
  bool _checking = false;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkVerification(showFeedback: false);
    });
  }

  Future<void> _resendVerification() async {
    if (_sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService().resendVerificationEmail();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Verification email sent.')),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not send verification email. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _checkVerification({required bool showFeedback}) async {
    if (_checking || _redirecting) return;
    if (showFeedback) setState(() => _checking = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final user = await AuthService().reloadCurrentUser();
      if (!mounted) return;
      if (user != null && user.emailVerified) {
        _redirecting = true;
        _pollTimer?.cancel();
        messenger.showSnackBar(
          const SnackBar(content: Text('Email verified. Redirecting...')),
        );
        if (!mounted) return;
        context.go(RouteNames.home);
        return;
      }
      if (showFeedback) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      if (showFeedback) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not refresh verification status. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted && showFeedback) setState(() => _checking = false);
    }
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email.trim().isEmpty ? 'your email' : widget.email;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(onPressed: _signOut, child: const Text('Log out')),
          ],
        ),
        body: Center(
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
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    color: AppColors.textPrimary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Check your inbox',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a verification link to $email.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                EmailVerificationTips(email: email),
                const SizedBox(height: 20),
                GradientButton(
                  text: _sending ? 'Sending...' : 'Resend verification email',
                  onPressed: _sending ? null : _resendVerification,
                ),
                TextButton(
                  onPressed: _checking
                      ? null
                      : () => _checkVerification(showFeedback: true),
                  child: Text(
                    _checking ? 'Checking...' : "I've verified",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We check automatically every few seconds.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
