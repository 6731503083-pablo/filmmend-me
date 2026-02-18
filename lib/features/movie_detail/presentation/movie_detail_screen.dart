import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  // Mock movie data based on ID
  Map<String, dynamic> _getMovieData() {
    final movies = {
      '1': {
        'title': 'Inception',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
        'rating': 8.8,
        'year': '2010',
        'rating_label': 'PG-13',
        'genres': ['Sci-Fi', 'Action', 'Thriller'],
        'synopsis':
            'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O. Dom Cobb is a skilled thief, the absolute best in the dangerous art of extraction, stealing valuable secrets from deep within the subconscious during the dream state, when the mind is at its most vulnerable.',
        'runtime': '2h 28m',
        'director': 'Christopher Nolan',
        'cast': 'Leonardo DiCaprio, Joseph Gordon-Levitt, Elliot Page',
      },
      '2': {
        'title': 'The Grand Budapest Hotel',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/eWdyYQreja6JGCzqHWXpWHDrrPo.jpg',
        'rating': 8.1,
        'year': '2014',
        'rating_label': 'R',
        'genres': ['Comedy', 'Drama', 'Adventure'],
        'synopsis':
            'The adventures of Gustave H, a legendary concierge at a famous hotel from the fictional Republic of Zubrowka between the first and second World Wars, and Zero Moustafa, the lobby boy who becomes his most trusted friend.',
        'runtime': '1h 40m',
        'director': 'Wes Anderson',
        'cast': 'Ralph Fiennes, F. Murray Abraham, Mathieu Amalric',
      },
      '3': {
        'title': 'Blade Runner 2049',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
        'rating': 8.0,
        'year': '2017',
        'rating_label': 'R',
        'genres': ['Sci-Fi', 'Mystery', 'Thriller'],
        'synopsis':
            'Thirty years after the events of the first film, a new blade runner, LAPD Officer K, unearths a long-buried secret that has the potential to plunge what\'s left of society into chaos. K\'s discovery leads him on a quest to find Rick Deckard, a former blade runner who has been missing for 30 years.',
        'runtime': '2h 44m',
        'director': 'Denis Villeneuve',
        'cast': 'Ryan Gosling, Harrison Ford, Ana de Armas',
      },
      '4': {
        'title': 'Her',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/eCOtqtfvn7mxGl6nfmq4b1exJRc.jpg',
        'rating': 8.0,
        'year': '2013',
        'rating_label': 'R',
        'genres': ['Romance', 'Sci-Fi', 'Drama'],
        'synopsis':
            'In a near future Los Angeles, Theodore Twombly, a complex, soulful man who makes his living writing touching, personal letters for other people. Heartbroken after the end of a long relationship, he becomes intrigued with a new, advanced operating system, which promises to be an intuitive entity in its own right.',
        'runtime': '2h 06m',
        'director': 'Spike Jonze',
        'cast': 'Joaquin Phoenix, Amy Adams, Scarlett Johansson',
      },
      '5': {
        'title': 'Parasite',
        'posterUrl':
            'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
        'rating': 8.5,
        'year': '2019',
        'rating_label': 'R',
        'genres': ['Thriller', 'Drama', 'Comedy'],
        'synopsis':
            'All unemployed, Ki-taek and his family take peculiar interest in the wealthy and glamorous Parks, as they ingratiate themselves into their lives and get entangled in an unexpected incident.',
        'runtime': '2h 12m',
        'director': 'Bong Joon-ho',
        'cast': 'Song Kang-ho, Lee Sun-kyun, Cho Yeo-jeong',
      },
    };

    return movies[movieId] ??
        {
          'title': 'Movie Not Found',
          'posterUrl': '',
          'rating': 0.0,
          'year': '',
          'rating_label': '',
          'genres': [],
          'synopsis': 'Movie details not available.',
          'runtime': '',
          'director': '',
          'cast': '',
        };
  }

  @override
  Widget build(BuildContext context) {
    final movie = _getMovieData();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      body: CustomScrollView(
        slivers: [
          // Large poster at top with app bar
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            backgroundColor: const Color(0xFF1A1D2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Future: Share functionality
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Movie poster
                  movie['posterUrl'].toString().isNotEmpty
                      ? Image.network(
                          movie['posterUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.dividerColor.withOpacity(0.2),
                              child: const Icon(
                                Icons.movie,
                                size: 120,
                                color: Colors.white30,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: theme.dividerColor.withOpacity(0.2),
                          child: const Icon(
                            Icons.movie,
                            size: 120,
                            color: Colors.white30,
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          const Color(0xFF1A1D2E).withOpacity(0.7),
                          const Color(0xFF1A1D2E),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Movie details
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie title
                    Text(
                      movie['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating and year
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (movie['rating'] as double).toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          movie['year'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            movie['rating_label'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie['runtime'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Add to Watchlist button
                    SizedBox(
                      width: double.infinity,
                      child: AdaptiveButton(
                        onPressed: () {
                          if (isLoggedIn) {
                            _showSuccessDialog(context);
                          } else {
                            // Navigate to login if not logged in
                            context.push(RouteNames.login);
                          }
                        },
                        label: 'Add to Watchlist',
                        style: AdaptiveButtonStyle.filled,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Genre chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (movie['genres'] as List<String>)
                          .map(
                            (genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Synopsis section
                    const Text(
                      'Synopsis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie['synopsis'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Additional info
                    _buildInfoSection('Director', movie['director'] as String),
                    const SizedBox(height: 16),
                    _buildInfoSection('Cast', movie['cast'] as String),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252A3D),
        title: const Text(
          'Added to Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Movie has been added to your watchlist!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          AdaptiveButton(
            onPressed: () => context.pop(),
            label: 'OK',
            style: AdaptiveButtonStyle.filled,
          ),
        ],
      ),
    );
  }
}
