import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/recommendations/presentation/recommendation_results_screen.dart';
import '../../features/movie_detail/presentation/movie_detail_screen.dart';
import 'app_shell.dart';
import 'route_names.dart';
import 'login_required_screen.dart';

// Mock authentication state
ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,

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

    // Login required screen (outside shell)
    GoRoute(
      path: RouteNames.loginRequired,
      builder: (context, state) => const LoginRequiredScreen(),
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
                  builder: (context, state) =>
                      const RecommendationResultsScreen(),
                  routes: [
                    // Nested route: Movie Detail
                    GoRoute(
                      path: '${RouteNames.movieDetail}/:id',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final movieId = state.pathParameters['id']!;
                        return MovieDetailScreen(movieId: movieId);
                      },
                    ),
                  ],
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
