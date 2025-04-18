// File generated by FlutterFire CLI.
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
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_nqsYrRzmikF33zIsd4zA_zz2nw4wEb8',
    appId: '1:857676139805:web:42b0b14dbd8dca775e65f4',
    messagingSenderId: '857676139805',
    projectId: 'tofu-bot-7de67',
    authDomain: 'tofu-bot-7de67.firebaseapp.com',
    storageBucket: 'tofu-bot-7de67.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmb9E6LXrfwBDdHg57GLyE-0bOVMdKoX0',
    appId: '1:857676139805:android:49cdf20466ff56995e65f4',
    messagingSenderId: '857676139805',
    projectId: 'tofu-bot-7de67',
    storageBucket: 'tofu-bot-7de67.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtrJS3-Ckx-TtQnPc4PZxqqzaI9HZsm3w',
    appId: '1:857676139805:ios:95444d8b411d598b5e65f4',
    messagingSenderId: '857676139805',
    projectId: 'tofu-bot-7de67',
    storageBucket: 'tofu-bot-7de67.firebasestorage.app',
    androidClientId: '857676139805-72g7u6r0trl09vqq1818c8ue4il90ebn.apps.googleusercontent.com',
    iosClientId: '857676139805-ogtp0ussv98s6tn4satgit2mdt19odt1.apps.googleusercontent.com',
    iosBundleId: 'com.example.tofuBot',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBtrJS3-Ckx-TtQnPc4PZxqqzaI9HZsm3w',
    appId: '1:857676139805:ios:95444d8b411d598b5e65f4',
    messagingSenderId: '857676139805',
    projectId: 'tofu-bot-7de67',
    storageBucket: 'tofu-bot-7de67.firebasestorage.app',
    androidClientId: '857676139805-72g7u6r0trl09vqq1818c8ue4il90ebn.apps.googleusercontent.com',
    iosClientId: '857676139805-ogtp0ussv98s6tn4satgit2mdt19odt1.apps.googleusercontent.com',
    iosBundleId: 'com.example.tofuBot',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC_nqsYrRzmikF33zIsd4zA_zz2nw4wEb8',
    appId: '1:857676139805:web:5fee27b94ba9c8b45e65f4',
    messagingSenderId: '857676139805',
    projectId: 'tofu-bot-7de67',
    authDomain: 'tofu-bot-7de67.firebaseapp.com',
    storageBucket: 'tofu-bot-7de67.firebasestorage.app',
  );

}