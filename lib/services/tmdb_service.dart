import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie_model.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const int _targetResultCount = 20;
  static final http.Client _client = http.Client();

  static const Duration _listCacheTtl = Duration(minutes: 10);
  static const Duration _detailCacheTtl = Duration(minutes: 30);
  static const Duration _searchCacheTtl = Duration(minutes: 5);
  static const Duration _popularCacheTtl = Duration(minutes: 5);

  static final Map<String, _CacheEntry<List<MovieModel>>> _listCache = {};
  static final Map<String, _CacheEntry<MovieModel>> _detailCache = {};
  static final Map<String, Future<List<MovieModel>>> _listInFlight = {};
  static final Map<String, Future<MovieModel>> _detailInFlight = {};

  /// CI injects the real token by replacing __TMDB_TOKEN__ via sed.
  /// For local dev/release overrides, use --dart-define=TMDB_READ_TOKEN=...
  static const String _ciToken = '__TMDB_TOKEN__';
  static const String _dartDefineToken = String.fromEnvironment(
    'TMDB_READ_TOKEN',
    defaultValue: '',
  );

  /// Fallback rules used when backend-configured rules are unavailable.
  static const Map<String, List<int>> fallbackMoodGenres = {
    'Chill': [10749, 35, 16, 10751],
    'Happy': [35, 16, 10751, 10402],
    'Sad': [18, 10402, 10749],
    'Excited': [28, 12, 878, 53],
    'Romantic': [10749, 18, 35],
    'Tired': [16, 10751, 35],
    'Thoughtful': [18, 36, 9648, 99],
    'Curious': [99, 9648, 878, 36, 14],
    'Nostalgic': [18, 10751, 10402, 36],
    'Adventurous': [12, 14, 878, 28],
    'Spooky': [27, 53, 9648],
    'Inspired': [36, 18, 99, 10402],
  };

  /// Compatibility alias for existing UI usages.
  static Map<String, List<int>> get moodGenres => fallbackMoodGenres;

  static DateTime? _moodRulesLoadedAt;
  static Map<String, List<int>>? _cachedMoodRules;
  static const Duration _moodRulesCacheDuration = Duration(minutes: 20);

  static String get _dotenvToken {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['TMDB_READ_TOKEN']?.trim() ?? '';
  }

  /// Returns the API read-access token.
  static String get _token {
    if (!_ciToken.startsWith('__')) return _ciToken;
    if (_dartDefineToken.trim().isNotEmpty) return _dartDefineToken;
    return _dotenvToken;
  }

  /// Default headers for all authenticated requests.
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'accept': 'application/json',
  };

  static void _ensureTokenConfigured() {
    if (_token.trim().isEmpty) {
      throw const TmdbException(
        statusCode: 0,
        message:
            'Movie service is not configured. Please contact support or try again later.',
        kind: TmdbFailureKind.configuration,
      );
    }
  }

  Future<List<String>> getAvailableMoods() async {
    final rules = await _getMoodRules();
    return rules.keys.toList();
  }

  Future<Map<String, List<int>>> _getMoodRules() async {
    if (_cachedMoodRules != null &&
        _moodRulesLoadedAt != null &&
        DateTime.now().difference(_moodRulesLoadedAt!) <
            _moodRulesCacheDuration) {
      return _cachedMoodRules!;
    }

    if (!_firebaseReady) {
      return fallbackMoodGenres;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('recommendation_rules')
          .get();
      final dynamic rawRules = doc.data()?['moodGenres'];
      final parsedRules = _parseMoodRules(rawRules);
      if (parsedRules.isNotEmpty) {
        _cachedMoodRules = parsedRules;
        _moodRulesLoadedAt = DateTime.now();
        return parsedRules;
      }
    } catch (_) {
      // Fall back to defaults when backend rules are missing/unavailable.
    }

    _cachedMoodRules = fallbackMoodGenres;
    _moodRulesLoadedAt = DateTime.now();
    return fallbackMoodGenres;
  }

  Map<String, List<int>> _parseMoodRules(dynamic raw) {
    if (raw is! Map) return <String, List<int>>{};
    final parsed = <String, List<int>>{};
    for (final entry in raw.entries) {
      final key = entry.key?.toString();
      final value = entry.value;
      if (key == null || key.trim().isEmpty || value is! List) continue;
      final genreIds = value
          .whereType<num>()
          .map((e) => e.toInt())
          .where((id) => id > 0)
          .toList();
      if (genreIds.isNotEmpty) {
        parsed[key.trim()] = genreIds;
      }
    }
    return parsed;
  }

  /// Discover movies filtered by mood (→ genres) and a minimum runtime.
  /// Uses deterministic pagination, ranking and explainability.
  Future<List<MovieModel>> discoverMovies({
    String? mood,
    int? minMinutes,
    String? language,
  }) async {
    final cacheKey = _buildDiscoverCacheKey(
      mood: mood,
      minMinutes: minMinutes,
      language: language,
    );
    final cached = _getCachedList(cacheKey);
    if (cached != null) return cached;

    return _getOrFetchList(cacheKey, _listCacheTtl, () async {
      try {
        _ensureTokenConfigured();

        final moodRules = await _getMoodRules();
        final moodGenresForFilter = mood == null
            ? <int>[]
            : (moodRules[mood] ?? []);
        final context = _RecommendationContext(
          mood: mood,
          minMinutes: minMinutes,
          language: language,
          moodGenreIds: moodGenresForFilter,
        );

        final primaryPages = [
          _stablePage(context.seed, maxPage: 5, salt: 0),
          _stablePage(context.seed, maxPage: 5, salt: 1),
        ];
        final intlPages = [
          _stablePage(context.seed, maxPage: 3, salt: 2),
          _stablePage(context.seed, maxPage: 3, salt: 3),
        ];

        final englishFuture = _fetchDiscoverPages(
          pages: primaryPages,
          context: context,
          withOriginalLanguage: language ?? 'en',
          withoutOriginalLanguage: null,
          voteCountGte: language == null ? 150 : 100,
          voteAverageGte: 6.0,
        );

        final intlFuture = language != null
            ? Future.value(<MovieModel>[])
            : _fetchDiscoverPages(
                pages: intlPages,
                context: context,
                withOriginalLanguage: null,
                withoutOriginalLanguage: 'en',
                voteCountGte: 250,
                voteAverageGte: 6.8,
              );

        final results = await Future.wait([englishFuture, intlFuture]);
        final englishOrLanguageResults = results[0];
        final intlResults = results[1];

        final fallbackResults =
            (englishOrLanguageResults.length + intlResults.length) <
                _targetResultCount
            ? await _fetchFallbackPopular(context)
            : <MovieModel>[];

        final combined = _dedupeById([
          ...englishOrLanguageResults,
          ...intlResults,
          ...fallbackResults,
        ]);

        final ranked = _rankMovies(combined, context);
        return ranked.take(_targetResultCount).toList();
      } on TmdbException {
        rethrow;
      } catch (_) {
        throw const TmdbException(
          statusCode: 0,
          message: 'Could not load recommendations. Please try again shortly.',
          kind: TmdbFailureKind.client,
        );
      }
    });
  }

  Future<List<MovieModel>> _fetchDiscoverPages({
    required List<int> pages,
    required _RecommendationContext context,
    required String? withOriginalLanguage,
    required String? withoutOriginalLanguage,
    required int voteCountGte,
    required double voteAverageGte,
  }) async {
    final futures = pages.map((page) async {
      final params = <String, String>{
        'sort_by': 'popularity.desc',
        'include_adult': 'false',
        'include_video': 'false',
        'vote_count.gte': '$voteCountGte',
        'vote_average.gte': voteAverageGte.toStringAsFixed(1),
        'page': '$page',
        'region': 'US',
        if (withOriginalLanguage != null)
          'with_original_language': withOriginalLanguage,
        if (withoutOriginalLanguage != null)
          'without_original_language': withoutOriginalLanguage,
        if (context.moodGenreIds.isNotEmpty)
          'with_genres': context.moodGenreIds.join('|'),
        if (context.minMinutes != null && context.minMinutes! > 0)
          'with_runtime.gte': '${context.minMinutes}',
      };
      final uri = Uri.parse(
        '$_baseUrl/discover/movie',
      ).replace(queryParameters: params);
      final response = await _getWithRetry(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>? ?? const [])
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }).toList();

    final pagesResults = await Future.wait(futures);
    return pagesResults.expand((results) => results).toList();
  }

  Future<List<MovieModel>> _fetchFallbackPopular(
    _RecommendationContext context,
  ) async {
    final pages = [
      _stablePage(context.seed, maxPage: 3, salt: 4),
      _stablePage(context.seed, maxPage: 3, salt: 5),
    ];
    final futures = pages.map((page) async {
      final params = <String, String>{
        'include_adult': 'false',
        'language': 'en-US',
        'region': 'US',
        'page': '$page',
      };
      final uri = Uri.parse(
        '$_baseUrl/movie/popular',
      ).replace(queryParameters: params);
      final response = await _getWithRetry(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>? ?? const [])
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }).toList();

    final pagesResults = await Future.wait(futures);
    return pagesResults.expand((results) => results).toList();
  }

  List<MovieModel> _rankMovies(
    List<MovieModel> movies,
    _RecommendationContext context,
  ) {
    if (movies.isEmpty) return const <MovieModel>[];
    final nowYear = DateTime.now().year;
    final selected = <MovieModel>[];
    final pool = List<MovieModel>.from(movies);
    final seenGenres = <int>{};

    while (pool.isNotEmpty && selected.length < _targetResultCount) {
      pool.sort((a, b) {
        final scoreA = _scoreMovie(
          movie: a,
          context: context,
          nowYear: nowYear,
          seenGenres: seenGenres,
        );
        final scoreB = _scoreMovie(
          movie: b,
          context: context,
          nowYear: nowYear,
          seenGenres: seenGenres,
        );
        return scoreB.compareTo(scoreA);
      });
      final picked = pool.removeAt(0);
      selected.add(picked);
      seenGenres.addAll(picked.genreIds);
    }

    return selected
        .map(
          (movie) =>
              movie.withRecommendationReason(_buildReason(movie, context)),
        )
        .toList();
  }

  double _scoreMovie({
    required MovieModel movie,
    required _RecommendationContext context,
    required int nowYear,
    required Set<int> seenGenres,
  }) {
    final normalizedRating = (movie.voteAverage.clamp(0, 10) / 10).toDouble();
    final votesScore = min(log(movie.voteCount + 1) / log(5000), 1.0);
    final popularityScore = min(
      (movie.popularity.clamp(0, 100) / 100).toDouble(),
      1.0,
    );

    final year = movie.releaseYear;
    final yearsOld = year > 0 ? max(0, nowYear - year) : 40;
    final freshnessScore = 1 - min(yearsOld / 40, 1.0);

    final relevantGenres = context.moodGenreIds.toSet();
    final overlap = relevantGenres.isEmpty
        ? 0.0
        : movie.genreIds.where(relevantGenres.contains).length /
              relevantGenres.length;

    final introducesNewGenre = movie.genreIds.any(
      (id) => !seenGenres.contains(id),
    );
    final diversityBonus = introducesNewGenre ? 0.08 : 0.0;

    return (normalizedRating * 0.40) +
        (votesScore * 0.20) +
        (popularityScore * 0.15) +
        (freshnessScore * 0.15) +
        (overlap * 0.10) +
        diversityBonus;
  }

  String _buildReason(MovieModel movie, _RecommendationContext context) {
    final reasons = <String>[];
    if (context.mood != null) {
      reasons.add('matches your ${context.mood} mood');
    }
    if (context.minMinutes != null && context.minMinutes! > 0) {
      reasons.add('fits your ${context.minMinutes}m+ duration filter');
    }
    if (movie.voteAverage >= 7.2) {
      reasons.add('has strong viewer ratings');
    } else if (movie.popularity >= 30) {
      reasons.add('is trending with viewers');
    }
    if (movie.releaseYear >= DateTime.now().year - 6) {
      reasons.add('is relatively recent');
    }
    if (reasons.isEmpty) {
      return 'Recommended because it is currently popular.';
    }
    return 'Recommended because it ${reasons.join(', ')}.';
  }

  List<MovieModel> _dedupeById(List<MovieModel> movies) {
    final seen = <int>{};
    final deduped = <MovieModel>[];
    for (final movie in movies) {
      if (seen.add(movie.id)) {
        deduped.add(movie);
      }
    }
    return deduped;
  }

  int _stablePage(int seed, {required int maxPage, required int salt}) {
    final value = (seed + (salt * 31)) % maxPage;
    return value + 1;
  }

  /// Fetch full movie details including runtime, credits, and similar movies.
  /// Uses `append_to_response` to get everything in a single API call.
  Future<MovieModel> getMovieDetails(int movieId) async {
    final cacheKey = 'detail:$movieId';
    final cached = _getCachedDetail(cacheKey);
    if (cached != null) return cached;

    return _getOrFetchDetail(cacheKey, _detailCacheTtl, () async {
      _ensureTokenConfigured();
      final uri = Uri.parse('$_baseUrl/movie/$movieId').replace(
        queryParameters: {'append_to_response': 'credits,similar,videos'},
      );
      final response = await _getWithRetry(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MovieModel.fromJson(data);
    });
  }

  /// Search movies by a text query.
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const <MovieModel>[];

    final cacheKey = 'search:$normalizedQuery:$page';
    final cached = _getCachedList(cacheKey);
    if (cached != null) return cached;

    _ensureTokenConfigured();
    final uri = Uri.parse(
      '$_baseUrl/search/movie',
    ).replace(queryParameters: {'query': normalizedQuery, 'page': '$page'});

    return _getOrFetchList(cacheKey, _searchCacheTtl, () async {
      try {
        final response = await _getWithRetry(uri);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? const [];
        return results
            .whereType<Map<String, dynamic>>()
            .map(MovieModel.fromJson)
            .toList();
      } on TmdbException {
        rethrow;
      } catch (_) {
        throw const TmdbException(
          statusCode: 0,
          message: 'Could not parse search results. Please try again.',
          kind: TmdbFailureKind.client,
        );
      }
    });
  }

  /// Get popular movies (useful for default/fallback lists).
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final cacheKey = 'popular:$page';
    final cached = _getCachedList(cacheKey);
    if (cached != null) return cached;

    _ensureTokenConfigured();
    final uri = Uri.parse('$_baseUrl/movie/popular').replace(
      queryParameters: {
        'page': '$page',
        'include_adult': 'false',
        'region': 'US',
      },
    );

    return _getOrFetchList(cacheKey, _popularCacheTtl, () async {
      try {
        final response = await _getWithRetry(uri);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? const [];
        return results
            .whereType<Map<String, dynamic>>()
            .map(MovieModel.fromJson)
            .toList();
      } on TmdbException {
        rethrow;
      } catch (_) {
        throw const TmdbException(
          statusCode: 0,
          message: 'Could not parse popular movies. Please try again.',
          kind: TmdbFailureKind.client,
        );
      }
    });
  }

  Future<http.Response> _getWithRetry(Uri uri, {int maxRetries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 10));
        _checkStatus(response);
        return response;
      } on TimeoutException {
        if (attempt >= maxRetries) {
          throw const TmdbException(
            statusCode: 0,
            message:
                'Request timed out. Please check your network and try again.',
            kind: TmdbFailureKind.network,
          );
        }
      } on SocketException {
        if (attempt >= maxRetries) {
          throw const TmdbException(
            statusCode: 0,
            message: 'No internet connection. Please reconnect and try again.',
            kind: TmdbFailureKind.network,
          );
        }
      } on http.ClientException {
        if (attempt >= maxRetries) {
          throw const TmdbException(
            statusCode: 0,
            message: 'Network request failed. Please try again.',
            kind: TmdbFailureKind.network,
          );
        }
      } on TmdbException catch (e) {
        if (!e.isRetryable || attempt >= maxRetries) rethrow;
      }

      attempt++;
      final backoffMs = 300 * attempt;
      await Future<void>.delayed(Duration(milliseconds: backoffMs));
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final statusCode = response.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      throw TmdbException(
        statusCode: statusCode,
        message: 'Movie service authorization failed. Please contact support.',
        kind: TmdbFailureKind.unauthorized,
      );
    }
    if (statusCode == 429) {
      throw TmdbException(
        statusCode: statusCode,
        message: 'Too many requests. Please try again shortly.',
        kind: TmdbFailureKind.rateLimited,
      );
    }
    if (statusCode >= 500) {
      throw TmdbException(
        statusCode: statusCode,
        message: 'Movie service is temporarily unavailable. Please try again.',
        kind: TmdbFailureKind.server,
      );
    }

    throw TmdbException(
      statusCode: statusCode,
      message: _parseErrorMessage(response.body),
      kind: TmdbFailureKind.client,
    );
  }

  String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['status_message'] as String? ?? 'Unknown TMDB error';
    } catch (_) {
      return 'Unknown TMDB error';
    }
  }

  List<MovieModel>? _getCachedList(String key) {
    final entry = _listCache[key];
    if (entry == null || !entry.isValid) return null;
    return entry.value;
  }

  MovieModel? _getCachedDetail(String key) {
    final entry = _detailCache[key];
    if (entry == null || !entry.isValid) return null;
    return entry.value;
  }

  Future<List<MovieModel>> _getOrFetchList(
    String key,
    Duration ttl,
    Future<List<MovieModel>> Function() loader,
  ) async {
    final cached = _getCachedList(key);
    if (cached != null) return cached;
    final inflight = _listInFlight[key];
    if (inflight != null) return inflight;

    final future = loader();
    _listInFlight[key] = future;
    try {
      final value = await future;
      _listCache[key] = _CacheEntry(value, ttl);
      return value;
    } finally {
      _listInFlight.remove(key);
    }
  }

  Future<MovieModel> _getOrFetchDetail(
    String key,
    Duration ttl,
    Future<MovieModel> Function() loader,
  ) async {
    final cached = _getCachedDetail(key);
    if (cached != null) return cached;
    final inflight = _detailInFlight[key];
    if (inflight != null) return inflight;

    final future = loader();
    _detailInFlight[key] = future;
    try {
      final value = await future;
      _detailCache[key] = _CacheEntry(value, ttl);
      return value;
    } finally {
      _detailInFlight.remove(key);
    }
  }

  String _buildDiscoverCacheKey({
    required String? mood,
    required int? minMinutes,
    required String? language,
  }) {
    final dayBucket =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;
    return 'discover:${mood ?? ''}:${minMinutes ?? 0}:${language ?? ''}:$dayBucket';
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  _CacheEntry(this.value, Duration ttl) : expiresAt = DateTime.now().add(ttl);

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

bool get _firebaseReady {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (_) {
    return false;
  }
}

class _RecommendationContext {
  final String? mood;
  final int? minMinutes;
  final String? language;
  final List<int> moodGenreIds;

  const _RecommendationContext({
    required this.mood,
    required this.minMinutes,
    required this.language,
    required this.moodGenreIds,
  });

  int get seed {
    final dayBucket =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;
    final key = '${mood ?? ''}|${minMinutes ?? 0}|${language ?? ''}|$dayBucket';
    return key.hashCode.abs();
  }
}

enum TmdbFailureKind {
  network,
  unauthorized,
  rateLimited,
  server,
  client,
  configuration,
}

class TmdbException implements Exception {
  final int statusCode;
  final String message;
  final TmdbFailureKind kind;

  const TmdbException({
    required this.statusCode,
    required this.message,
    this.kind = TmdbFailureKind.client,
  });

  bool get isNetworkError => kind == TmdbFailureKind.network;
  bool get isRetryable =>
      kind == TmdbFailureKind.network ||
      kind == TmdbFailureKind.server ||
      kind == TmdbFailureKind.rateLimited;

  @override
  String toString() => message;
}
