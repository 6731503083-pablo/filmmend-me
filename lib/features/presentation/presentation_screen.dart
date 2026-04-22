import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({Key? key}) : super(key: key);

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to app
      context.go(RouteNames.home);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // Fallback if somehow accessed on mobile, though routing should usually prefer normal app flow.
      return const Scaffold(
        body: Center(child: Text("Presentation only available on Web")),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _slides[index];
            },
          ),

          // Navigation Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _prevPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.white24,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? "Enter App" : "Next",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Page Indicators
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<Widget> _slides = [
    // Slide 1: Title
    const _SlideContent(
      title: "Filmmend Me",
      subtitle: "Stop Scrolling. Start Watching.",
      description:
          "An AI-powered movie recommendation platform designed to find the perfect film for your exact mood and available time.",
      icon: Icons.movie_creation_outlined,
    ),

    // Slide 2: Problem Statement
    const _SlideContent(
      title: "The Problem",
      subtitle: "Choice Paralysis",
      description:
          "We spend more time looking for movies than actually watching them. With thousands of titles across multiple streaming platforms, users face overwhelming decision fatigue, leading to frustration and wasted free time.",
      icon: Icons.access_time_filled,
      color: Colors.redAccent,
    ),

    // Slide 3: The Solution
    const _SlideContent(
      title: "The Solution",
      subtitle: "Intent-Based Curation",
      description:
          "Filmmend Me bypasses generic categories. Tell us exactly how you feel (e.g., 'Happy', 'Nostalgic', 'Need a thrill') and how much time you have. Our app instantly curates a personalized list that fits your life perfectly.",
      icon: Icons.lightbulb_outline,
      color: Colors.blueAccent,
    ),

    // Slide 4: Key Features (Selling Points)
    const _SlideFeatureList(
      title: "Key Selling Points",
      features: [
        "AI-Powered Matching matching human emotion to film genres.",
        "Time-Scoped Filtering so you never start a movie you can't finish.",
        "One-Tap Trailer Playback to quickly vet recommendations.",
        "Seamless Watchlist Management synced across devices via Firebase.",
        "Native Device Sharing to easily recommend films to friends.",
      ],
      icon: Icons.star_border,
      color: Colors.amber,
    ),
  ];
}

class _SlideContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color? color;

  const _SlideContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color ?? Theme.of(context).primaryColor),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color ?? Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              description,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                height: 1.5,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideFeatureList extends StatelessWidget {
  final String title;
  final List<String> features;
  final IconData icon;
  final Color color;

  const _SlideFeatureList({
    required this.title,
    required this.features,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 30),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((feature) => _buildFeatureItem(context, feature))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                height: 1.4,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
