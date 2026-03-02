import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedMood;
  double availableTime = 90;
  bool _bannerDismissed = false;

  static const List<Map<String, dynamic>> _moods = [
    {
      'label': 'Chill',
      'icon': Icons.air,
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
    },
    {
      'label': 'Happy',
      'icon': Icons.sentiment_satisfied_alt,
      'gradient': [Color(0xFFf093fb), Color(0xFFF5576C)],
    },
    {
      'label': 'Sad',
      'icon': Icons.sentiment_dissatisfied,
      'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)],
    },
    {
      'label': 'Excited',
      'icon': Icons.celebration,
      'gradient': [Color(0xFFfa709a), Color(0xFFfee140)],
    },
    {
      'label': 'Romantic',
      'icon': Icons.favorite,
      'gradient': [Color(0xFFff9a9e), Color(0xFFfad0c4)],
    },
    {
      'label': 'Tired',
      'icon': Icons.bedtime,
      'gradient': [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
    },
    {
      'label': 'Thoughtful',
      'icon': Icons.psychology,
      'gradient': [Color(0xFF4A90E2), Color(0xFF357ABD)],
    },
    {
      'label': 'Curious',
      'icon': Icons.visibility,
      'gradient': [Color(0xFF2193b0), Color(0xFF6dd5ed)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildVerificationBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 32),
                      _buildMoodGrid(),
                      const SizedBox(height: 40),
                      _buildTimeSliderCard(),
                      const SizedBox(height: 32),
                      _buildRecommendButton(),
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
    final user = FirebaseAuth.instance.currentUser;
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
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
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
              await AuthService().resendVerificationEmail();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent!')),
                );
              }
            },
            child: const Text('Resend', style: TextStyle(fontSize: 13)),
          ),
          InkWell(
            onTap: () => setState(() => _bannerDismissed = true),
            child: const Icon(Icons.close, color: Colors.amber, size: 18),
          ),
        ],
      ),
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
                Icons.shuffle_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'How are you feeling?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Pick a mood to start',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        final mood = _moods[index];
        final isSelected = selectedMood == mood['label'];
        final gradientColors = (mood['gradient'] as List).cast<Color>();

        return GestureDetector(
          onTap: () => setState(() => selectedMood = mood['label'] as String),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
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
                            color: gradientColors.first.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  mood['icon'] as IconData,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mood['label'] as String,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
  }

  Widget _buildTimeSliderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.glassBorder,
              thumbColor: AppColors.textPrimary,
              overlayColor: AppColors.primary.withOpacity(0.2),
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
          const SizedBox(height: 4),
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

  Widget _buildRecommendButton() {
    return GradientButton(
      text: 'Recommend Movie',
      onPressed: selectedMood != null
          ? () => context.go(
              '/${RouteNames.recommendations}',
              extra: {'mood': selectedMood!, 'time': availableTime.toInt()},
            )
          : null,
      height: 60,
      borderRadius: 20,
    );
  }
}
