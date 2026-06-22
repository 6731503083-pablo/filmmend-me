import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../firebase/firebase_safe.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/recommendations/presentation/recommendation_results_screen.dart';
import '../../features/movie_detail/presentation/movie_detail_screen.dart';
import 'app_shell.dart';
import 'route_names.dart';
import 'login_required_screen.dart';

/// Whether the user is currently authenticated via Firebase
bool get isLoggedIn => safeCurrentUser() != null;

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.home,

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0A0E21),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFF06B6D4)),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sorry, this page could not be opened.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xB3FFFFFF)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  ),

  routes: [
    // Splash screen (outside shell)
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth screens (outside shell)
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: RouteNames.verifyEmail,
      builder: (context, state) {
        final email = state.extra is String ? state.extra as String : null;
        final fallbackEmail = safeCurrentUser()?.email ?? '';
        return VerifyEmailScreen(email: email ?? fallbackEmail);
      },
    ),

    // Login required screen (outside shell)
    GoRoute(
      path: RouteNames.loginRequired,
      builder: (context, state) => const LoginRequiredScreen(),
    ),

    // Movie Detail (outside shell so it can be pushed from any tab without branch switching)
    GoRoute(
      path: '/${RouteNames.movieDetail}/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final movieId = state.pathParameters['id']!;
        return MovieDetailScreen(movieId: movieId);
      },
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Home tab with nested navigation (public)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                // Nested route: Recommendation Results
                GoRoute(
                  path: RouteNames.recommendations,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final extra = state.extra;
                    final map = extra is Map ? extra : null;
                    return RecommendationResultsScreen(
                      mood: map?['mood'] as String?,
                      minMinutes: (map?['time'] as num?)?.toInt(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Watchlist tab (protected - redirect handled globally)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.watchlist,
              builder: (context, state) => const WatchlistScreen(),
            ),
          ],
        ),

        // Profile tab (protected - redirect handled globally)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
