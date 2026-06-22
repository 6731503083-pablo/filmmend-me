/// Google Sign-In OAuth web client ID from Firebase Console:
/// Project settings → Your apps → Web app → Web client ID.
///
/// Pass at build/run time when needed (iOS/Web):
/// `--dart-define=GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com`
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static const String verificationEmailSender =
      'noreply@filmmend-me.firebaseapp.com';
}
