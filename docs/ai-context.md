# FilmMend Me — Architecture Summary

**FilmMend Me** is a cross-platform **Flutter** app for mood-based movie recommendations, watchlists, and user profiles. It uses a **feature-oriented layout** with a thin **service layer**, but not full clean architecture (no repositories, no DI, no global state library).

**Maintaining this doc:** After implementing fixes, agents update this file to match the codebase and commit alongside code changes. See `.cursor/rules/project.mdc` → *After implementing fixes*.

---

## High-Level Overview

```mermaid
flowchart TB
    subgraph client [Flutter App]
        UI[Feature Screens]
        Core[Core: Router / Theme / Widgets]
        Services[Services Layer]
        Models[Models]
    end

    subgraph external [External Systems]
        TMDB[TMDB API]
        FBAuth[Firebase Auth]
        FS[Cloud Firestore]
    end

    UI --> Core
    UI --> Services
    Services --> Models
    Services --> TMDB
    Services --> FBAuth
    Services --> FS
```

| Layer | Role |
|--------|------|
| **Presentation** | Screens per feature (`features/*/presentation/`) |
| **Services** | Firebase + TMDB access (`lib/services/`) |
| **Models** | `MovieModel`, `UserModel` |
| **Core** | Routing, theme, shared widgets, Firebase guards |

---

## App Bootstrap & Entry

1. **`main.dart`** — Loads optional `.env` (TMDB token), sets a global error widget, runs the app.
2. **`app.dart`** — Initializes Firebase (with a ~600ms minimum splash so the animation can play), configures Crashlytics, then mounts `MaterialApp.router` with `appRouter`.
3. **`firebase_options.dart`** — Platform Firebase config (injected in CI for web deploy).
4. **`core/firebase/crashlytics_bootstrap.dart`** — After Firebase init: `FlutterError.onError` and `PlatformDispatcher.onError` → Firebase Crashlytics (collection disabled in debug).

Startup is defensive: Firebase init can time out or fail, with retry UI instead of a hard crash.

---

## Navigation Architecture

**GoRouter** with a **3-tab shell**:

```
/ (home)          → Home tab (public)
/watchlist        → Watchlist tab (auth-gated in UI)
/profile          → Profile tab (auth-gated in UI)
/login, /register, /verify-email, /splash  → Outside shell
/movie/:id        → Full-screen detail (root navigator)
/home/recommendations → Results (pushed from home)
```

- **`StatefulShellRoute.indexedStack`** keeps tab state alive.
- **`AppShell`** wraps tabs with:
  - iOS: native liquid-glass `AdaptiveBottomNavigationBar`
  - Web/Android: custom Material nav bar
- **Protected routes are not router redirects** — watchlist/profile screens use `StreamBuilder` + `LoginRequiredView` / `VerificationRequiredView` inline.

---

## State Management Pattern

**No Provider / Riverpod / Bloc.** Pattern is:

- `StatefulWidget` for local UI state (mood selection, form fields, loading flags)
- `StreamBuilder` for Firebase auth and Firestore watchlist streams
- Services instantiated directly in widgets (`TmdbService()`, `AuthService()`, `WatchlistService()`)

This keeps the codebase small but couples screens to services.

---

## Feature Modules

| Feature | Responsibility |
|---------|----------------|
| **splash** | Branded splash (mostly superseded by bootstrap in `app.dart`) |
| **home** | Mood picker, runtime slider, navigates to recommendations |
| **recommendations** | Displays ranked TMDB results with “why picked” text |
| **movie_detail** | Full movie info, trailer links, watchlist toggle |
| **auth** | Login, register, Google Sign-In, email verification |
| **watchlist** | Real-time Firestore watchlist |
| **profile** | User info, stats, logout, account deletion |

Each feature is **presentation-only** — no `domain/` or `data/` subfolders.

---

## Services Layer

### `AuthService`
- Firebase Auth (email/password + **Google Sign-In**)
- Firestore user docs at `users/{uid}` (created on register or first Google sign-in)
- Email verification, password reset, account deletion (including watchlist cleanup)
- Google accounts are treated as verified (`emailVerified == true`) — no verification email

### `WatchlistService`
- Subcollection: `users/{uid}/watchlist/{movieId}`
- Real-time streams for list and per-movie status

