import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../monitor/presentation/providers/monitor_providers.dart';
import '../widgets/live_sighting_card.dart';
import '../widgets/ranking_preview.dart';
import '../widgets/collection_carousel.dart';
import '../widgets/achievement_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitorsAsync = ref.watch(monitorsRankedProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFF0D1F0D),
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              title: Row(
                children: [
                  Text(
                    'Toem Here!',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 22,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.bgDark,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // ─── Live Sighting Alert ───
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LiveSightingCard(),
            ),
          ),

          // ─── Ranking Preview ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cuteness Ranking',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/ranking'),
                    child: Text(
                      'View all',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Top 3 Monitors ───
          monitorsAsync.when(
            data: (monitors) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= 3 || index >= monitors.length) return null;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: RankingPreviewCard(
                      monitor: monitors[index],
                      rank: index + 1,
                      onTap: () =>
                          context.push('/monitor/${monitors[index].id}'),
                    ),
                  );
                },
                childCount: 3,
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),

          // ─── My Collection ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Collection',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 of 50 discovered',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: CollectionCarousel(),
          ),

          // ─── Achievements ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Achievements',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: AchievementGrid(),
            ),
          ),
        ],
      ),
    );
  }
}
