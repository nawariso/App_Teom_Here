import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../monitor/presentation/providers/monitor_providers.dart';

class LiveSightingCard extends ConsumerWidget {
  const LiveSightingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sightingsAsync = ref.watch(recentSightingsProvider);

    return sightingsAsync.when(
      data: (sightings) {
        if (sightings.isEmpty) return const SizedBox.shrink();
        final latest = sightings.first;
        final minutesAgo =
            DateTime.now().difference(latest.spottedAt).inMinutes;
        final timeLabel = minutesAgo < 1
            ? 'Just now'
            : minutesAgo < 60
                ? '$minutesAgo min ago'
                : '${(minutesAgo / 60).floor()}h ago';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🦎 Spotted at ${latest.parkName}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Fredoka',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timeLabel,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