### `TmdbService` (largest service)
- TMDB HTTP client with in-memory caching, deduped in-flight requests, retries
- **Recommendation engine**: mood → genre IDs → discover API → scoring/ranking → explainable reasons
- Mood→genre rules from Firestore `app_config/recommendation_rules` with hardcoded fallbacks
- Token from: CI placeholder replacement, `--dart-define`, or `.env`

---

## Data Models

- **`MovieModel`** — TMDB JSON parsing (list + detail), images, cast/crew, trailers, recommendation reason
- **`UserModel`** — Firestore user profile

Models live in `lib/models/` and are used by both services and UI.

---

## Authentication & Authorization

```
Firebase Auth (identity)
       ↓
safeCurrentUser() / safeAuthStateChanges()  ← guards if Firebase not ready
       ↓
Screen-level checks:
  - Not logged in → LoginRequiredView
  - Logged in, email unverified → VerificationRequiredView (watchlist actions)
  - Google Sign-In → skips verification email flow
```

`firebase_safe.dart` wraps Firebase calls so uninitialized Firebase does not crash the app. `safeAuthStateChanges()` emits `safeCurrentUser()` synchronously on subscribe before listening to `userChanges()`, so auth-gated tabs do not flash `LoginRequiredView` while the stream warms up.

### Google Sign-In (free, no custom domain)

Login and register screens offer **Continue with Google** (`google_sign_in` + `AuthService.signInWithGoogle()`). Web uses `signInWithPopup`; mobile uses the Google account picker.

**Firebase Console setup (one-time):**
1. **Authentication → Sign-in method → Google** → Enable
2. **Android:** add debug + release SHA-1/SHA-256 fingerprints (Project settings → Your apps → Android)
3. **iOS:** add `CFBundleURLTypes` URL scheme from `REVERSED_CLIENT_ID` in `GoogleService-Info.plist`
4. **iOS/Web client ID:** pass Web OAuth client ID at run/build when needed:
   `--dart-define=GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com`
   (from Project settings → Web app → Web client ID; stored in `GoogleAuthConfig`)

### Email verification UX (email/password only)

Verification emails come from `noreply@filmmend-me.firebaseapp.com` and may land in spam without a custom domain. The verify screen and `VerificationRequiredView` show sender address + spam/promotions steps via `EmailVerificationTips`.

---

## Theming & Shared UI

**`core/theme/`** — Dark theme, colors, text styles, constants.

**`core/widgets/`** — Reusable pieces:
- `MovieCard`, `GradientBackground`, `GradientButton`
- `LoginRequiredView`, `VerificationRequiredView`, `EmailVerificationTips`
- `GoogleSignInButton`, `AuthDivider` on login/register
- Platform-adaptive inputs via `adaptive_platform_ui` on auth/home flows

---

## External Dependencies & Config

| System | Usage |
|--------|--------|
| **TMDB API** | Movie discovery, search, details |
| **Firebase Auth** | Users (email/password + Google Sign-In via `google_sign_in`) |
| **Cloud Firestore** | Profiles, watchlists, remote recommendation config |
| **Firebase Hosting** | Web build deploy (GitHub Actions on `main`) |
| **Firebase Crashlytics** | Production crash reports (Android/iOS; off in debug builds) |

Firestore schema (conceptual):

```
users/{uid}
  ├── displayName, email, createdAt, photoUrl
  └── watchlist/{movieId}
        └── title, posterPath, rating, genres, addedAt, ...

app_config/recommendation_rules
  └── moodGenres: { "Chill": [10749, 35, ...], ... }
```

---

## Deployment & Secrets

- **Web**: CI builds Flutter web, injects `firebase_options.dart` and TMDB token via `sed` into `tmdb_service.dart`
- **Android release**: `.env` is not bundled in release builds. Pass the TMDB token at build time:
  ```bash
  flutter build appbundle --release --dart-define=TMDB_READ_TOKEN=...
  ```
  Emulator/device testing: `flutter run -d android --dart-define=TMDB_READ_TOKEN=...` or use `.env` in debug only.
- **iOS / Android Firebase**: `google-services.json` / `GoogleService-Info.plist` (gitignored; copy from Firebase console or old machine). See `HANDOVER_NEW_MAC.md` for Play signing and version-code rules.
- **Local dev**: `.env` with `TMDB_READ_TOKEN` or `--dart-define=TMDB_READ_TOKEN=...`

### Cursor / VS Code (Android Gradle)

On macOS, Cursor’s Java extension may show **“The supplied phased action failed with an exception”** on `android/build.gradle.kts` when no JDK is registered with the OS. The Gradle files are fine; the IDE cannot sync without a JDK path.

