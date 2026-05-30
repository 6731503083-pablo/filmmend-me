import 'package:flutter/material.dart';

/// A reusable movie card widget that displays movie information in a horizontal layout.
///
/// This card shows a movie poster on the left and details (title, rating, runtime, genres)
/// on the right. It's fully tappable and uses theme colors for dark theme compatibility.
///
/// Example:
/// ```dart
/// MovieCard(
///   title: 'Inception',
///   posterUrl: 'https://image.tmdb.org/t/p/w500/path.jpg',
///   rating: 8.8,
///   runtime: '2h 28m',
///   genres: ['Sci-Fi', 'Thriller'],
///   onTap: () {
///     // Navigate to movie detail
///   },
/// )
/// ```
class MovieCard extends StatelessWidget {
  /// The title of the movie
  final String title;

  /// URL to the movie poster image
  final String posterUrl;

  /// Movie rating (typically 0-10)
  final double rating;

  /// Runtime of the movie (e.g., "2h 28m")
  final String runtime;

  /// List of genre names
  final List<String> genres;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Optional recommendation explanation shown below metadata
  final String? recommendationReason;

  /// Creates a movie card widget
  const MovieCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.onTap,
    this.recommendationReason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 120,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          cacheWidth: 240,
                          cacheHeight: 360,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.movie,
                              size: 40,
                              color: theme.iconTheme.color?.withValues(
                                alpha: 0.5,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.movie,
                          size: 40,
                          color: theme.iconTheme.color?.withValues(alpha: 0.5),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Movie Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Rating Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Runtime
                        if (runtime.isNotEmpty) ...[
                          Text(
                            '—',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            runtime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Genres
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: genres.take(3).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            genre,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (recommendationReason != null &&
                        recommendationReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        recommendationReason!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Chevron Icon
              Icon(
                Icons.chevron_right,
                color: theme.iconTheme.color?.withValues(alpha: 0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
