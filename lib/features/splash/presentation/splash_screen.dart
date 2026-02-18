import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const MovieMosaicHeader(heightFactor: 0.62),
          Positioned(
            top: size.height * 0.40,
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const FilmmendBrandLogo(imageSize: 42, fontSize: 34),
                    const SizedBox(height: 24),
                    const Text(
                      '"Find your mood.\nDiscover your film.\nFall in love with cinema."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(),
                    AccentButton(
                      text: 'Get Started',
                      height: 58,
                      onPressed: () => context.go(RouteNames.home),
                    ),
                    const SizedBox(height: 18),
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
                                color: Color(0xFFE87A4A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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

