import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/firebase/firebase_safe.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/tmdb_service.dart';
import '../../../services/watchlist_service.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieModel> _movieFuture;
  MovieModel? _movie;
  bool _isWatchlistBusy = false;
  final _service = TmdbService();

  @override
  void initState() {
    super.initState();
    _movieFuture = _loadMovieDetails();
  }

  Future<MovieModel> _loadMovieDetails() {
    final parsedId = int.tryParse(widget.movieId);
    if (parsedId == null) {
      return Future<MovieModel>.error(
        const FormatException('Invalid movie id. Please try another movie.'),
      );
    }
    return _service.getMovieDetails(parsedId);
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white30,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error is TmdbException &&
                              (snapshot.error as TmdbException).isNetworkError
                          ? 'You appear to be offline'
                          : 'Couldn\'t load movie',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error is TmdbException
                          ? (snapshot.error as TmdbException).message
                          : 'Please try again in a moment.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
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
    _movie = movie;
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
                    if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildTagline(movie),
                    ],
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
                      const SizedBox(height: 28),
                    ],
                    // Director & Writers
                    if (movie.directors.isNotEmpty ||
                        movie.writers.isNotEmpty) ...[
                      _buildCrewHighlights(movie),
                      const SizedBox(height: 28),
                    ],
                    // Cast
                    if (movie.cast.isNotEmpty) ...[
                      _buildSectionHeader('Cast'),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              // Cast horizontal list (full-bleed, outside padding)
              if (movie.cast.isNotEmpty) ...[
                _buildCastList(movie),
                const SizedBox(height: 28),
              ],
              // Trailer
              if (movie.trailer != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Trailer'),
                      const SizedBox(height: 12),
                      _buildTrailerCard(movie.trailer!),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              // Movie Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Movie Info'),
                    const SizedBox(height: 12),
                    _buildInfoGrid(movie),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
              // Similar Movies
              if (movie.similarMovies.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSectionHeader('Similar Movies'),
                ),
                const SizedBox(height: 12),
                _buildSimilarMovies(movie),
                const SizedBox(height: 40),
              ],
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
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 20),
              onPressed: () {
                final url = 'https://www.themoviedb.org/movie/${movie.id}';
                SharePlus.instance.share(
                  ShareParams(text: 'Check out "${movie.title}"!\n$url'),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildPosterImage(movie),
            // Top gradient so icons are always visible on light images
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Bottom gradient into background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.7),
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
    final url = movie.backdropUrl.isNotEmpty
        ? movie.backdropUrl
        : movie.posterUrl;
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
    return StreamBuilder<User?>(
      stream: safeAuthStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;
        if (user == null) {
          return SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              onPressed: _isWatchlistBusy
                  ? null
                  : () async {
                      if (_movie == null) return;
                      setState(() => _isWatchlistBusy = true);
                      try {
                        await context.push<bool>(RouteNames.login);
                        if (!mounted || safeCurrentUser() == null) return;

                        final ws = WatchlistService();
                        final movieId = widget.movieId;
                        final alreadyInWatchlist = await ws.isInWatchlist(
                          movieId,
                        );
                        if (alreadyInWatchlist) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Already in your watchlist.'),
                            ),
                          );
                          return;
                        }

                        await ws.addMovie(
                          movieId: movieId,
                          title: _movie!.title,
                          posterPath: _movie!.posterPath,
                          rating: _movie!.voteAverage,
                          releaseDate: _movie!.releaseDate,
                          genres: _movie!.genres,
                          runtime: _movie!.runtimeFormatted,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to watchlist.')),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not update watchlist. Please try again.',
                            ),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isWatchlistBusy = false);
                        }
                      }
                    },
              label: 'Sign in to add to Watchlist',
              style: AdaptiveButtonStyle.filled,
            ),
          );
        }
        if (!user.emailVerified) {
          return SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              onPressed: _isWatchlistBusy
                  ? null
                  : () async {
                      setState(() => _isWatchlistBusy = true);
                      try {
                        await AuthService().resendVerificationEmail();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email sent.'),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not send verification email. Please try again.',
                            ),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isWatchlistBusy = false);
                        }
                      }
                    },
              label: _isWatchlistBusy
                  ? 'Sending...'
                  : 'Verify email to use Watchlist',
              style: AdaptiveButtonStyle.filled,
            ),
          );
        }

        final ws = WatchlistService();
        final movieId = widget.movieId;

        return StreamBuilder<bool>(
          stream: ws.watchlistStatus(movieId),
          builder: (context, snap) {
            final inWatchlist = snap.data ?? false;
            return SizedBox(
              width: double.infinity,
              child: AdaptiveButton(
                onPressed: _isWatchlistBusy
                    ? null
                    : () async {
                        if (_movie == null) return;
                        setState(() => _isWatchlistBusy = true);
                        try {
                          if (inWatchlist) {
                            await ws.removeMovie(movieId);
                          } else {
                            await ws.addMovie(
                              movieId: movieId,
                              title: _movie!.title,
                              posterPath: _movie!.posterPath,
                              rating: _movie!.voteAverage,
                              releaseDate: _movie!.releaseDate,
                              genres: _movie!.genres,
                              runtime: _movie!.runtimeFormatted,
                            );
                          }
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not update watchlist. Please try again.',
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isWatchlistBusy = false);
                          }
                        }
                      },
                label: _isWatchlistBusy
                    ? 'Updating...'
                    : inWatchlist
                    ? 'Remove from Watchlist'
                    : 'Add to Watchlist',
                style: AdaptiveButtonStyle.filled,
              ),
            );
          },
        );
      },
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
            color: Colors.blue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.5),
              width: 1,
            ),
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
        _buildSectionHeader('Synopsis'),
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

  Widget _buildTagline(MovieModel movie) {
    return Text(
      '"${movie.tagline!}"',
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 15,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCrewHighlights(MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie.directors.isNotEmpty) ...[
          _buildCrewRow(
            'Director',
            movie.directors.map((d) => d.name).join(', '),
          ),
          const SizedBox(height: 10),
        ],
        if (movie.writers.isNotEmpty) ...[
          _buildCrewRow('Writer', movie.writers.map((w) => w.name).join(', ')),
        ],
      ],
    );
  }

  Widget _buildCrewRow(String role, String names) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            role,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            names,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCastList(MovieModel movie) {
    final topCast = movie.cast.take(20).toList();
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: topCast.length,
        itemBuilder: (context, index) {
          final member = topCast[index];
          return Container(
            width: 110,
            margin: EdgeInsets.only(right: index < topCast.length - 1 ? 12 : 0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: member.profileUrl.isNotEmpty
                      ? Image.network(
                          member.profileUrl,
                          width: 100,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholderAvatar(),
                        )
                      : _buildPlaceholderAvatar(),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  member.character,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.white30),
    );
  }

  Widget _buildTrailerCard(MovieVideo trailer) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(trailer.youtubeUrl);
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } catch (e) {
          debugPrint('Could not launch trailer: $e');
        }
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (trailer.youtubeThumbnail.isNotEmpty)
              Image.network(
                trailer.youtubeThumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                trailer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(MovieModel movie) {
    final items = <MapEntry<String, String>>[];

    if (movie.status != null && movie.status!.isNotEmpty) {
      items.add(MapEntry('Status', movie.status!));
    }
    if (movie.languageName.isNotEmpty) {
      items.add(MapEntry('Language', movie.languageName));
    }
    if (movie.budgetFormatted.isNotEmpty) {
      items.add(MapEntry('Budget', movie.budgetFormatted));
    }
    if (movie.revenueFormatted.isNotEmpty) {
      items.add(MapEntry('Revenue', movie.revenueFormatted));
    }
    if (movie.voteCount > 0) {
      items.add(MapEntry('Votes', _formatVoteCount(movie.voteCount)));
    }
    if (movie.popularity > 0) {
      items.add(MapEntry('Popularity', movie.popularity.toStringAsFixed(1)));
    }
    if (movie.productionCompanies.isNotEmpty) {
      items.add(
        MapEntry('Studio', movie.productionCompanies.take(2).join(', ')),
      );
    }
    if (movie.spokenLanguages.isNotEmpty) {
      items.add(
        MapEntry('Languages', movie.spokenLanguages.take(3).join(', ')),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (idx > 0)
                Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 20,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      item.key,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatVoteCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildSimilarMovies(MovieModel movie) {
    final similar = movie.similarMovies.take(15).toList();
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: similar.length,
        itemBuilder: (context, index) {
          final m = similar[index];
          return GestureDetector(
            onTap: () => context.push('/${RouteNames.movieDetail}/${m.id}'),
            child: Container(
              width: 130,
              margin: EdgeInsets.only(
                right: index < similar.length - 1 ? 12 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: m.posterUrl.isNotEmpty
                        ? Image.network(
                            m.posterUrl,
                            width: 130,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPosterPlaceholder(),
                          )
                        : _buildPosterPlaceholder(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    m.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        m.ratingFormatted,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      if (m.releaseYear > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${m.releaseYear}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      width: 130,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.movie, size: 40, color: Colors.white30),
    );
  }
}
