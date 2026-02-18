import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/widgets.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  // Mock saved movies
  final List<Map<String, dynamic>> mockWatchlist = const [
    {
      'id': '1',
      'title': 'Inception',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg',
      'rating': 8.8,
      'runtime': '2h 28m',
      'genres': ['Sci-Fi', 'Thriller', 'Action'],
    },
    {
      'id': '3',
      'title': 'Parasite',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      'rating': 8.6,
      'runtime': '2h 12m',
      'genres': ['Thriller', 'Drama', 'Comedy'],
    },
    {
      'id': '4',
      'title': 'Blade Runner 2049',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
      'rating': 8.0,
      'runtime': '2h 44m',
      'genres': ['Sci-Fi', 'Drama'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Watchlist', style: TextStyle(color: Colors.white)),
      ),
      body: !isLoggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Login Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to save and view your favorite movies',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.go(RouteNames.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockWatchlist.length,
              itemBuilder: (context, index) {
                final movie = mockWatchlist[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MovieCard(
                    title: movie['title'] as String,
                    posterUrl: movie['posterUrl'] as String,
                    rating: movie['rating'] as double,
                    runtime: movie['runtime'] as String,
                    genres: movie['genres'] as List<String>,
                    onTap: () {
                      context.go(
                        '/${RouteNames.recommendations}/${RouteNames.movieDetail}/${movie['id']}',
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
