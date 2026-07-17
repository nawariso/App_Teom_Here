import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/monitor.dart';
import '../providers/monitor_providers.dart';

class MonitorDetailScreen extends ConsumerWidget {
  const MonitorDetailScreen({super.key, required this.monitorId});

  final String monitorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitorAsync = ref.watch(monitorDetailProvider(monitorId));

    return Scaffold(
      body: monitorAsync.when(
        data: (monitor) {
          if (monitor == null) {
            return const Center(child: Text('Monitor not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(monitor.name),
                  background: _HeroImage(monitor: monitor),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monitor.nickname,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.favorite_rounded,
                            value: monitor.votes.toString(),
                            label: 'Votes',
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            icon: Icons.local_fire_department_rounded,
                            value: monitor.sightingCount.toString(),
                            label: 'Sightings',
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            icon: Icons.straighten_rounded,
                            value: monitor.size,
                            label: 'Size',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoPanel(
                        title: 'LAST SEEN',
                        icon: Icons.place_rounded,
                        child: Text(
                          '${monitor.parkName} (${monitor.parkNameEn})',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoPanel(
                        title: 'PERSONALITY',
                        icon: Icons.psychology_alt_rounded,
                        muted: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monitor.personality,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              monitor.personalityEn,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.favorite_rounded),
                              label: const Text('Vote soon'),
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor:
                                    AppColors.heart.withValues(alpha: 0.25),
                                disabledForegroundColor: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.share_rounded),
                              label: const Text('Share soon'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.monitor});

  final Monitor monitor;

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
    if (monitor.photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: monitor.photoUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _HeroFallback(
          badge: monitor.badge,
          color: _rarityColor,
        ),
      );
    }

    return _HeroFallback(badge: monitor.badge, color: _rarityColor);
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.badge, required this.color});

  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.35),
            AppColors.bgSurface,
          ],
        ),
      ),
      child: Center(
        child: Text(
          badge,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 56,
            fontWeight: FontWeight.w800,
            fontFamily: 'Fredoka',
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.muted = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: muted
            ? Colors.white.withValues(alpha: 0.03)
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: muted
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: muted ? AppColors.textSecondary : AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: muted ? AppColors.textSecondary : AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
