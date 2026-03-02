/// A cast member from the credits response.
class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      character: (json['character'] as String?) ?? '',
      profilePath: json['profile_path'] as String?,
      order: (json['order'] as int?) ?? 999,
    );
  }

  String get profileUrl =>
      profilePath != null ? TmdbImageConfig.w500(profilePath!) : '';
}

/// A crew member from the credits response.
class CrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  const CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      job: (json['job'] as String?) ?? '',
      department: (json['department'] as String?) ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  String get profileUrl =>
      profilePath != null ? TmdbImageConfig.w500(profilePath!) : '';
}

/// A video (trailer, teaser, etc.) from the videos response.
class MovieVideo {
  final String key;
  final String name;
  final String site;
  final String type;

  const MovieVideo({
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      key: (json['key'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      site: (json['site'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
    );
  }

  /// YouTube thumbnail URL.
  String get youtubeThumbnail =>
      site == 'YouTube' ? 'https://img.youtube.com/vi/$key/hqdefault.jpg' : '';

  /// YouTube watch URL.
  String get youtubeUrl =>
      site == 'YouTube' ? 'https://www.youtube.com/watch?v=$key' : '';
}

class MovieModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final List<String> genres;
  final int? runtime;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? status;
  final String? originalLanguage;
  final double popularity;
  final List<String> productionCompanies;
  final List<String> spokenLanguages;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final List<MovieModel> similarMovies;
  final List<MovieVideo> videos;

  const MovieModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.voteCount = 0,
    required this.releaseDate,
    required this.genreIds,
    required this.genres,
    this.runtime,
    this.tagline,
    this.budget,
    this.revenue,
    this.status,
    this.originalLanguage,
    this.popularity = 0,
    this.productionCompanies = const [],
    this.spokenLanguages = const [],
    this.cast = const [],
    this.crew = const [],
    this.similarMovies = const [],
    this.videos = const [],
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
      voteCount: (json['vote_count'] as int?) ?? 0,
      releaseDate: (json['release_date'] as String?) ?? '',
      genreIds: genreIds,
      genres: genreNames,
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      status: json['status'] as String?,
      originalLanguage: json['original_language'] as String?,
      popularity: ((json['popularity'] ?? 0) as num).toDouble(),
      productionCompanies:
          (json['production_companies'] as List<dynamic>?)
              ?.map((c) => (c as Map<String, dynamic>)['name'] as String)
              .toList() ??
          [],
      spokenLanguages:
          (json['spoken_languages'] as List<dynamic>?)
              ?.map(
                (l) => (l as Map<String, dynamic>)['english_name'] as String,
              )
              .toList() ??
          [],
      cast:
          (json['credits']?['cast'] as List<dynamic>?)
              ?.map((c) => CastMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      crew:
          (json['credits']?['crew'] as List<dynamic>?)
              ?.map((c) => CrewMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      similarMovies:
          (json['similar']?['results'] as List<dynamic>?)
              ?.map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      videos:
          (json['videos']?['results'] as List<dynamic>?)
              ?.map((v) => MovieVideo.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
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

  /// Director(s) extracted from crew.
  List<CrewMember> get directors =>
      crew.where((c) => c.job == 'Director').toList();

  /// Writers (Screenplay / Writer) extracted from crew.
  List<CrewMember> get writers =>
      crew.where((c) => c.job == 'Screenplay' || c.job == 'Writer').toList();

  /// Formatted budget string (e.g. "\$120M").
  String get budgetFormatted {
    if (budget == null || budget == 0) return '';
    if (budget! >= 1000000) {
      return '\$${(budget! / 1000000).toStringAsFixed(budget! % 1000000 == 0 ? 0 : 1)}M';
    }
    return '\$${budget!.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }

  /// Formatted revenue string.
  String get revenueFormatted {
    if (revenue == null || revenue == 0) return '';
    if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(revenue! % 1000000 == 0 ? 0 : 1)}M';
    }
    return '\$${revenue!.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }

  /// Get the first YouTube trailer, if available.
  MovieVideo? get trailer {
    final trailers = videos.where(
      (v) => v.site == 'YouTube' && v.type == 'Trailer',
    );
    if (trailers.isNotEmpty) return trailers.first;
    final teasers = videos.where(
      (v) => v.site == 'YouTube' && v.type == 'Teaser',
    );
    if (teasers.isNotEmpty) return teasers.first;
    return null;
  }

  /// Language name from ISO code.
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'hi': 'Hindi',
    'ar': 'Arabic',
    'th': 'Thai',
    'sv': 'Swedish',
    'da': 'Danish',
    'no': 'Norwegian',
    'fi': 'Finnish',
    'nl': 'Dutch',
    'pl': 'Polish',
    'tr': 'Turkish',
    'id': 'Indonesian',
    'ms': 'Malay',
    'tl': 'Filipino',
    'vi': 'Vietnamese',
    'cs': 'Czech',
    'el': 'Greek',
    'he': 'Hebrew',
    'hu': 'Hungarian',
    'ro': 'Romanian',
    'uk': 'Ukrainian',
    'my': 'Burmese',
  };

  String get languageName =>
      _languageNames[originalLanguage] ?? originalLanguage?.toUpperCase() ?? '';
}

/// Convenience helpers for TMDB image URLs.
class TmdbImageConfig {
  static const String _base = 'https://image.tmdb.org/t/p';

  static String w500(String path) => '$_base/w500$path';
  static String w780(String path) => '$_base/w780$path';
  static String original(String path) => '$_base/original$path';
}
