class AppRoutes {
  const AppRoutes._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const map = '/map';
  static const camera = '/camera';
  static const ranking = '/ranking';
  static const profile = '/profile';
  static const monitorDetail = '/monitor/:id';

  static String monitorDetailPath(String id) => '/monitor/$id';
}
