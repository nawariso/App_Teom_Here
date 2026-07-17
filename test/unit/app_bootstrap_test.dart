import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/core/bootstrap/app_bootstrap.dart';
import 'package:toem_here/core/config/app_environment.dart';
import 'package:toem_here/firebase_options.dart';

void main() {
  FirebaseOptions optionsFor(String projectId) => FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: projectId,
      );

  test('demo mode never resolves options or initializes Firebase', () async {
    var resolvedOptions = false;
    var initializationCalls = 0;

    final result = await bootstrapApp(
      config: AppEnvironmentConfig.parse('demo'),
      resolveOptions: (_) {
        resolvedOptions = true;
        return optionsFor('unexpected');
      },
      initializeFirebase: (_) async {
        initializationCalls += 1;
      },
    );

    expect(result.usesFirebase, isFalse);
    expect(resolvedOptions, isFalse);
    expect(initializationCalls, 0);
  });

  test('dev initializes exactly once with the configured project', () async {
    FirebaseOptions? initializedWith;

    final result = await bootstrapApp(
      config: AppEnvironmentConfig.parse('dev'),
      resolveOptions: (_) => optionsFor('toem-here-dev'),
      initializeFirebase: (options) async {
        initializedWith = options;
      },
    );

    expect(result.usesFirebase, isTrue);
    expect(initializedWith?.projectId, 'toem-here-dev');
  });

  test('production initialization failures propagate without demo fallback',
      () async {
    final failure = StateError('Firebase unavailable');

    await expectLater(
      bootstrapApp(
        config: AppEnvironmentConfig.parse('production'),
        resolveOptions: (_) => optionsFor('toem-here-prod'),
        initializeFirebase: (_) => Future<void>.error(failure),
      ),
      throwsA(same(failure)),
    );
  });

  test('rejects Firebase options for the wrong project before initialization',
      () async {
    var initializationCalls = 0;

    await expectLater(
      bootstrapApp(
        config: AppEnvironmentConfig.parse('production'),
        resolveOptions: (_) => optionsFor('toem-here-dev'),
        initializeFirebase: (_) async {
          initializationCalls += 1;
        },
      ),
      throwsA(isA<StateError>()),
    );

    expect(initializationCalls, 0);
  });

  test('rejects placeholder Firebase options before initialization', () async {
    var initializationCalls = 0;
    const placeholderOptions = FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'toem-here-dev',
    );

    await expectLater(
      bootstrapApp(
        config: AppEnvironmentConfig.parse('dev'),
        resolveOptions: (_) => placeholderOptions,
        initializeFirebase: (_) async {
          initializationCalls += 1;
        },
      ),
      throwsA(isA<StateError>()),
    );

    expect(initializationCalls, 0);
  });

  test('real resolver selects dev and production projects by platform', () {
    final dev = DefaultFirebaseOptions.forEnvironmentAndPlatform(
      AppEnvironment.dev,
      TargetPlatform.android,
    );
    final production = DefaultFirebaseOptions.forEnvironmentAndPlatform(
      AppEnvironment.production,
      TargetPlatform.iOS,
    );

    expect(dev.projectId, AppEnvironmentConfig.devProjectId);
    expect(production.projectId, AppEnvironmentConfig.productionProjectId);
    expect(dev.appId, contains('YOUR_DEV_ANDROID'));
    expect(production.appId, contains('YOUR_PRODUCTION_IOS'));
  });

  test('real resolver fails closed before Firebase initialization', () async {
    var initializationCalls = 0;

    await expectLater(
      bootstrapApp(
        config: AppEnvironmentConfig.parse('dev'),
        resolveOptions: (environment) =>
            DefaultFirebaseOptions.forEnvironmentAndPlatform(
          environment,
          TargetPlatform.android,
        ),
        initializeFirebase: (_) async {
          initializationCalls += 1;
        },
      ),
      throwsA(isA<StateError>()),
    );

    expect(initializationCalls, 0);
  });

  test('real resolver rejects demo mode and unsupported platforms', () {
    expect(
      () => DefaultFirebaseOptions.forEnvironmentAndPlatform(
        AppEnvironment.demo,
        TargetPlatform.android,
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      () => DefaultFirebaseOptions.forEnvironmentAndPlatform(
        AppEnvironment.production,
        TargetPlatform.windows,
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
