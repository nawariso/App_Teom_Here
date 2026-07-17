import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../monitor/domain/models/monitor.dart';

class RankingPreviewCard extends StatelessWidget {
  const RankingPreviewCard({
    super.key,
    required this.monitor,
    required this.rank,
    required this.onTap,
  });

  final Monitor monitor;
  final int rank;
  final VoidCallback onTap;

  Color get _rankColor {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return AppColors.silver;
    return AppColors.bronze;
  }

  Color get _rarityColor {
    switch (monitor.rarity) {
      case MonitorRarity.legendary:
        return AppColors.rarityLegendary;
      case MonitorRarity.epic:
        return AppColors.rarityEpic;
      case MonitorRarity.rare:
        return AppColors.rarityRare;
      case MonitorRarity.common:
        return AppColors.rarityCommon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: _rankColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Fredoka',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: monitor.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: monitor.photoUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _PhotoPlaceholder(
                        badge: monitor.badge,
                        color: _rarityColor,
                      ),
                      errorWidget: (_, __, ___) => _PhotoPlaceholder(
                        badge: monitor.badge,
                        color: _rarityColor,
                      ),
                    )
                  : _PhotoPlaceholder(
                      badge: monitor.badge,
                      color: _rarityColor,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monitor.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Fredoka',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monitor.parkName,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Fredoka',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _rarityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      monitor.rarity.name.toUpperCase(),
                      style: TextStyle(
                        color: _rarityColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.heart,
                  size: 14,
                ),
                Text(
                  '${monitor.votes}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.badge, required this.color});

  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(badge, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
