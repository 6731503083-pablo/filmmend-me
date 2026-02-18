import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
            prefixIcon: Icon(icon, color: AppColors.textHint, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}
