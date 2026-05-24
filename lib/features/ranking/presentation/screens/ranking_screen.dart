import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/ranking_preview.dart';
import '../../../monitor/presentation/providers/monitor_providers.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitorsAsync = ref.watch(monitorsRankedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        backgroundColor: AppColors.bgSurface,
      ),
      body: monitorsAsync.when(
        data: (monitors) {
          if (monitors.isEmpty) {
            return const Center(
              child: Text('No monitors ranked yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: monitors.length,
            itemBuilder: (context, index) {
              final monitor = monitors[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RankingPreviewCard(
                  monitor: monitor,
                  rank: index + 1,
                  onTap: () => context.push('/monitor/${monitor.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load ranking: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
