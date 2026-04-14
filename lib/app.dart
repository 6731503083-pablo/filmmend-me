import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

  Future<void> _initializeFirebase() {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        throw TimeoutException('Firebase initialization timed out');
      },
    );
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

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF0D1B3E), Color(0xFF0A3D5C)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF06B6D4)),
              SizedBox(height: 16),
              Text(
                'Starting Filmmend Me...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
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
