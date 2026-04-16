import 'dart:async';

import 'package:flutter/material.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0A0E21),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error_outline, color: Color(0xFF06B6D4), size: 52),
              SizedBox(height: 12),
              Text(
                'Startup issue detected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please restart the app. If this continues, update to the latest test build.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xB3FFFFFF)),
              ),
            ],
          ),
        ),
      ),
    );
  };

  await runZonedGuarded(
    () async {
      runApp(const FilmmendMeApp());
    },
    (error, stackTrace) {
      debugPrint('Uncaught startup error: $error');
    },
  );
}
