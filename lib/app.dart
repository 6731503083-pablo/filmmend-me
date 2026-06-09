import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/firebase/crashlytics_bootstrap.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

class FilmmendMeApp extends StatefulWidget {
  const FilmmendMeApp({super.key});

  @override
  State<FilmmendMeApp> createState() => _FilmmendMeAppState();
}

class _FilmmendMeAppState extends State<FilmmendMeApp> {
  late Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    // We run Firebase initialization and an artificial delay in parallel.
    // This guarantees our beautiful new splash animation actually has time to play
    // (Firebase usually initializes in <50ms, which skips the animation entirely!)
    final firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final minSplashDuration = Future.delayed(
      const Duration(milliseconds: 600),
    );

    await Future.wait([firebaseInit, minSplashDuration]).timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        throw TimeoutException('Initialization timed out');
      },
    );

    await configureCrashlytics();
  }

  void _retryBootstrap() {
    setState(() {
      _bootstrapFuture = _initializeFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            title: 'Filmmend Me',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const _BootstrapLoadingScreen(),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            title: 'Filmmend Me',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: _BootstrapErrorScreen(onRetry: _retryBootstrap),
          );
        }

        return MaterialApp.router(
          title: 'Filmmend Me',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: appRouter,
        );
      },
    );
  }
}

class _BootstrapLoadingScreen extends StatefulWidget {
  const _BootstrapLoadingScreen();

  @override
  State<_BootstrapLoadingScreen> createState() =>
      _BootstrapLoadingScreenState();
}

class _BootstrapLoadingScreenState extends State<_BootstrapLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: const Text(
                  'FilmMend Me',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Color(0xFF06B6D4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to start right now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your network and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xB3FFFFFF)),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
