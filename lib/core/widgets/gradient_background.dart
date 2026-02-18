import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: child,
    );
  }
}
