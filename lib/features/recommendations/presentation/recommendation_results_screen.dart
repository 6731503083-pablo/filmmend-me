import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/movie_model.dart';
import '../../../services/tmdb_service.dart';

class RecommendationResultsScreen extends StatefulWidget {
  const RecommendationResultsScreen({super.key, this.mood, this.maxMinutes});

  final String? mood;
  final int? maxMinutes;

  @override
  State<RecommendationResultsScreen> createState() =>
      _RecommendationResultsScreenState();
}

class _RecommendationResultsScreenState
    extends State<RecommendationResultsScreen> {
  late Future<List<MovieModel>> _moviesFuture;
  final _service = TmdbService();

  // Mutable filter state — initialised from widget params
  late String? _activeMood;
  late int? _activeMinMinutes;
  String? _activeLanguage; // null = English-priority default

  @override
  void initState() {
    super.initState();
    _activeMood = widget.mood;
    _activeMinMinutes = widget.maxMinutes;
    _load();
  }

  void _load() {
    final hasFilters =
        _activeMood != null ||
        (_activeMinMinutes != null && _activeMinMinutes! > 0) ||
        _activeLanguage != null;

    if (hasFilters) {
      _moviesFuture = _service.discoverMovies(
        mood: _activeMood,
        minMinutes: _activeMinMinutes,
        language: _activeLanguage,
      );
    } else {
      _moviesFuture = _service.getPopularMovies();
    }
  }

  String get _title {
    if (_activeMood != null) return '$_activeMood Picks';
    return 'Popular Right Now';
  }

  String get _subtitle {
    final parts = <String>[];
    if (_activeMood != null) parts.add('Mood: $_activeMood');
    if (_activeMinMinutes != null && _activeMinMinutes! > 0) {
      parts.add('At least $_activeMinMinutes min');
    }
    if (_activeLanguage != null) {
      parts.add(_languageLabel(_activeLanguage!));
    }
    if (parts.isEmpty) return 'Top movies right now';
    return parts.join('  ·  ');
  }

  // ── Filter count badge ─────────────────────────────────────────────────────
  int get _activeFilterCount {
    int count = 0;
    if (_activeMood != null) count++;
    if (_activeMinMinutes != null && _activeMinMinutes! > 0) count++;
    if (_activeLanguage != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Filters',
                onPressed: () => _showFilterSheet(context),
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Refresh / shuffle button
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Shuffle',
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              _subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MovieModel>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                final movies = snapshot.data ?? [];
                if (movies.isEmpty) return _buildEmpty();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      title: movie.title,
                      posterUrl: movie.posterUrl,
                      rating: movie.voteAverage,
                      runtime: movie.runtimeFormatted,
                      genres: movie.genres.take(3).toList(),
                      onTap: () {
                        context.push('/${RouteNames.movieDetail}/${movie.id}');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Bottom Sheet ────────────────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    // Temporary state for the sheet
    String? sheetMood = _activeMood;
    int sheetMinMinutes = _activeMinMinutes ?? 0;
    String? sheetLanguage = _activeLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            sheetMood = null;
                            sheetMinMinutes = 0;
                            sheetLanguage = null;
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Mood picker ────────────────────────────────────────────
                  const Text(
                    'Mood',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TmdbService.moodGenres.keys.map((mood) {
                      final isSelected = sheetMood == mood;
                      return GestureDetector(
                        onTap: () => setSheetState(
                          () => sheetMood = isSelected ? null : mood,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            mood,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Minimum Duration slider ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minimum Duration',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        sheetMinMinutes > 0 ? '$sheetMinMinutes min' : 'Any',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: sheetMinMinutes.toDouble(),
                    min: 0,
                    max: 180,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white12,
                    label: sheetMinMinutes > 0 ? '$sheetMinMinutes min' : 'Any',
                    onChanged: (v) =>
                        setSheetState(() => sheetMinMinutes = v.toInt()),
                  ),
                  const SizedBox(height: 16),

                  // ── Language picker ────────────────────────────────────────
                  const Text(
                    'Language',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _languageOptions.map((lang) {
                      final isSelected = sheetLanguage == lang['code'];
                      return GestureDetector(
                        onTap: () => setSheetState(
                          () =>
                              sheetLanguage = isSelected ? null : lang['code'],
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            lang['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // ── Apply button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _activeMood = sheetMood;
                          _activeMinMinutes = sheetMinMinutes > 0
                              ? sheetMinMinutes
                              : null;
                          _activeLanguage = sheetLanguage;
                          _load();
                        });
                      },
                      height: 52,
                      borderRadius: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Language helpers ───────────────────────────────────────────────────────
  static const List<Map<String, String?>> _languageOptions = [
    {'code': null, 'label': 'All (English first)'},
    {'code': 'en', 'label': 'English only'},
    {'code': 'ko', 'label': 'Korean'},
    {'code': 'ja', 'label': 'Japanese'},
    {'code': 'fr', 'label': 'French'},
    {'code': 'es', 'label': 'Spanish'},
    {'code': 'hi', 'label': 'Hindi'},
    {'code': 'de', 'label': 'German'},
    {'code': 'zh', 'label': 'Chinese'},
    {'code': 'th', 'label': 'Thai'},
    {'code': 'my', 'label': 'Burmese'},
  ];

  String _languageLabel(String code) {
    final match = _languageOptions.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'label': code.toUpperCase()},
    );
    return match['label'] ?? code;
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              'Couldn\'t load movies',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Try Again',
              onPressed: () => setState(_load),
              height: 48,
              borderRadius: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_outlined, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            'No movies found',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your mood or time filter.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
