import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie_model.dart';
import '../../../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieModel> _movieFuture;
  final _service = TmdbService();

  @override
  void initState() {
    super.initState();
    _movieFuture = _service.getMovieDetails(int.parse(widget.movieId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MovieModel>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.white30),
                    const SizedBox(height: 16),
                    const Text(
                      'Couldn\'t load movie',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _buildDetail(context, snapshot.data!);
      },
    );
  }

  Widget _buildDetail(BuildContext context, MovieModel movie) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, movie),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(movie),
                    const SizedBox(height: 12),
                    _buildMetadataRow(movie),
                    const SizedBox(height: 20),
                    _buildWatchlistButton(context),
                    const SizedBox(height: 20),
                    if (movie.genres.isNotEmpty) ...[
                      _buildGenreChips(movie),
                      const SizedBox(height: 24),
                    ],
                    if (movie.overview.isNotEmpty) ...[
                      _buildSynopsis(movie),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, MovieModel movie) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildPosterImage(movie),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.background.withOpacity(0.7),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage(MovieModel movie) {
    final url = movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl;
    if (url.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(Icons.movie, size: 120, color: Colors.white30),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surface,
        child: const Icon(Icons.movie, size: 120, color: Colors.white30),
      ),
    );
  }

  Widget _buildTitle(MovieModel movie) {
    return Text(
      movie.title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetadataRow(MovieModel movie) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text(
                movie.ratingFormatted,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (movie.releaseYear > 0)
          Text(
            '${movie.releaseYear}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        if (movie.runtimeFormatted.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                movie.runtimeFormatted,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildWatchlistButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AdaptiveButton(
        onPressed: () {
          if (isLoggedIn.value) {
            _showSuccessDialog(context);
          } else {
            context.push(RouteNames.login);
          }
        },
        label: 'Add to Watchlist',
        style: AdaptiveButtonStyle.filled,
      ),
    );
  }

  Widget _buildGenreChips(MovieModel movie) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movie.genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
          ),
          child: Text(
            genre,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSynopsis(MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          movie.overview,
          style: const TextStyle(
            color: Colors.white70,
            height: 1.6,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Added to Watchlist',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
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
