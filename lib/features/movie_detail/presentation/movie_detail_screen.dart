import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF1A1D2E),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[800]!, const Color(0xFF1A1D2E)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.movie, size: 120, color: Colors.white30),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inception',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '8.8',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '2010',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'PG-13',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AdaptiveButton(
                            onPressed: () {
                              if (isLoggedIn) {
                                _showSuccessDialog(context);
                              } else {
                                context.push(RouteNames.login);
                              }
                            },
                            label: 'Add to Watchlist',
                            style: AdaptiveButtonStyle.gray,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdaptiveButton(
                            onPressed: () {},
                            label: 'Where to Watch',
                            style: AdaptiveButtonStyle.filled,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['Sci-Fi', 'Action', 'Thriller']
                          .map(
                            (genre) => Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Synopsis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O. in order to reconnect with his children.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildInfoBox('Duration', '2h 28m'),
                        const SizedBox(width: 16),
                        _buildInfoBox('Language', 'English'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Top Cast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCastMember('Leonardo'),
                          _buildCastMember('Joseph'),
                          _buildCastMember('Elliot'),
                          _buildCastMember('Tom'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252A3D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastMember(String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.person, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252A3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'SUCCESS',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Added to Watchlist!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.go(RouteNames.watchlist);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Watchlist'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
