import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Reference to the current user's watchlist collection
  CollectionReference<Map<String, dynamic>> get _watchlistRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(uid).collection('watchlist');
  }

  /// Add a movie to the watchlist
  Future<void> addMovie({
    required String movieId,
    required String title,
    required String? posterPath,
    required double rating,
    required String? releaseDate,
    required List<String> genres,
    required String? runtime,
  }) async {
    final trimmedMovieId = movieId.trim();
    if (trimmedMovieId.isEmpty) {
      throw ArgumentError('movieId cannot be empty');
    }
    final normalizedGenres = genres
        .where((g) => g.trim().isNotEmpty)
        .map((g) => g.trim())
        .take(12)
        .toList();
    await _watchlistRef.doc(trimmedMovieId).set({
      'movieId': trimmedMovieId,
      'title': title.trim(),
      'posterPath': posterPath,
      'rating': rating.isNaN ? 0.0 : rating,
      'releaseDate': releaseDate,
      'genres': normalizedGenres,
      'runtime': runtime,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a movie from the watchlist
  Future<void> removeMovie(String movieId) async {
    await _watchlistRef.doc(movieId).delete();
  }

  /// Check if a movie is in the watchlist
  Future<bool> isInWatchlist(String movieId) async {
    final doc = await _watchlistRef.doc(movieId).get();
    return doc.exists;
  }

  /// Stream of whether a specific movie is in the watchlist (real-time)
  Stream<bool> watchlistStatus(String movieId) {
    return _watchlistRef.doc(movieId).snapshots().map((s) => s.exists);
  }

  /// Stream of all watchlist movies (real-time, ordered by date added)
  Stream<List<Map<String, dynamic>>> watchlistStream() {
    return _watchlistRef
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get watchlist count
  Future<int> watchlistCount() async {
    final snapshot = await _watchlistRef.count().get();
    return snapshot.count ?? 0;
  }
}
