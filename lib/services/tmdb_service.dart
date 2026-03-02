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
  static const Map<String, List<int>> moodGenres = {
    'Chill': [10749, 18, 35],
    'Happy': [35, 10751, 16],
    'Sad': [18, 10402],
    'Excited': [28, 12, 878],
    'Romantic': [10749, 18],
    'Tired': [16, 10751, 35],
    'Thoughtful': [18, 9648, 36],
    'Curious': [99, 9648, 878],
  };

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Discover movies filtered by mood (→ genres) and a max runtime in minutes.
  /// Returns up to 20 movies (one page from TMDB).
  Future<List<MovieModel>> discoverMovies({
    required String mood,
    int? maxMinutes,
    int page = 1,
  }) async {
    final genres = (moodGenres[mood] ?? []).join(',');

    final queryParams = <String, String>{
      'sort_by': 'popularity.desc',
      'vote_count.gte': '100',
      'page': '$page',
      if (genres.isNotEmpty) 'with_genres': genres,
      if (maxMinutes != null) 'with_runtime.lte': '$maxMinutes',
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

  /// Fetch full movie details including runtime.
  Future<MovieModel> getMovieDetails(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId');
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
