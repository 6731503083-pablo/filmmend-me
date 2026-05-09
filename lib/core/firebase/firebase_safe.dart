import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

bool get isFirebaseReady {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (_) {
    return false;
  }
}

User? safeCurrentUser() {
  if (!isFirebaseReady) return null;
  try {
    return FirebaseAuth.instance.currentUser;
  } catch (_) {
    return null;
  }
}

Stream<User?> safeAuthStateChanges() {
  if (!isFirebaseReady) return Stream<User?>.value(null);
  try {
    return FirebaseAuth.instance.userChanges();
  } catch (_) {
    return Stream<User?>.value(null);
  }
}
