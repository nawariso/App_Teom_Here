import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import 'core/config/app_environment.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions forEnvironment(AppEnvironment environment) {
    return forEnvironmentAndPlatform(environment, defaultTargetPlatform);
  }

  static FirebaseOptions forEnvironmentAndPlatform(
    AppEnvironment environment,
    TargetPlatform platform,
  ) {
    if (environment == AppEnvironment.demo) {
      throw StateError('Demo mode does not use Firebase options.');
    }

    return switch ((environment, platform)) {
      (AppEnvironment.dev, TargetPlatform.android) => devAndroid,
      (AppEnvironment.dev, TargetPlatform.iOS) => devIos,
      (AppEnvironment.production, TargetPlatform.android) => productionAndroid,
      (AppEnvironment.production, TargetPlatform.iOS) => productionIos,
      (_, _) => throw UnsupportedError(
          'Firebase is not configured for ${platform.name}.',
        ),
    };
  }

  // Replace each placeholder with values from the matching Firebase project.
  // Keeping these explicit and invalid makes dev/production fail closed until
  // both projects have been configured; never reuse one environment's values.
  static const FirebaseOptions devAndroid = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_DEV_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: AppEnvironmentConfig.devProjectId,
    storageBucket: 'toem-here-dev.appspot.com',
  );

  static const FirebaseOptions devIos = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_DEV_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: AppEnvironmentConfig.devProjectId,
    storageBucket: 'toem-here-dev.appspot.com',
    iosBundleId: 'com.toemhere.app',
  );

  static const FirebaseOptions productionAndroid = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_PRODUCTION_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: AppEnvironmentConfig.productionProjectId,
    storageBucket: 'toem-here-prod.appspot.com',
  );

  static const FirebaseOptions productionIos = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_PRODUCTION_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: AppEnvironmentConfig.productionProjectId,
    storageBucket: 'toem-here-prod.appspot.com',
    iosBundleId: 'com.toemhere.app',
  );
}
