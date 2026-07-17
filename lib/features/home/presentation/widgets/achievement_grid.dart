import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementGrid extends StatelessWidget {
  const AchievementGrid({super.key});

  static const _achievements = [
    _AchievementData(
      icon: Icons.pets_rounded,
      title: 'First Spot',
      description: 'Log your first sighting',
      unlocked: true,
    ),
    _AchievementData(
      icon: Icons.map_rounded,
      title: 'Park Explorer',
      description: 'Visit 3 parks',
      unlocked: false,
    ),
    _AchievementData(
      icon: Icons.favorite_rounded,
      title: 'Fan Club',
      description: 'Vote ${AppConstants.xpPerVote * 10} times',
      unlocked: false,
    ),
    _AchievementData(
      icon: Icons.photo_camera_rounded,
      title: 'Paparazzi',
      description: 'Submit 10 photos',
      unlocked: false,
    ),
    _AchievementData(
      icon: Icons.workspace_premium_rounded,
      title: 'Legend Hunter',
      description: 'Find a legendary monitor',
      unlocked: false,
    ),
    _AchievementData(
      icon: Icons.local_fire_department_rounded,
      title: 'On a Streak',
      description: 'Spot monitors 7 days in a row',
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        return _AchievementTile(data: _achievements[index]);
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.data});

  final _AchievementData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: data.unlocked
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: data.unlocked
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.icon,
            size: 28,
            color: data.unlocked ? AppColors.primary : const Color(0xFF444444),
          ),
          const SizedBox(height: 6),
          Text(
            data.title,
            style: TextStyle(
              color:
                  data.unlocked ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Fredoka',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            data.description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontFamily: 'Fredoka',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (data.unlocked) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 13,
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementData {
  const _AchievementData({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;
}
