import 'package:flutter/material.dart';

/// A reusable primary button widget with consistent styling across the app.
///
/// This button automatically takes full width of its parent container,
/// uses theme colors, and provides consistent padding and border radius.
///
/// Example:
/// ```dart
/// PrimaryButton(
///   text: 'Sign In',
///   onPressed: () {
///     // Handle button press
///   },
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// Callback function when the button is pressed
  /// If null, the button will be disabled
  final VoidCallback? onPressed;

  /// Creates a primary button widget
  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.disabledColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
