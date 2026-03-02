class MovieModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final List<String> genres;
  final int? runtime;

  const MovieModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    required this.genres,
    this.runtime,
  });

  // TMDB genre ID → human-readable name map
  static const Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Detail endpoint returns genres as [{id, name}], discover returns genre_ids as [int]
    final rawGenres = json['genres'] as List<dynamic>?;
    final List<String> genreNames;
    final List<int> genreIds;

    if (rawGenres != null) {
      // Full detail response
      genreNames = rawGenres
          .map((g) => (g as Map<String, dynamic>)['name'] as String)
          .toList();
      genreIds = rawGenres
          .map((g) => (g as Map<String, dynamic>)['id'] as int)
          .toList();
    } else {
      // Discover/list response
      genreIds =
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [];
      genreNames = genreIds
          .map((id) => genreMap[id] ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    }

    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      originalTitle: (json['original_title'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      releaseDate: (json['release_date'] as String?) ?? '',
      genreIds: genreIds,
      genres: genreNames,
      runtime: json['runtime'] as int?,
    );
  }

  String get posterUrl =>
      posterPath != null ? TmdbImageConfig.w500(posterPath!) : '';

  String get backdropUrl =>
      backdropPath != null ? TmdbImageConfig.w780(backdropPath!) : '';

  int get releaseYear {
    if (releaseDate.length >= 4) {
      return int.tryParse(releaseDate.substring(0, 4)) ?? 0;
    }
    return 0;
  }

  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  String get runtimeFormatted {
    if (runtime == null || runtime == 0) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

/// Convenience helpers for TMDB image URLs.
class TmdbImageConfig {
  static const String _base = 'https://image.tmdb.org/t/p';

  static String w500(String path) => '$_base/w500$path';
  static String w780(String path) => '$_base/w780$path';
  static String original(String path) => '$_base/original$path';
}
