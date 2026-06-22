import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/firebase/firebase_safe.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/auth_service.dart';
import '../../../services/tmdb_service.dart';

class _MoodConfig {
  final IconData icon;
  final List<Color> gradient;

  const _MoodConfig({required this.icon, required this.gradient});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedMood;
  double availableTime = 90;
  bool _bannerDismissed = false;
  final TmdbService _service = TmdbService();
  List<String> _availableMoods = _defaultMoodOrder;

  static const List<String> _defaultMoodOrder = [
    'Chill',
    'Happy',
    'Romantic',
    'Nostalgic',
    'Sad',
    'Tired',
    'Thoughtful',
    'Curious',
    'Excited',
    'Adventurous',
    'Spooky',
    'Inspired',
  ];

  static const _MoodConfig _fallbackMoodConfig = _MoodConfig(
    icon: Icons.movie,
    gradient: [Color(0xFF2AFADF), Color(0xFF4C83FF)],
  );

  static const Map<String, _MoodConfig> _moodConfigs = {
    'Chill': _MoodConfig(
      icon: Icons.air,
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    'Happy': _MoodConfig(
      icon: Icons.sentiment_satisfied_alt,
      gradient: [Color(0xFFf093fb), Color(0xFFF5576C)],
    ),
    'Romantic': _MoodConfig(
      icon: Icons.favorite,
      gradient: [Color(0xFFff9a9e), Color(0xFFfad0c4)],
    ),
    'Nostalgic': _MoodConfig(
      icon: Icons.history_edu,
      gradient: [Color(0xFF8E7AB5), Color(0xFFB784B7)],
    ),
    'Sad': _MoodConfig(
      icon: Icons.sentiment_dissatisfied,
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
    'Tired': _MoodConfig(
      icon: Icons.bedtime,
      gradient: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
    ),
    'Thoughtful': _MoodConfig(
      icon: Icons.psychology,
      gradient: [Color(0xFF4A90E2), Color(0xFF357ABD)],
    ),
    'Curious': _MoodConfig(
      icon: Icons.visibility,
      gradient: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
    ),
    'Excited': _MoodConfig(
      icon: Icons.celebration,
      gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
    ),
    'Adventurous': _MoodConfig(
      icon: Icons.explore,
      gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    'Spooky': _MoodConfig(
      icon: Icons.nightlight_round,
      gradient: [Color(0xFF434343), Color(0xFF000000)],
    ),
    'Inspired': _MoodConfig(
      icon: Icons.emoji_objects,
      gradient: [Color(0xFFFFB75E), Color(0xFFED8F03)],
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadAvailableMoods();
  }

  Future<void> _loadAvailableMoods() async {
    try {
      final moods = await _service.getAvailableMoods();
      if (!mounted || moods.isEmpty) return;
      setState(() {
        _availableMoods = _normalizeMoodList(moods);
        if (selectedMood != null && !_availableMoods.contains(selectedMood)) {
          selectedMood = null;
        }
      });
    } catch (_) {
      // Keep fallback moods on failure.
    }
  }

  List<String> _normalizeMoodList(List<String> moods) {
    final normalized = <String>[];
    for (final mood in _defaultMoodOrder) {
      if (moods.contains(mood)) {
        normalized.add(mood);
      }
    }
    final extras = moods.where((m) => !normalized.contains(m)).toList()..sort();
    normalized.addAll(extras);
    return normalized.isEmpty ? _defaultMoodOrder : normalized;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final compactLayout = size.height < 860;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildVerificationBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    compactLayout ? 8 : 12,
                    20,
                    compactLayout ? 16 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(compactLayout: compactLayout),
                      SizedBox(height: compactLayout ? 16 : 32),
                      _buildMoodGrid(
                        compactLayout: compactLayout,
                        isAndroid: isAndroid,
                      ),
                      SizedBox(height: compactLayout ? 18 : 40),
                      _buildTimeSliderCard(compactLayout: compactLayout),
                      SizedBox(height: compactLayout ? 14 : 32),
                      _buildRecommendButton(compactLayout: compactLayout),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return StreamBuilder<User?>(
      stream: safeAuthStateChanges(),
      initialData: safeCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (_bannerDismissed || user == null || user.emailVerified) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Please verify your email address.',
                  style: TextStyle(color: Colors.amber, fontSize: 13),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await AuthService().resendVerificationEmail();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Verification email sent!')),
                    );
                  } catch (_) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Could not send verification email.'),
                      ),
                    );
                  }
                },
                child: const Text('Resend', style: TextStyle(fontSize: 13)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await AuthService().reloadCurrentUser();
                  } catch (_) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Could not refresh verification status.'),
                      ),
                    );
                  }
                },
                child: const Text('Verified', style: TextStyle(fontSize: 13)),
              ),
              InkWell(
                onTap: () => setState(() => _bannerDismissed = true),
                child: const Icon(Icons.close, color: Colors.amber, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filmmend Me',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go(
                  '/${RouteNames.recommendations}',
                  extra: {'mood': null, 'time': null},
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle({required bool compactLayout}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: compactLayout ? 26 : 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: compactLayout ? 6 : 8),
        Text(
          'Pick a mood to start',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: compactLayout ? 14 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodGrid({
    required bool compactLayout,
    required bool isAndroid,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380 || compactLayout;
        final crossAxisCount = isAndroid ? 4 : (isCompact ? 3 : 4);
        final iconBoxSize = isAndroid ? 54.0 : (isCompact ? 60.0 : 64.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: isAndroid ? 6 : (isCompact ? 8 : 12),
            crossAxisSpacing: isAndroid ? 6 : (isCompact ? 8 : 12),
            childAspectRatio: isAndroid ? 0.9 : (isCompact ? 1.0 : 0.85),
          ),
          itemCount: _availableMoods.length,
          itemBuilder: (context, index) {
            final moodLabel = _availableMoods[index];
            final config = _moodConfigs[moodLabel] ?? _fallbackMoodConfig;
            final isSelected = selectedMood == moodLabel;
            final gradientColors = config.gradient;

            return GestureDetector(
              onTap: () => setState(() {
                selectedMood = selectedMood == moodLabel ? null : moodLabel;
              }),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.glassHighlight
                            : AppColors.glassBorder,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: gradientColors.first.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      config.icon,
                      color: AppColors.textPrimary,
                      size: isAndroid ? 26 : (isCompact ? 28 : 30),
                    ),
                  ),
                  SizedBox(height: isAndroid ? 3 : (isCompact ? 4 : 6)),
                  Text(
                    moodLabel,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: isAndroid ? 10 : (isCompact ? 11 : 12),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeSliderCard({required bool compactLayout}) {
    return Container(
      padding: EdgeInsets.all(compactLayout ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        children: [
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${availableTime.toInt()} min',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compactLayout ? 12 : 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.glassBorder,
              thumbColor: AppColors.textPrimary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 6,
            ),
            child: Slider(
              value: availableTime,
              min: 0,
              max: 180,
              onChanged: (value) => setState(() => availableTime = value),
            ),
          ),
          SizedBox(height: compactLayout ? 2 : 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '0m',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              Text(
                '90m',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              Text(
                '180m',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendButton({required bool compactLayout}) {
    return GradientButton(
      text: 'Recommend Movie',
      onPressed: selectedMood != null
          ? () => context.go(
              '/${RouteNames.recommendations}',
              extra: {'mood': selectedMood!, 'time': availableTime.toInt()},
            )
          : null,
      height: compactLayout ? 54 : 60,
      borderRadius: 20,
    );
  }
}
