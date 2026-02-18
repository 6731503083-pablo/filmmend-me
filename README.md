# 🎬 FilmMend Me

A modern Flutter movie recommendation app featuring native iOS 26 UI components with liquid glass bottom navigation.

## ✨ Features

- **🎭 Mood-Based Recommendations**: Select your mood and get personalized movie suggestions
- **📱 Native iOS 26 Design**: Authentic iOS 26 liquid glass bottom navigation and adaptive UI components
- **🔐 Authentication Flow**: Login/Register screens with form validation
- **📚 Watchlist Management**: Save and manage your favorite movies
- **👤 User Profile**: View profile with stats and logout functionality
- **🎯 Movie Details**: Comprehensive movie information with streaming availability
- **🎲 Random Pick**: Surprise yourself with a random movie recommendation

## 🛠 Tech Stack

- **Framework**: Flutter 3.41.1 (Dart 3.11.0)
- **UI Components**: [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui) ^0.1.101
- **Navigation**: GoRouter with StatefulShellRoute for bottom navigation
- **State Management**: Riverpod (ready for implementation)
- **Backend**: Firebase (ready for integration)
- **Movie Data**: TMDB API (ready for integration)

## 📦 Key Dependencies

```yaml
adaptive_platform_ui: ^0.1.101  # Native iOS 26 components
go_router: ^14.6.2              # Declarative routing
flutter_riverpod: ^2.7.1        # State management
firebase_core: ^3.11.1          # Firebase integration
firebase_auth: ^5.4.1           # Authentication
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
git clone https://github.com/6731503083-pablo/filmmend-me.git
cd filmmend-me
```

2. Install dependencies:
```bash
flutter pub get
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
- Mock authentication system (ready for Firebase integration)
- Login required prompts on protected screens
- Maintains navigation context

## 🔮 Future Enhancements

- [ ] TMDB API integration for real movie data
- [ ] Firebase authentication implementation
- [ ] Firestore database for watchlist persistence
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

Pablo - [GitHub](https://github.com/6731503083-pablo)

## 🙏 Acknowledgments

- [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui) for native iOS 26 components
- [TMDB](https://www.themoviedb.org/) for movie data API
- Flutter team for the amazing framework

---

**Note**: This app showcases modern Flutter development with native iOS 26 UI components. The authentication and movie data are currently mocked for demonstration purposes and are ready for production API integration.
