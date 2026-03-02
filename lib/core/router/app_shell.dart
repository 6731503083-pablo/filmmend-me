import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web / non-iOS: use standard Material NavigationBar
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: _WebNavBar(
          selectedIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      );
    }

    // iOS: keep native iOS 26 liquid glass bottom bar
    return AdaptiveScaffold(
      body: navigationShell,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        useNativeBottomBar: true,
        selectedIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: const [
          AdaptiveNavigationDestination(icon: 'house', label: 'Home'),
          AdaptiveNavigationDestination(icon: 'bookmark', label: 'Watchlist'),
          AdaptiveNavigationDestination(icon: 'person', label: 'Profile'),
        ],
      ),
    );
  }
}

class _WebNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _WebNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bookmark_rounded,
                label: 'Watchlist',
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
