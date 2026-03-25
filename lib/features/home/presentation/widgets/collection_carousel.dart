import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../monitor/domain/models/monitor.dart';
import '../../../monitor/presentation/providers/monitor_providers.dart';

class CollectionCarousel extends ConsumerWidget {
  const CollectionCarousel({super.key});

  Color _rarityColor(MonitorRarity rarity) {
    switch (rarity) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final monitorsAsync = ref.watch(monitorsRankedProvider);

    return SizedBox(
      height: 110,
      child: monitorsAsync.when(
        data: (monitors) {
          if (monitors.isEmpty) {
            return const Center(
              child: Text(
                'No monitors collected yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: monitors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final monitor = monitors[index];
              final color = _rarityColor(monitor.rarity);
              return _CollectionItem(monitor: monitor, rarityColor: color);
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => _CollectionSkeleton(),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _CollectionItem extends StatelessWidget {
  final Monitor monitor;
  final Color rarityColor;

  const _CollectionItem({required this.monitor, required this.rarityColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: rarityColor.withOpacity(0.4), width: 1.5),
            color: rarityColor.withOpacity(0.08),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: monitor.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: monitor.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                        child: Text(monitor.badge,
                            style: const TextStyle(fontSize: 28))),
                    errorWidget: (_, __, ___) => Center(
                        child: Text(monitor.badge,
                            style: const TextStyle(fontSize: 28))),
                  )
                : Center(
                    child: Text(monitor.badge,
                        style: const TextStyle(fontSize: 28))),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            monitor.name,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontFamily: 'NotoSansThai',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CollectionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.bgCard,
      ),
    );
  }
}
