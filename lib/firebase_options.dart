// File generated manually for Firebase configuration
// TODO: Replace with your Firebase project configuration from Firebase Console

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Ganti dengan konfigurasi dari Firebase Console
  // Buka: https://console.firebase.google.com/

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCrJAAUZAPettM5AwPbV3rAGlT4Jx922m8',
    appId: '1:217854138058:android:b8bd92665b1766ad0c4633',
    messagingSenderId: '217854138058',
    projectId: 'project-ta-951b4',
    storageBucket: 'project-ta-951b4.firebasestorage.app',
  );

  // Pilih project Anda > Project Settings > Your apps > Android app

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIQXk616hEbKodZuktee38OFW042eXs1M',
    appId: '1:217854138058:ios:aeee768efda8c5d80c4633',
    messagingSenderId: '217854138058',
    projectId: 'project-ta-951b4',
    storageBucket: 'project-ta-951b4.firebasestorage.app',
    iosBundleId: 'com.kampus.apsgo',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQWvoDxDyVCuLEDiwammjUIVYxVARzJig',
    appId: '1:217854138058:web:50a5bcd5a61ac1820c4633',
    messagingSenderId: '217854138058',
    projectId: 'project-ta-951b4',
    authDomain: 'project-ta-951b4.firebaseapp.com',
    storageBucket: 'project-ta-951b4.firebasestorage.app',
    measurementId: 'G-6ML8QQEGNZ',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBIQXk616hEbKodZuktee38OFW042eXs1M',
    appId: '1:217854138058:ios:d9fb00752ef371fe0c4633',
    messagingSenderId: '217854138058',
    projectId: 'project-ta-951b4',
    storageBucket: 'project-ta-951b4.firebasestorage.app',
    iosBundleId: 'com.example.projectTa',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQWvoDxDyVCuLEDiwammjUIVYxVARzJig',
    appId: '1:217854138058:web:233d93e01272a0870c4633',
    messagingSenderId: '217854138058',
    projectId: 'project-ta-951b4',
    authDomain: 'project-ta-951b4.firebaseapp.com',
    storageBucket: 'project-ta-951b4.firebasestorage.app',
    measurementId: 'G-SB8J6ZZQHZ',
  );

}