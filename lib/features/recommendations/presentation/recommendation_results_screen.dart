import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class RecommendationResultsScreen extends StatelessWidget {
  const RecommendationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Top Picks for Your Mood',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMovieCard(
            context,
            id: '1',
            title: 'Inception',
            rating: '4.8',
            votes: '94k',
            duration: '2h 28m',
            year: '2010',
            genres: ['Sci-Fi', 'Action'],
          ),
          _buildMovieCard(
            context,
            id: '2',
            title: 'The Grand Budapest Hotel',
            rating: '4.5',
            votes: '18k',
            duration: '1h 40m',
            year: '2014',
            genres: ['Comedy', 'Drama'],
          ),
          _buildMovieCard(
            context,
            id: '3',
            title: 'Blade Runner 2049',
            rating: '4.7',
            votes: '15k',
            duration: '2h 44m',
            year: '2017',
            genres: ['Sci-Fi', 'Mystery'],
          ),
          _buildMovieCard(
            context,
            id: '4',
            title: 'Her',
            rating: '4.3',
            votes: '11k',
            duration: '2h 06m',
            year: '2013',
            genres: ['Romance', 'Sci-Fi'],
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(
    BuildContext context, {
    required String id,
    required String title,
    required String rating,
    required String votes,
    required String duration,
    required String year,
    required List<String> genres,
  }) {
    return AdaptiveCard(
      color: const Color(0xFF252A3D),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.go(
            '${RouteNames.home}/${RouteNames.recommendations}/${RouteNames.movieDetail}/$id',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.movie, color: Colors.white54, size: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$rating ($votes)',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          year,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: genres
                          .map(
                            (genre) => Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: Colors.blue.withValues(
                                alpha: 0.3,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white54),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
