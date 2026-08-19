# 🎬 FilmMend Me

A modern Flutter movie recommendation app featuring native iOS 26 UI components with liquid glass bottom navigation.

## ⚠️ Release Handover (New Mac)

If you are moving development to a new laptop, read this first:

- [HANDOVER_NEW_MAC.md](HANDOVER_NEW_MAC.md)

## ✨ Features

- **🎭 Mood-Based Recommendations**: Select your mood and get personalized movie suggestions
- **🧠 Explainable Recommendations**: Recommended items include short “why this was picked” context
- **📱 Native iOS 26 Design**: Authentic iOS 26 liquid glass bottom navigation and adaptive UI components
- **🔐 Authentication Flow**: Login/Register screens with form validation
- **📚 Watchlist Management**: Save and manage your favorite movies
- **👤 User Profile**: View profile with stats and logout functionality
- **🎯 Movie Details**: Comprehensive movie information with streaming availability
- **🎲 Random Pick**: Surprise yourself with a random movie recommendation

## 🛠 Tech Stack

- **Framework**: Flutter (Dart >= 3.9.2)
- **UI Components**: [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui) ^0.1.6
- **Navigation**: GoRouter with StatefulShellRoute for bottom navigation
- **Backend**: Firebase (Auth + Firestore)
- **Movie Data**: TMDB API

## 📦 Key Dependencies

```yaml
adaptive_platform_ui: ^0.1.6 # Native iOS 26 components
go_router: ^14.6.2 # Declarative routing
firebase_core: ^4.4.0 # Firebase integration
firebase_auth: ^6.1.4 # Authentication
cloud_firestore: ^6.1.2 # Firestore data
```

## 🎨 Adaptive UI Components Used

- `AdaptiveBottomNavigationBar` - iOS 26 liquid glass navigation
- `AdaptiveButton` - Platform-specific buttons (filled, bordered, plain)
- `AdaptiveTextField` - Native text input fields
- `AdaptiveCard` - Adaptive card containers
- `AdaptiveSlider` - Mood intensity slider

## 📱 Screenshots

The app features a beautiful dark theme with iOS 26 native components, including:

- Liquid glass bottom navigation bar
- Native iOS button styles
- Smooth animations and transitions
- Responsive layouts

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.41.1 or higher
- Dart SDK 3.11.0 or higher
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/phyowaiyanlinzaw/filmmend-me.git
cd filmmend-me
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure TMDB token (required for recommendations):

```bash
flutter run --dart-define=TMDB_READ_TOKEN=YOUR_TOKEN
```

For local development, you can also create a `.env` file (not bundled in release builds):

```
TMDB_READ_TOKEN=YOUR_TOKEN
```

3. Run the app:

```bash
flutter run
```

For iOS Simulator:

```bash
flutter run -d ios
```

For Android Emulator:

```bash
flutter run -d android
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and configurations
│   ├── router/         # GoRouter configuration and routes
│   ├── theme/          # App theme and styling
│   ├── utils/          # Utility functions and helpers
│   └── widgets/        # Reusable widgets
├── features/
│   ├── auth/           # Authentication (login/register)
│   ├── home/           # Home screen with mood selection
│   ├── movie_detail/   # Movie details screen
│   ├── profile/        # User profile
│   ├── recommendations/# Movie recommendations
│   ├── splash/         # Splash screen
│   └── watchlist/      # Watchlist management
├── models/             # Data models
├── services/           # API services (TMDB, Auth, etc.)
├── app.dart            # Root app widget
└── main.dart           # App entry point
```

## 🎯 Key Features Implementation

### Native iOS 26 Bottom Navigation

- Uses `AdaptiveBottomNavigationBar` with `useNativeBottomBar: true`
- Liquid glass effect on iOS 26+
- Falls back to standard navigation on older versions

### Routing Architecture

- Declarative routing with GoRouter
- StatefulShellRoute for persistent bottom navigation
- Protected routes with inline login prompts
- Parent navigator keys for full-screen navigation

### Authentication State

- Firebase Authentication + Firestore profile/watchlist integration
- Login required prompts on protected screens
- Email verification gates for watchlist/profile protected flows
- Maintains navigation context

### Recommendation Configuration (Backend-Configurable)

Mood-to-genre rules can be configured from Firestore:

- Document path: `app_config/recommendation_rules`
- Field: `moodGenres` (map of mood -> list of TMDB genre IDs)

Example:

```json
{
  "moodGenres": {
    "Chill": [10749, 35, 16, 10751],
    "Excited": [28, 12, 878, 53]
  }
}
```

If this config is missing or unavailable, the app safely uses built-in defaults.

## 🔮 Future Enhancements

- [ ] Movie search functionality
- [ ] User reviews and ratings
- [ ] Social features (share recommendations)
- [ ] Dark/Light theme toggle
- [ ] Localization support
- [ ] Offline caching
- [ ] Push notifications for new releases

## 🧪 Running Tests

```bash
flutter test
```

## 📱 Platform Support

- ✅ iOS (Native iOS 26 components)
- ✅ Android (Material Design)
- ⚠️ Web (Limited adaptive features)
- ⚠️ macOS (Basic support)
- ⚠️ Linux (Basic support)
- ⚠️ Windows (Basic support)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

Pablo - [GitHub](https://github.com/phyowaiyanlinzaw)

## 🙏 Acknowledgments

- [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui) for native iOS 26 components
- [TMDB](https://www.themoviedb.org/) for movie data API
- Flutter team for the amazing framework

---

**Note**: This app showcases modern Flutter development with native iOS 26 UI components. The authentication and movie data are currently mocked for demonstration purposes and are ready for production API integration.
