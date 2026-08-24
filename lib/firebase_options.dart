// File generated for Firebase setup.
// ignore_for_file: type=lint
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD96OOhvx_A4dp8x8YO4Ed1LQDqr8B47ko',
    appId: '1:516009650694:web:fd9332e63c3b772be67187',
    messagingSenderId: '516009650694',
    projectId: 'country-meat-f281c',
    authDomain: 'country-meat-f281c.firebaseapp.com',
    storageBucket: 'country-meat-f281c.firebasestorage.app',
    measurementId: 'G-9K6GKJFB1Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw9C3sjilNhYaMkNvkXGVSGC7tavVZI6E',
    appId: '1:516009650694:android:ec9ddc81fea6a742e67187',
    messagingSenderId: '516009650694',
    projectId: 'country-meat-f281c',
    storageBucket: 'country-meat-f281c.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAB_KttlzlGL5THaJt6duqIEo4rPrYJ6yw',
    appId: '1:516009650694:ios:6d96a74b77473edce67187',
    messagingSenderId: '516009650694',
    projectId: 'country-meat-f281c',
    storageBucket: 'country-meat-f281c.firebasestorage.app',
    iosBundleId: 'com.example.countryMeatApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAB_KttlzlGL5THaJt6duqIEo4rPrYJ6yw',
    appId: '1:516009650694:ios:6d96a74b77473edce67187',
    messagingSenderId: '516009650694',
    projectId: 'country-meat-f281c',
    storageBucket: 'country-meat-f281c.firebasestorage.app',
    iosBundleId: 'com.example.countryMeatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD96OOhvx_A4dp8x8YO4Ed1LQDqr8B47ko',
    appId: '1:516009650694:web:0e4baaade526e8cae67187',
    messagingSenderId: '516009650694',
    projectId: 'country-meat-f281c',
    authDomain: 'country-meat-f281c.firebaseapp.com',
    storageBucket: 'country-meat-f281c.firebasestorage.app',
    measurementId: 'G-KVRVNDP0S0',
  );
}
