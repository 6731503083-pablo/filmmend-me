import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context) {
    final movie = MockData.getMovieById(movieId);

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
                    _buildGenreChips(movie),
                    const SizedBox(height: 24),
                    _buildSynopsis(movie),
                    const SizedBox(height: 24),
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

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    Map<String, dynamic> movie,
  ) {
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

  Widget _buildPosterImage(Map<String, dynamic> movie) {
    final url = movie['posterUrl'].toString();
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

  Widget _buildTitle(Map<String, dynamic> movie) {
    return Text(
      movie['title'] as String,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetadataRow(Map<String, dynamic> movie) {
    return Row(
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
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            movie['rating_label'] as String,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.access_time, size: 16, color: Colors.white54),
        const SizedBox(width: 4),
        Text(
          movie['runtime'] as String,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWatchlistButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AdaptiveButton(
        onPressed: () {
          if (isLoggedIn) {
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

  Widget _buildGenreChips(Map<String, dynamic> movie) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: (movie['genres'] as List).cast<String>().map((genre) {
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

  Widget _buildSynopsis(Map<String, dynamic> movie) {
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
          movie['synopsis'] as String,
          style: const TextStyle(
            color: Colors.white70,
            height: 1.6,
            fontSize: 15,
          ),
        ),
      ],
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
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
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
