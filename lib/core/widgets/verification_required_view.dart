import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'gradient_button.dart';

class VerificationRequiredView extends StatefulWidget {
  final IconData icon;
  final String subtitle;

  const VerificationRequiredView({
    super.key,
    required this.icon,
    required this.subtitle,
  });

  @override
  State<VerificationRequiredView> createState() =>
      _VerificationRequiredViewState();
}

class _VerificationRequiredViewState extends State<VerificationRequiredView> {
  bool _sending = false;

  Future<void> _resendVerification() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await AuthService().resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send verification email. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

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
              child: Icon(widget.icon, color: AppColors.textPrimary, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Email Verification Required',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: _sending ? 'Sending...' : 'Resend Verification Email',
              onPressed: _sending ? null : _resendVerification,
            ),
          ],
        ),
      ),
    );
  }
}
