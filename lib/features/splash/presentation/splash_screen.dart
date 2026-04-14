import 'dart:math' as math;
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_controller.value * 2 * math.pi),
                      math.sin(_controller.value * 2 * math.pi),
                    ),
                    end: Alignment(
                      -math.cos(_controller.value * 2 * math.pi),
                      -math.sin(_controller.value * 2 * math.pi),
                    ),
                    colors: const [
                      Color(0xFF0A0E21), // deep midnight
                      Color(0xFF0D1B3E), // midnight blue
                      Color(0xFF0E2A4D), // navy
                      Color(0xFF0A3D5C), // dark teal-blue
                      Color(0xFF0891B2), // cyan accent
                      Color(0xFF0D1B3E), // back to midnight
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating orbs for depth
          _FloatingOrb(
            controller: _controller,
            screenSize: screenSize,
            size: 260,
            color: const Color(0xFF0891B2),
            startX: 0.7,
            startY: 0.15,
          ),
          _FloatingOrb(
            controller: _controller,
            screenSize: screenSize,
            size: 200,
            color: const Color(0xFF06B6D4),
            startX: 0.2,
            startY: 0.65,
            phaseOffset: 0.33,
          ),
          _FloatingOrb(
            controller: _controller,
            screenSize: screenSize,
            size: 140,
            color: const Color(0xFF4A90E2),
            startX: 0.5,
            startY: 0.4,
            phaseOffset: 0.66,
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/logo/app_icon.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  const Text(
                    'Filmmend Me',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Tagline
                  const Text(
                    '"Find your mood.\nDiscover your film.\nFall in love with cinema."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0x99FFFFFF),
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Get Started button
                  AccentButton(
                    text: 'Get Started',
                    height: 56,
                    onPressed: () => context.go(RouteNames.home),
                  ),
                  const SizedBox(height: 18),

                  // Sign In link
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

class _FloatingOrb extends StatelessWidget {
  final AnimationController controller;
  final Size screenSize;
  final double size;
  final Color color;
  final double startX;
  final double startY;
  final double phaseOffset;

  const _FloatingOrb({
    required this.controller,
    required this.screenSize,
    required this.size,
    required this.color,
    required this.startX,
    required this.startY,
    this.phaseOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final phase = (controller.value + phaseOffset) % 1.0;
        final dx = math.sin(phase * 2 * math.pi) * 30;
        final dy = math.cos(phase * 2 * math.pi) * 20;

        return Positioned(
          left: screenSize.width * startX - size / 2 + dx,
          top: screenSize.height * startY - size / 2 + dy,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
