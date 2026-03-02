import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie_model.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  /// Returns the API read-access token loaded from .env.
  static String get _token => dotenv.env['TMDB_READ_TOKEN'] ?? '';

  /// Default headers for all authenticated requests.
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'accept': 'application/json',
  };

  // ── Mood → Genre IDs ────────────────────────────────────────────────────────
  // TMDB genre IDs reference:
  //   28 Action | 12 Adventure | 16 Animation | 35 Comedy | 80 Crime
  //   99 Documentary | 18 Drama | 10751 Family | 14 Fantasy | 36 History
  //   27 Horror | 10402 Music | 9648 Mystery | 10749 Romance | 878 Sci-Fi
  //   10770 TV Movie | 53 Thriller | 10752 War | 37 Western
  //
  // These are joined with '|' (OR) so a movie only needs to match ONE genre.
  static const Map<String, List<int>> moodGenres = {
    // Relaxing — light romance, soft comedy, easy drama, animation
    'Chill': [10749, 35, 16, 10751],
    // Feel-good — comedy, animation, family, music
    'Happy': [35, 16, 10751, 10402],
    // Emotional — drama, music, romance (tearjerkers)
    'Sad': [18, 10402, 10749],
    // High-energy — action, adventure, sci-fi, thriller
    'Excited': [28, 12, 878, 53],
    // Love stories — romance first, drama, comedy
    'Romantic': [10749, 18, 35],
    // Low-effort watching — animation, family, comedy
    'Tired': [16, 10751, 35],
    // Cerebral — drama, history, mystery, documentary
    'Thoughtful': [18, 36, 9648, 99],
    // Exploratory — documentary, mystery, sci-fi, history, fantasy
    'Curious': [99, 9648, 878, 36, 14],
  };

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Discover movies filtered by mood (→ genres) and a minimum runtime.
  /// Prioritises English movies; fills remaining slots with highly-rated
  /// non-English titles.  Each call picks a random page so results differ
  /// even for the same mood/runtime combination.
  Future<List<MovieModel>> discoverMovies({
    required String mood,
    int? minMinutes,
    String? language,
  }) async {
    final genres = (moodGenres[mood] ?? []).join('|');
    final rng = Random();

    // -- 1. English movies (random page 1-5) --
    final enPage = rng.nextInt(5) + 1;
    final enParams = <String, String>{
      'sort_by': 'vote_average.desc',
      'vote_count.gte': '200',
      'vote_average.gte': '6.0',
      'with_original_language': language ?? 'en',
      'page': '$enPage',
      if (genres.isNotEmpty) 'with_genres': genres,
      if (minMinutes != null && minMinutes > 0)
        'with_runtime.gte': '$minMinutes',
    };
    final enUri = Uri.parse('$_baseUrl/discover/movie')
        .replace(queryParameters: enParams);
    final enResponse = await http.get(enUri, headers: _headers);
    _checkStatus(enResponse);
    final enData = jsonDecode(enResponse.body) as Map<String, dynamic>;
    final enResults = (enData['results'] as List<dynamic>)
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // If a specific language filter was applied, return those results directly.
    if (language != null) {
      enResults.shuffle(rng);
      return enResults;
    }

    // -- 2. High-rated non-English movies (random page 1-3) --
    final intlPage = rng.nextInt(3) + 1;
    final intlParams = <String, String>{
      'sort_by': 'vote_average.desc',
      'vote_count.gte': '500',
      'vote_average.gte': '7.5',
      'without_original_language': 'en',
      'page': '$intlPage',
      if (genres.isNotEmpty) 'with_genres': genres,
      if (minMinutes != null && minMinutes > 0)
        'with_runtime.gte': '$minMinutes',
    };
    final intlUri = Uri.parse('$_baseUrl/discover/movie')
        .replace(queryParameters: intlParams);
    final intlResponse = await http.get(intlUri, headers: _headers);
    _checkStatus(intlResponse);
    final intlData = jsonDecode(intlResponse.body) as Map<String, dynamic>;
    final intlResults = (intlData['results'] as List<dynamic>)
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // -- 3. Merge: English first, then sprinkle in international titles --
    // Keep up to ~15 English + up to ~5 international, then shuffle.
    final merged = <MovieModel>[
      ...enResults.take(15),
      ...intlResults.take(5),
    ];
    merged.shuffle(rng);
    return merged;
  }

  /// Fetch full movie details including runtime, credits, and similar movies.
  /// Uses `append_to_response` to get everything in a single API call.
  Future<MovieModel> getMovieDetails(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId').replace(
      queryParameters: {'append_to_response': 'credits,similar,videos'},
    );
    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return MovieModel.fromJson(data);
  }

  /// Search movies by a text query.
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/search/movie',
    ).replace(queryParameters: {'query': query, 'page': '$page'});

    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get popular movies (useful for default/fallback lists).
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/popular',
    ).replace(queryParameters: {'page': '$page'});

    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TmdbException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }
  }

  String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['status_message'] as String? ?? 'Unknown TMDB error';
    } catch (_) {
      return 'Unknown TMDB error';
    }
  }
}

class TmdbException implements Exception {
  final int statusCode;
  final String message;

  const TmdbException({required this.statusCode, required this.message});

  @override
  String toString() => 'TmdbException($statusCode): $message';
}
