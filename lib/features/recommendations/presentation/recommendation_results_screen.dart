import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/movie_model.dart';
import '../../../services/tmdb_service.dart';

class RecommendationResultsScreen extends StatefulWidget {
  const RecommendationResultsScreen({super.key, this.mood, this.maxMinutes});

  final String? mood;
  final int? maxMinutes;

  @override
  State<RecommendationResultsScreen> createState() =>
      _RecommendationResultsScreenState();
}

class _RecommendationResultsScreenState
    extends State<RecommendationResultsScreen> {
  late Future<List<MovieModel>> _moviesFuture;
  final _service = TmdbService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (widget.mood != null) {
      _moviesFuture = _service.discoverMovies(
        mood: widget.mood!,
        minMinutes: widget.maxMinutes,
      );
    } else {
      _moviesFuture = _service.getPopularMovies();
    }
  }

  String get _title {
    if (widget.mood != null) return '${widget.mood} Picks';
    return 'Popular Right Now';
  }

  String get _subtitle {
    if (widget.mood != null && widget.maxMinutes != null) {
      return 'Mood: ${widget.mood}  ·  At least ${widget.maxMinutes} min';
    }
    if (widget.mood != null) return 'Mood: ${widget.mood}';
    return 'Top movies right now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Refresh',
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              _subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MovieModel>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                final movies = snapshot.data ?? [];
                if (movies.isEmpty) return _buildEmpty();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      title: movie.title,
                      posterUrl: movie.posterUrl,
                      rating: movie.voteAverage,
                      runtime: movie.runtimeFormatted.isNotEmpty
                          ? movie.runtimeFormatted
                          : '—',
                      genres: movie.genres.take(3).toList(),
                      onTap: () {
                        context.go(
                          '/${RouteNames.recommendations}/${RouteNames.movieDetail}/${movie.id}',
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              'Couldn\'t load movies',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Try Again',
              onPressed: () => setState(_load),
              height: 48,
              borderRadius: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_outlined, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            'No movies found',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your mood or time filter.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
