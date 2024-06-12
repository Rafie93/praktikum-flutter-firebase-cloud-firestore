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

      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkLnGU_zd_L_JoXvYPhRIqHhOaAJ_NIVk',
    authDomain: 'tugas2-a8340.firebaseapp.com',
    databaseURL:
        'https://tugas2-a8340-default-rtdb.asia-southeast1.firebasedatabase.app',
    appId: '1:713883959807:web:52ef505c70bc9888ed27ca',
    messagingSenderId: '713883959807',
    projectId: 'tugas2-a8340',
    storageBucket: 'tugas2-a8340.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkLnGU_zd_L_JoXvYPhRIqHhOaAJ_NIVk',
    authDomain: 'tugas2-a8340.firebaseapp.com',
    databaseURL:
        'https://tugas2-a8340-default-rtdb.asia-southeast1.firebasedatabase.app',
    appId: '1:713883959807:web:52ef505c70bc9888ed27ca',
    messagingSenderId: '713883959807',
    projectId: 'tugas2-a8340',
    storageBucket: 'tugas2-a8340.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkLnGU_zd_L_JoXvYPhRIqHhOaAJ_NIVk',
    authDomain: 'tugas2-a8340.firebaseapp.com',
    databaseURL:
        'https://tugas2-a8340-default-rtdb.asia-southeast1.firebasedatabase.app',
    appId: '1:713883959807:web:52ef505c70bc9888ed27ca',
    messagingSenderId: '713883959807',
    projectId: 'tugas2-a8340',
    storageBucket: 'tugas2-a8340.appspot.com',
  );
}
