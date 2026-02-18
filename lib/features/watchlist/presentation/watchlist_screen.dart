import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/widgets/widgets.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Watchlist',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoggedIn,
        builder: (context, loggedIn, _) => !loggedIn
          ? const LoginRequiredView(
              icon: Icons.bookmark_border,
              subtitle: 'Sign in to save and view your favorite movies',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.watchlistMovies.length,
              itemBuilder: (context, index) {
                final movie = MockData.watchlistMovies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MovieCard(
                    title: movie['title'] as String,
                    posterUrl: movie['posterUrl'] as String,
                    rating: movie['rating'] as double,
                    runtime: movie['runtime'] as String,
                    genres: (movie['genres'] as List).cast<String>(),
                    onTap: () {
                      context.go(
                        '/${RouteNames.recommendations}/${RouteNames.movieDetail}/${movie['id']}',
                      );
                    },
                  ),
                );
              },
            ),
          ),
    );
  }
}
