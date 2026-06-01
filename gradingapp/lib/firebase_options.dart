import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return android; // Default fallback for non-web platforms
  }

  // NOTE: Replace the apiKey and appId values with the values from your
  // Firebase project settings (Console → Project settings → General → Your apps).
  // The project is: gradingapp (ID: gradingapp-df6bb)

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQipRVtbTH8Pe59FSyQb9iNwgwR6rMoiM',
    appId: '1:893550464962:android:44c53d6e1cd74ecc9a905b',
    messagingSenderId: '893550464962',
    projectId: 'gradingapp-df6bb',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'gradingapp-df6bb',
    iosBundleId: 'REPLACE_WITH_YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'gradingapp-df6bb',
    authDomain: 'gradingapp-df6bb.firebaseapp.com',
    storageBucket: 'gradingapp-df6bb.appspot.com',
  );
}