**Workspace fix** (`.vscode/settings.json`): point the Java language server and Gradle import at Android Studio’s bundled JBR:

```json
"java.jdt.ls.java.home": "/Applications/Android Studio.app/Contents/jbr/Contents/Home",
"java.import.gradle.java.home": "/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

After changing JDK settings: **Command Palette → Java: Clean Java Language Server Workspace → Reload**.

Terminal Gradle (independent of IDE): `export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` then `cd android && ./gradlew projects`.

---

## Architectural Characteristics

**Strengths**
- Clear feature folders and a single router entry point
- Rich recommendation logic centralized in `TmdbService`
- Real Firebase integration (not mocked in code)
- Platform-aware UI (iOS 26 native nav vs Material fallback)
- Resilient startup and API error handling
- Firebase Crashlytics for release crash reporting

**Trade-offs / gaps**
- No formal state management or dependency injection
- No repository abstraction — screens call services directly
- Auth gating is UI-level, not router-level (tabs stay reachable when logged out)
- No offline persistence beyond in-memory TMDB cache
- No Android CI (web-only GitHub Actions deploy)
- README still mentions “mocked” auth in places; the implementation is production Firebase

---

## Mental Model

Think of it as a **Flutter UI shell** over **two backends**:

1. **TMDB** — read-only movie data and recommendation logic (mostly client-side)
2. **Firebase** — identity, user data, watchlists, and remotely tunable mood rules

The app is optimized for **native iOS polish** and a **simple, direct codebase** rather than a layered enterprise architecture.

---

## Emulator Testing (Pre–Play Store)

### Run commands

**Debug** (uses bundled `.env` for TMDB when present):

```bash
flutter run -d android
```

**Release APK on emulator** (matches Play minification; TMDB requires token at build time):

```bash
flutter build apk --release --dart-define=TMDB_READ_TOKEN=YOUR_TOKEN
adb uninstall com.filmmend.me   # required when switching debug ↔ release signing
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Play upload artifact:**

```bash
flutter build appbundle --release --dart-define=TMDB_READ_TOKEN=YOUR_TOKEN
```

### Manual test checklist

| Area | Steps | Pass criteria |
|------|--------|----------------|
| **Startup** | Cold launch | Splash → home; no crash |
| **Home** | Pick mood + runtime → Get recommendations | Results load with posters and “why picked” text |
| **Movie detail** | Tap a card | Detail, cast, trailer link open |
| **Auth** | Register → verify email flow | Verification screen blocks back; resend works |
| **Watchlist** | Logged out → tab | `LoginRequiredView`; after login + verify, add/remove movie |
| **Profile** | Logout, delete account (test account) | Navigates correctly; `requires-recent-login` signs out to login |
| **Back** | System back on tabs / detail | Predictive back behaves; no stuck routes |
| **Release build** | Install release APK | App opens; recommendations work (token was passed at build) |

### Known emulator pitfalls

- **WiFi after wipe** — DNS fails until WiFi connects (~30–60s after cold boot). `ping google.com` from adb is a quick check; enable WiFi or wait before testing API flows.
- **No DNS / offline Firestore** — if WiFi never connects, logs show `Unable to resolve host`; use **Cold Boot Now** or recreate the AVD.
- **Debug vs release signing** — `INSTALL_FAILED_UPDATE_INCOMPATIBLE` → `adb uninstall com.filmmend.me` first.
- **`.env`** — listed in `pubspec.yaml` assets for debug; release/Android store builds still need `--dart-define=TMDB_READ_TOKEN=...`.
- **Lag on low-RAM Macs** — 8 GB total RAM forces software GPU rendering; use `flutter run --release -d android` for smoother emulator runs, or prefer a lighter AVD (below).

### Recommended AVD (no physical device)

On memory-tight Macs (e.g. 8 GB), avoid **API 37 + 16 KB (ps16k)** images — they are heavy. Prefer:

| Setting | Value |
|---------|--------|
| Device | Pixel 6 (or similar) |
| System image | **API 34 or 35**, Google Play — **not** “16 KB Page Size” |
| AVD RAM | **2048 MB** (not 4096+ on 8 GB hosts) |

Create via **Android Studio → Device Manager → Create Device**. No phone required for dev; use Play **Internal testing** for a final install check on any borrowed Android device before production.

---

## Play Store Readiness

A full readiness audit was completed on 2026-06-22. The app is **upload-ready** for Android Play Store.

### What was fixed

