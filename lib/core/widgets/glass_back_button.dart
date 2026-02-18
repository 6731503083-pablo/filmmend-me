import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';

class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
      ),
    );
  }
}
