// Firebase configuration for Flutter web
// This file should contain your actual Firebase project configuration

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiS2ueOHdukdK-0kZe2TAInYRvDxvwgKg',
    appId: '1:1095504222814:web:686f096c2e731a5aa6b2cf',
    messagingSenderId: '1095504222814',
    projectId: 'fir-b5615',
    authDomain: 'fir-b5615.firebaseapp.com',
    storageBucket: 'fir-b5615.firebasestorage.app',
  );
}