| # | File | Change |
|---|------|--------|
| 1 | `pubspec.yaml` | Updated `description` from Flutter template default to a real description |
| 2 | `android/app/build.gradle.kts` | Removed stale `TODO` comment about application ID |
| 3 | `lib/features/profile/presentation/profile_screen.dart` | `requires-recent-login` error now signs the user out and navigates to `/login` instead of showing a dead-end snackbar |
| 4 | `android/app/build.gradle.kts` | Enabled R8 minification (`isMinifyEnabled`, `isShrinkResources`) for release builds |
| 5 | `android/app/proguard-rules.pro` | New file — keep rules for Flutter, Firebase, Crashlytics, Kotlin; `SourceFile,LineNumberTable` preserved for readable Crashlytics stack traces |

### Remaining known gaps (not blockers)

- README still says auth is "mocked" — it is real Firebase; README needs a one-line correction
- No Android CI pipeline (web-only GitHub Actions)
- Auth gating is UI-level, not router-level

---

## Recent Dev Environment Fix (2026-06-22)

| File | Change |
|------|--------|
| `.vscode/settings.json` | JDK paths for Java/Gradle extension (Android Studio JBR); automatic Gradle build configuration |
| `docs/ai-context.md` | Documented Cursor Gradle sync / JDK setup (this section) |

No changes to `android/build.gradle.kts` — root Gradle script is standard Flutter boilerplate; red IDE errors were JDK configuration only.

---

## Pre–Play Store Emulator Pass (2026-06-22)

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `.env` to Flutter assets so `dotenv.load` works in debug/emulator runs |
| `lib/features/auth/presentation/verify_email_screen.dart` | Replaced deprecated `WillPopScope` with `PopScope(canPop: false)` for Android predictive back |
| `docs/ai-context.md` | Emulator test commands, checklist, and pitfalls (section above) |

**Automated checks:** `flutter analyze` clean; debug APK installed on emulator (API 37); `flutter build apk --release` succeeds with R8 minification. Manual UI pass pending on a lighter AVD (user creating API 34/35 emulator).

---

## Emulator Test Pass (2026-06-22)

App run on Pixel 6a (API 34) emulator via `flutter run`. No Flutter exceptions found.

| # | Finding | Severity | Resolution |
|---|---------|----------|------------|
| 1 | `RecommendationResultsScreen.maxMinutes` was misnamed — field and constructor param were called `maxMinutes` but represent a **minimum** runtime filter (used as `with_runtime.gte` in TMDB, labelled "Minimum Duration" in UI) | Bug | **Fixed** — renamed to `minMinutes` in `recommendation_results_screen.dart` and `router.dart` |
| 2 | Firestore `PERMISSION_DENIED` on `app_config/recommendation_rules` | Infrastructure | Local `firestore.rules` is correct (`allow read: if true`) but rules haven't been deployed to Firebase. App falls back to hardcoded `fallbackMoodGenres` — no user-facing crash. Fix: run `firebase deploy --only firestore:rules` |

**Emulator noise (not real bugs):** `GoogleApiManager` / `FlagRegistrar` / `FlagStore` errors are emulator-internal GMS service issues. Frame skipping is expected with software rendering on low RAM.

---

## Pending Feature Work

From the roadmap in `README.md`, none of these are started:

- [ ] Movie search
- [ ] User reviews and ratings
- [ ] Social sharing of recommendations
- [ ] Dark / Light theme toggle
- [ ] Localization
- [ ] Offline caching (beyond in-memory TMDB cache)
- [ ] Push notifications for new releases

---

## Google Sign-In + verification UX (2026-06-22)

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `google_sign_in` |
| `lib/services/auth_service.dart` | `signInWithGoogle()`, Firestore user bootstrap for new Google users |
| `lib/core/firebase/google_auth_config.dart` | Web client ID (`GOOGLE_WEB_CLIENT_ID`), verification sender constant |
| `lib/core/widgets/google_sign_in_button.dart` | `GoogleSignInButton`, `AuthDivider` |
| `lib/core/widgets/email_verification_tips.dart` | Spam/promotions guidance + sender address |
| `lib/features/auth/presentation/login_screen.dart` | Google sign-in button |
| `lib/features/auth/presentation/register_screen.dart` | Google sign-in (no verification email) |
| `lib/features/auth/presentation/verify_email_screen.dart` | Prominent spam-folder tips |
| `lib/core/widgets/verification_required_view.dart` | Same tips on gated screens |
