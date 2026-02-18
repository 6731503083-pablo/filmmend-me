import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Your Watchlist',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: isLoggedIn
            ? ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _buildWatchlistItem(
                    context,
                    title: 'Inception',
                    genres: 'Sci-Fi • 2h 28m',
                    id: '1',
                  ),
                  _buildWatchlistItem(
                    context,
                    title: 'The Grand Budapest Hotel',
                    genres: 'Comedy • 1h 39m',
                    id: '2',
                  ),
                  _buildWatchlistItem(
                    context,
                    title: 'Parasite',
                    genres: 'Thriller • 2h 12m',
                    id: '3',
                  ),
                  _buildWatchlistItem(
                    context,
                    title: 'Blade Runner 2049',
                    genres: 'Sci-Fi • 2h 44m',
                    id: '4',
                  ),
                  _buildWatchlistItem(
                    context,
                    title: 'Dune: Part Two',
                    genres: 'Adventure • 2h 46m',
                    id: '5',
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'Login Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please log in to view your watchlist',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  AdaptiveButton(
                    onPressed: () {
                      context.push(RouteNames.login);
                    },
                    label: 'Go to Login',
                    style: AdaptiveButtonStyle.filled,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWatchlistItem(
    BuildContext context, {
    required String title,
    required String genres,
    required String id,
  }) {
    return AdaptiveCard(
      color: const Color(0xFF252A3D),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.movie, color: Colors.white54, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(genres, style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white54),
          onPressed: () {},
        ),
        onTap: () {
          context.go(
            '${RouteNames.home}/${RouteNames.recommendations}/${RouteNames.movieDetail}/$id',
          );
        },
      ),
    );
  }
}
