import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementGrid extends StatelessWidget {
  const AchievementGrid({super.key});

  static const _achievements = [
    _AchievementData(
      icon: '🦎',
      title: 'First Spot',
      descriptionTh: 'พบวารานัสตัวแรก',
      unlocked: true,
    ),
    _AchievementData(
      icon: '🗺️',
      title: 'Park Explorer',
      descriptionTh: 'เยี่ยมชม 3 สวน',
      unlocked: false,
    ),
    _AchievementData(
      icon: '♥',
      title: 'Fan Club',
      descriptionTh: 'โหวต ${AppConstants.xpPerVote * 10} ครั้ง',
      unlocked: false,
    ),
    _AchievementData(
      icon: '📸',
      title: 'Paparazzi',
      descriptionTh: 'ถ่ายภาพ 10 ใบ',
      unlocked: false,
    ),
    _AchievementData(
      icon: '👑',
      title: 'Legend Hunter',
      descriptionTh: 'พบ Legendary 1 ตัว',
      unlocked: false,
    ),
    _AchievementData(
      icon: '🔥',
      title: 'On a Streak',
      descriptionTh: 'พบ 7 วันติดต่อกัน',
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
  final _AchievementData data;

  const _AchievementTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: data.unlocked
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: data.unlocked
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.icon,
            style: TextStyle(
              fontSize: 28,
              color: data.unlocked ? null : const Color(0xFF444444),
            ),
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
            data.descriptionTh,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontFamily: 'NotoSansThai',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (data.unlocked) ...[
            const SizedBox(height: 4),
            const Text('✓',
                style: TextStyle(color: AppColors.primary, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class _AchievementData {
  final String icon;
  final String title;
  final String descriptionTh;
  final bool unlocked;

  const _AchievementData({
    required this.icon,
    required this.title,
    required this.descriptionTh,
    required this.unlocked,
  });
}
