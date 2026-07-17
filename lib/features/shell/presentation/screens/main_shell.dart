import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

enum _ShellTab {
  home(AppRoutes.home, Icons.home_rounded, 'Home'),
  map(AppRoutes.map, Icons.map_rounded, 'Map'),
  camera(AppRoutes.camera, Icons.camera_alt_rounded, 'Camera'),
  ranking(AppRoutes.ranking, Icons.emoji_events_rounded, 'Rank'),
  profile(AppRoutes.profile, Icons.person_rounded, 'Me');

  const _ShellTab(this.path, this.icon, this.label);

  final String path;
  final IconData icon;
  final String label;
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _ShellTab.values.indexWhere(
      (tab) => location.startsWith(tab.path),
    );
    return index == -1 ? _ShellTab.home.index : index;
  }

  void _onTap(BuildContext context, int index) {
    context.go(_ShellTab.values[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bgDark.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: _ShellTab.home.icon,
                  label: _ShellTab.home.label,
                  isActive: currentIndex == _ShellTab.home.index,
                  onTap: () => _onTap(context, _ShellTab.home.index),
                ),
                _NavItem(
                  icon: _ShellTab.map.icon,
                  label: _ShellTab.map.label,
                  isActive: currentIndex == _ShellTab.map.index,
                  onTap: () => _onTap(context, _ShellTab.map.index),
                ),
                _CameraNavItem(
                  isActive: currentIndex == _ShellTab.camera.index,
                  onTap: () => _onTap(context, _ShellTab.camera.index),
                ),
                _NavItem(
                  icon: _ShellTab.ranking.icon,
                  label: _ShellTab.ranking.label,
                  isActive: currentIndex == _ShellTab.ranking.index,
                  onTap: () => _onTap(context, _ShellTab.ranking.index),
                ),
                _NavItem(
                  icon: _ShellTab.profile.icon,
                  label: _ShellTab.profile.label,
                  isActive: currentIndex == _ShellTab.profile.index,
                  onTap: () => _onTap(context, _ShellTab.profile.index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'NotoSansThai',
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraNavItem extends StatelessWidget {
  const _CameraNavItem({
    required this.isActive,
    required this.onTap,
  });
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: AppColors.bgDark,
            size: 26,
          ),
        ),
      ),
    );
  }
}
