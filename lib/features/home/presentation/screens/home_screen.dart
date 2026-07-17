import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../monitor/presentation/providers/monitor_providers.dart';
import '../widgets/achievement_grid.dart';
import '../widgets/collection_carousel.dart';
import '../widgets/live_sighting_card.dart';
import '../widgets/ranking_preview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitorsAsync = ref.watch(monitorsRankedProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const _HomeAppBar(),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LiveSightingCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Cuteness Ranking',
              actionLabel: 'View all',
              onActionTap: () => context.go(AppRoutes.ranking),
            ),
          ),
          monitorsAsync.when(
            data: (monitors) {
              final visibleCount = monitors.length < 3 ? monitors.length : 3;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final monitor = monitors[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: RankingPreviewCard(
                        monitor: monitor,
                        rank: index + 1,
                        onTap: () => context.push(
                          AppRoutes.monitorDetailPath(monitor.id),
                        ),
                      ),
                    );
                  },
                  childCount: visibleCount,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          const SliverToBoxAdapter(
            child: _CollectionHeader(),
          ),
          const SliverToBoxAdapter(
            child: CollectionCarousel(),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(title: 'Achievements'),
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

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF0D1F0D),
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 22,
              ),
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.notifications_rounded,
              color: AppColors.bgDark,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (actionLabel != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            '3 of ${AppConstants.maxCollectionGoal} discovered',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
