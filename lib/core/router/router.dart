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
        final email = state.extra as String?;
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
                    final extra = state.extra as Map<String, dynamic>?;
                    return RecommendationResultsScreen(
                      mood: extra?['mood'] as String?,
                      maxMinutes: extra?['time'] as int?,
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
