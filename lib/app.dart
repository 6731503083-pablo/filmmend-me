import 'package:flutter/material.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

class FilmmendMeApp extends StatelessWidget {
  const FilmmendMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Filmmend Me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
