import 'package:flutter/material.dart';

import '../firebase/google_auth_config.dart';
import '../theme/app_colors.dart';

class EmailVerificationTips extends StatelessWidget {
  final String? email;

  const EmailVerificationTips({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final trimmedEmail = email?.trim();
    final hasEmail = trimmedEmail != null && trimmedEmail.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Can\'t find the email?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasEmail
                ? 'We sent a link to $trimmedEmail from:'
                : 'Look for a message from:',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            GoogleAuthConfig.verificationEmailSender,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '1. Check Spam or Promotions (Gmail)\n'
            '2. Mark the message as Not spam\n'
            '3. Tap the verification link, then return here',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
