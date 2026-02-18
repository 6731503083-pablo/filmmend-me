import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const MovieMosaicHeader(heightFactor: 0.52),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const FilmmendBrandLogo(imageSize: 40, fontSize: 32),
                    const Text(
                      '"Find your mood.\nDiscover your film.\nFall in love with cinema."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                    Column(
                      children: [
                        AccentButton(
                          text: 'Get Started',
                          height: 56,
                          onPressed: () => context.go(RouteNames.home),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.login),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

