import 'dart:convert';

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

  /// Discover movies filtered by mood (→ genres) and a minimum runtime in minutes.
  /// Genres are joined with '|' (OR logic) so results are broad.
  /// Returns up to 20 movies (one page from TMDB).
  Future<List<MovieModel>> discoverMovies({
    required String mood,
    int? minMinutes,
    int page = 1,
  }) async {
    // Use '|' = OR so a movie only needs to match one of the mood genres.
    final genres = (moodGenres[mood] ?? []).join('|');

    final queryParams = <String, String>{
      'sort_by': 'vote_average.desc',
      'vote_count.gte': '200',
      'vote_average.gte': '6.0',
      'page': '$page',
      if (genres.isNotEmpty) 'with_genres': genres,
      // Minimum runtime: movies must be AT LEAST this long
      if (minMinutes != null && minMinutes > 0)
        'with_runtime.gte': '$minMinutes',
    };

    final uri = Uri.parse(
      '$_baseUrl/discover/movie',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
