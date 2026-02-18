import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: navigationShell,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        useNativeBottomBar: true, // Enable native iOS 26 liquid glass
        selectedIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          AdaptiveNavigationDestination(icon: 'house', label: 'Home'),
          AdaptiveNavigationDestination(icon: 'bookmark', label: 'Watchlist'),
          AdaptiveNavigationDestination(icon: 'person', label: 'Profile'),
        ],
      ),
    );
  }
}
