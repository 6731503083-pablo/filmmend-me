import 'dart:async';

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

/// Auth stream that emits [safeCurrentUser] immediately on subscribe, then
/// follows Firebase user changes. Avoids a one-frame "logged out" flicker in
/// [StreamBuilder]s while waiting for the first `userChanges()` event.
Stream<User?> safeAuthStateChanges() {
  if (!isFirebaseReady) return Stream<User?>.value(null);
  try {
    final initial = safeCurrentUser();
    return Stream.multi((controller) {
      controller.add(initial);
      final sub = FirebaseAuth.instance.userChanges().listen(
        controller.add,
        onError: controller.addError,
        cancelOnError: false,
      );
      controller.onCancel = sub.cancel;
    });
  } catch (_) {
    return Stream<User?>.value(null);
  }
}
