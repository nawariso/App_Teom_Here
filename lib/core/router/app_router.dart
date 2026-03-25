import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/camera/presentation/screens/camera_screen.dart';
import '../../features/ranking/presentation/screens/ranking_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/monitor/presentation/screens/monitor_detail_screen.dart';
import '../../features/shell/presentation/screens/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Onboarding & Auth
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: '/camera',
            name: 'camera',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CameraScreen(),
            ),
          ),
          GoRoute(
            path: '/ranking',
            name: 'ranking',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RankingScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Detail screen (outside shell for full-screen)
      GoRoute(
        path: '/monitor/:id',
        name: 'monitor-detail',
        builder: (context, state) {
          final monitorId = state.pathParameters['id']!;
          return MonitorDetailScreen(monitorId: monitorId);
        },
      ),
    ],
  );
});
