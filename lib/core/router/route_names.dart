/// Route name constants for type-safe navigation
class RouteNames {
  RouteNames._();

  // Outside shell (no bottom nav)
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String loginRequired = '/login-required';

  // Main tabs (with bottom nav)
  static const String home = '/';
  static const String watchlist = '/watchlist';
  static const String profile = '/profile';

  // Nested routes under home
  static const String recommendations = 'recommendations';
  static const String movieDetail = 'movie';
}
