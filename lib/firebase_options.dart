// © 2026 Imen BELHIBA — SANTEO Connect. Tous droits réservés.
// © 2026 Imen BELHIBA — SANTEO Connect. Tous droits réservés.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        // Fallback web pour les autres plateformes (Linux, macOS, Windows)
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD8wje7L9Y8jQ5gTWi5F9bk8S9bTy-l_p8',
    appId: '1:449105964214:web:3d5dc01a1713282459ca17',
    messagingSenderId: '449105964214',
    projectId: 'santeo-connect',
    storageBucket: 'santeo-connect.firebasestorage.app',
    authDomain: 'santeo-connect.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKQOWYKC0cOZX-NzwN29oLKWCdG4Fx8pI',
    appId: '1:449105964214:android:237c0920d97c325259ca17',
    messagingSenderId: '449105964214',
    projectId: 'santeo-connect',
    storageBucket: 'santeo-connect.firebasestorage.app',
  );

    static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQqh_sxOX06nrREkGJHWyKYmdsdW9ohgE',
    appId: '1:449105964214:ios:f1db981600fb4c7e59ca17',
    messagingSenderId: '449105964214',
    projectId: 'santeo-connect',
    storageBucket: 'santeo-connect.firebasestorage.app',
    iosBundleId: 'com.santeoconnect.app',
  );
}
