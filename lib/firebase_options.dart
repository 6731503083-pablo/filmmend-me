import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxyPlBN_0ZlW-p8bdTKu0gX-D9kO12RYI',
    appId: '1:316474289696:web:9fba6d048779f97517d645',
    messagingSenderId: '316474289696',
    projectId: 'filmmend-me',
    authDomain: 'filmmend-me.firebaseapp.com',
    storageBucket: 'filmmend-me.firebasestorage.app',
    measurementId: 'G-9QRF1E4RL1',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAk7WqHbcxpsFiYeivWrGlb_cUSCmwy1KM',
    appId: '1:316474289696:ios:0540e86cc2fc42cf17d645',
    messagingSenderId: '316474289696',
    projectId: 'filmmend-me',
    storageBucket: 'filmmend-me.firebasestorage.app',
    iosBundleId: 'com.example.filmmendMe',
  );

}