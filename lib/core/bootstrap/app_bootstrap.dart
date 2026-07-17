import 'package:firebase_core/firebase_core.dart';

import '../config/app_environment.dart';

typedef FirebaseOptionsResolver = FirebaseOptions Function(
  AppEnvironment environment,
);
typedef FirebaseInitializer = Future<void> Function(FirebaseOptions options);

final class AppBootstrapResult {
  const AppBootstrapResult({required this.config});

  final AppEnvironmentConfig config;

  bool get usesFirebase => config.usesFirebase;
}

Future<AppBootstrapResult> bootstrapApp({
  required AppEnvironmentConfig config,
  required FirebaseOptionsResolver resolveOptions,
  required FirebaseInitializer initializeFirebase,
}) async {
  if (!config.usesFirebase) {
    return AppBootstrapResult(config: config);
  }

  final options = resolveOptions(config.environment);
  _validateFirebaseOptions(config, options);
  await initializeFirebase(options);

  return AppBootstrapResult(config: config);
}

void _validateFirebaseOptions(
  AppEnvironmentConfig config,
  FirebaseOptions options,
) {
  final requiredValues = <String, String>{
    'apiKey': options.apiKey,
    'appId': options.appId,
    'messagingSenderId': options.messagingSenderId,
    'projectId': options.projectId,
  };

  for (final entry in requiredValues.entries) {
    final value = entry.value.trim();
    if (value.isEmpty || value.startsWith('YOUR_')) {
      throw StateError(
        'Firebase ${entry.key} is missing or still contains a placeholder.',
      );
    }
  }

  if (options.projectId != config.firebaseProjectId) {
    throw StateError(
      'Firebase project ${options.projectId} does not match '
      '${config.firebaseProjectId} for ${config.environment.name}.',
    );
  }
}
