// firebase_options.dart — généré pour le projet santeo-connect
// Android : com.santeoconnect.app
// Web     : clé API extraite de google-services.json
// ⚠️  Ne jamais commiter ce fichier avec de vraies clés en production

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

  // ── Configuration WEB ─────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4A-4w7RoBXRZAMP3JeljQuVUN7MT19Ms',
    appId: '1:449105964214:web:3d5dc01a1713282459ca17',
    messagingSenderId: '449105964214',
    projectId: 'santeo-connect',
    storageBucket: 'santeo-connect.firebasestorage.app',
    authDomain: 'santeo-connect.firebaseapp.com',
  );

  // ── Configuration ANDROID ─────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKQOWYKC0cOZX-NzwN29oLKWCdG4Fx8pI',
    appId: '1:449105964214:android:237c0920d97c325259ca17',
    messagingSenderId: '449105964214',
    projectId: 'santeo-connect',
    storageBucket: 'santeo-connect.firebasestorage.app',
  );

  // ── Configuration iOS ─────────────────────────────────────────────────────
  // GoogleService-Info.plist — SANTEO CONNECT iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQqh_sxOX06nrREkGJHWyKYmdsdW9ohgE',
    appId: '1:449105964214:ios:f1db981600fb4c7e59ca17',
    messagingSenderId: '449105964214',
    projectId: 'santeo-connect',
    storageBucket: 'santeo-connect.firebasestorage.app',
    iosBundleId: 'com.santeoconnect.app',
  );
}
