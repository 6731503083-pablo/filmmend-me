import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;

  const GradientButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = 16,
    this.gradientColors,
  }) : assert(text != null || child != null, 'Provide text or child');

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final colors = gradientColors ?? AppColors.primaryGradient;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled ? LinearGradient(colors: colors) : null,
        color: isEnabled ? null : AppColors.glassFill,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child:
            child ??
            Text(
              text!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
              ),
            ),
      ),
    );
  }
}
