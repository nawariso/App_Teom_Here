import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/core/config/app_environment.dart';

void main() {
  group('AppEnvironmentConfig.parse', () {
    test('parses every supported environment explicitly', () {
      expect(
        AppEnvironmentConfig.parse('demo').environment,
        AppEnvironment.demo,
      );
      expect(
        AppEnvironmentConfig.parse('dev').environment,
        AppEnvironment.dev,
      );
      expect(
        AppEnvironmentConfig.parse('production').environment,
        AppEnvironment.production,
      );
    });

    test('maps Firebase environments to their expected project IDs', () {
      expect(AppEnvironmentConfig.parse('demo').firebaseProjectId, isNull);
      expect(
        AppEnvironmentConfig.parse('dev').firebaseProjectId,
        'toem-here-dev',
      );
      expect(
        AppEnvironmentConfig.parse('production').firebaseProjectId,
        'toem-here-prod',
      );
    });

    test('requires an explicit environment', () {
      expect(
        () => AppEnvironmentConfig.parse(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unknown values and ambiguous aliases', () {
      for (final value in ['prod', 'development', 'local', 'DEMO']) {
        expect(
          () => AppEnvironmentConfig.parse(value),
          throwsA(isA<FormatException>()),
          reason: '$value must not be accepted',
        );
      }
    });

    test('only demo mode disables Firebase', () {
      expect(AppEnvironmentConfig.parse('demo').usesFirebase, isFalse);
      expect(AppEnvironmentConfig.parse('dev').usesFirebase, isTrue);
      expect(
        AppEnvironmentConfig.parse('production').usesFirebase,
        isTrue,
      );
    });
  });
}
