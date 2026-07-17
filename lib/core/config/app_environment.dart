enum AppEnvironment { demo, dev, production }

final class AppEnvironmentConfig {
  const AppEnvironmentConfig._({
    required this.environment,
    required this.firebaseProjectId,
  });

  static const environmentKey = 'APP_ENV';
  static const devProjectId = 'toem-here-dev';
  static const productionProjectId = 'toem-here-prod';

  final AppEnvironment environment;
  final String? firebaseProjectId;

  bool get usesFirebase => environment != AppEnvironment.demo;

  static AppEnvironmentConfig fromCompileTime() {
    const value = String.fromEnvironment(environmentKey);
    return parse(value);
  }

  static AppEnvironmentConfig parse(String value) {
    return switch (value) {
      'demo' => const AppEnvironmentConfig._(
          environment: AppEnvironment.demo,
          firebaseProjectId: null,
        ),
      'dev' => const AppEnvironmentConfig._(
          environment: AppEnvironment.dev,
          firebaseProjectId: devProjectId,
        ),
      'production' => const AppEnvironmentConfig._(
          environment: AppEnvironment.production,
          firebaseProjectId: productionProjectId,
        ),
      _ => throw FormatException(
          '$environmentKey must be explicitly set to demo, dev, or production.',
          value,
        ),
    };
  }
}
