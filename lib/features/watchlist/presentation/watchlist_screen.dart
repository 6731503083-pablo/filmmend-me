import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/firebase/firebase_safe.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/watchlist_service.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  int _streamNonce = 0;

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
      body: StreamBuilder<User?>(
        stream: safeAuthStateChanges(),
        initialData: safeCurrentUser(),
        builder: (context, authSnap) {
          final user = authSnap.data;
          if (user == null) {
            return const LoginRequiredView(
              icon: Icons.bookmark_border,
              subtitle: 'Sign in to save and view your favorite movies',
            );
          }
          final ws = WatchlistService();
          return StreamBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_streamNonce),
            stream: ws.watchlistStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.white30,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not load your watchlist',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your connection and try again.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => setState(() => _streamNonce += 1),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final movies = snap.data ?? [];
              if (movies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        color: Colors.white24,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your watchlist is empty',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add movies from the detail page',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Dismissible(
                    key: Key(movie['movieId'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    onDismissed: (_) {
                      final movieId = movie['movieId'].toString();
                      ws.removeMovie(movieId).catchError((_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not remove from watchlist. Please try again.',
                            ),
                          ),
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MovieCard(
                        title: movie['title'] ?? 'Unknown',
                        posterUrl: movie['posterPath'] != null
                            ? 'https://image.tmdb.org/t/p/w500${movie['posterPath']}'
                            : '',
                        rating: (movie['rating'] as num?)?.toDouble() ?? 0.0,
                        runtime: movie['runtime'] ?? '',
                        genres:
                            (movie['genres'] as List?)?.cast<String>() ?? [],
                        onTap: () {
                          context.push(
                            '/${RouteNames.movieDetail}/${movie['movieId']}',
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
