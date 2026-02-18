import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/movie_card.dart';

class RecommendationResultsScreen extends StatelessWidget {
  const RecommendationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock movie data (hardcoded)
    final mockMovies = [
      {
        'id': '1',
        'title': 'Inception',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
        'rating': 8.8,
        'runtime': '2h 28m',
        'genres': ['Sci-Fi', 'Action', 'Thriller'],
      },
      {
        'id': '2',
        'title': 'The Grand Budapest Hotel',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/eWdyYQreja6JGCzqHWXpWHDrrPo.jpg',
        'rating': 8.1,
        'runtime': '1h 40m',
        'genres': ['Comedy', 'Drama'],
      },
      {
        'id': '3',
        'title': 'Blade Runner 2049',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
        'rating': 8.0,
        'runtime': '2h 44m',
        'genres': ['Sci-Fi', 'Mystery', 'Thriller'],
      },
      {
        'id': '4',
        'title': 'Her',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/eCOtqtfvn7mxGl6nfmq4b1exJRc.jpg',
        'rating': 8.0,
        'runtime': '2h 06m',
        'genres': ['Romance', 'Sci-Fi', 'Drama'],
      },
      {
        'id': '5',
        'title': 'Parasite',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
        'rating': 8.5,
        'runtime': '2h 12m',
        'genres': ['Thriller', 'Drama', 'Comedy'],
      },
      {
        'id': '6',
        'title': 'Interstellar',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        'rating': 8.7,
        'runtime': '2h 49m',
        'genres': ['Sci-Fi', 'Adventure', 'Drama'],
      },
      {
        'id': '7',
        'title': 'The Shawshank Redemption',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg',
        'rating': 9.3,
        'runtime': '2h 22m',
        'genres': ['Drama', 'Crime'],
      },
      {
        'id': '8',
        'title': 'Spirited Away',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
        'rating': 8.6,
        'runtime': '2h 05m',
        'genres': ['Animation', 'Fantasy', 'Family'],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Top Picks for Your Mood',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // Future: Filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockMovies.length,
        itemBuilder: (context, index) {
          final movie = mockMovies[index];

          return MovieCard(
            title: movie['title'] as String,
            posterUrl: movie['posterUrl'] as String,
            rating: movie['rating'] as double,
            runtime: movie['runtime'] as String,
            genres: movie['genres'] as List<String>,
            onTap: () {
              // Navigate to movie detail with ID
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
