import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedMood;
  double availableTime = 90;

  final List<Map<String, dynamic>> moods = [
    {'label': 'Chill', 'icon': Icons.air},
    {'label': 'Happy', 'icon': Icons.sentiment_satisfied_alt},
    {'label': 'Sad', 'icon': Icons.sentiment_dissatisfied},
    {'label': 'Excited', 'icon': Icons.celebration},
    {'label': 'Romantic', 'icon': Icons.favorite},
    {'label': 'Tired', 'icon': Icons.bedtime},
    {'label': 'Thoughtful', 'icon': Icons.psychology},
    {'label': 'Curious', 'icon': Icons.visibility},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Filmmend Me',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.movie, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pick a mood to start',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Mood Grid (4 columns x 2 rows = 8 moods)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: moods.length,
              itemBuilder: (context, index) {
                final mood = moods[index];
                final isSelected = selectedMood == mood['label'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood['label'];
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF252A3D),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          mood['icon'],
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          mood['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Time Slider Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${availableTime.toInt()} min',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AdaptiveSlider(
              value: availableTime,
              min: 0,
              max: 180,
              onChanged: (value) {
                setState(() {
                  availableTime = value;
                });
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0m',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  '90m',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  '180m',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Recommend Movie Button
            SizedBox(
              width: double.infinity,
              child: AdaptiveButton(
                onPressed: selectedMood != null
                    ? () {
                        context.go(
                          '${RouteNames.home}/${RouteNames.recommendations}',
                        );
                      }
                    : null,
                label: 'Recommend Movie',
                style: AdaptiveButtonStyle.filled,
              ),
            ),

            const SizedBox(height: 12),

            // Random Pick Button (bonus feature)
            SizedBox(
              width: double.infinity,
              child: AdaptiveButton(
                onPressed: () {
                  context.go(
                    '${RouteNames.home}/${RouteNames.recommendations}',
                  );
                },
                label: 'Random Pick',
                style: AdaptiveButtonStyle.bordered,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
