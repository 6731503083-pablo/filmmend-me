import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env is optional in CI/production where token is injected differently.
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Color(0xFF0A0E21),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
      ),
    );
  };

  runApp(const FilmmendMeApp());
}
