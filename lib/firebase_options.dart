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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNKwI9CKCNbAf9bgBksdXXVqTvHPPqB6M',
    appId: '1:464023817804:android:f27a0bc63bfeeef598eee9',
    messagingSenderId: '464023817804',
    projectId: 'snitch-clothing',
    storageBucket: 'snitch-clothing.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNKwI9CKCNbAf9bgBksdXXVqTvHPPqB6M',
    appId: '1:464023817804:ios:f27a0bc63bfeeef598eee9',
    messagingSenderId: '464023817804',
    projectId: 'snitch-clothing',
    storageBucket: 'snitch-clothing.firebasestorage.app',
    iosBundleId: 'com.isham.snitchclothing',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNKwI9CKCNbAf9bgBksdXXVqTvHPPqB6M',
    appId: '1:464023817804:ios:f27a0bc63bfeeef598eee9',
    messagingSenderId: '464023817804',
    projectId: 'snitch-clothing',
    storageBucket: 'snitch-clothing.firebasestorage.app',
    iosBundleId: 'com.isham.snitchclothing',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNKwI9CKCNbAf9bgBksdXXVqTvHPPqB6M',
    appId: '1:464023817804:web:f27a0bc63bfeeef598eee9',
    messagingSenderId: '464023817804',
    projectId: 'snitch-clothing',
    authDomain: 'snitch-clothing.firebaseapp.com',
    storageBucket: 'snitch-clothing.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNKwI9CKCNbAf9bgBksdXXVqTvHPPqB6M',
    appId: '1:464023817804:web:f27a0bc63bfeeef598eee9',
    messagingSenderId: '464023817804',
    projectId: 'snitch-clothing',
    authDomain: 'snitch-clothing.firebaseapp.com',
    storageBucket: 'snitch-clothing.firebasestorage.app',
  );
}
