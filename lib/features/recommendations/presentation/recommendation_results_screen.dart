import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/widgets/widgets.dart';

class RecommendationResultsScreen extends StatelessWidget {
  const RecommendationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Top Picks for Your Mood',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {
              // Future: Filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.movies.length,
        itemBuilder: (context, index) {
          final movie = MockData.movies[index];
          return MovieCard(
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
          );
        },
      ),
    );
  }
}
