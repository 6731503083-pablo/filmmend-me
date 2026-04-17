import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _autoContinueTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _autoContinueTimer = Timer(const Duration(seconds: 3), _goHome);
  }

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    super.dispose();
  }

  void _goHome() {
    if (!mounted || _navigated) return;
    _navigated = true;
    context.go(RouteNames.home);
  }

  void _goLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    context.push(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.sizeOf(context).height < 860;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E21),
                  Color(0xFF0D1B3E),
                  Color(0xFF0A3D5C),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28, 0, 28, compactLayout ? 20 : 28),
              child: Column(
                children: [
                  Spacer(flex: compactLayout ? 2 : 3),

                  // Logo
                  SizedBox(
                    width: compactLayout ? 160 : 190,
                    height: compactLayout ? 160 : 190,
                    child: Image.asset(
                      'assets/logo/brand_logo_transparent.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: compactLayout ? 8 : 12),

                  Spacer(flex: compactLayout ? 0 : 1),

                  // Tagline
                  Text(
                    '"Find your mood.\nDiscover your film.\nFall in love with cinema."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compactLayout ? 14 : 16,
                      color: Color(0x99FFFFFF),
                      fontStyle: FontStyle.italic,
                      height: compactLayout ? 1.5 : 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),

                  Spacer(flex: compactLayout ? 1 : 2),

                  // Get Started button
                  AccentButton(
                    text: 'Get Started',
                    height: compactLayout ? 52 : 56,
                    onPressed: _goHome,
                  ),
                  SizedBox(height: compactLayout ? 12 : 18),

                  // Sign In link
                  GestureDetector(
                    onTap: _goLogin,
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
                              color: Color(0xFF06B6D4),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
