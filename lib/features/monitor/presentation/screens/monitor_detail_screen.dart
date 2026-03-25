import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/monitor_providers.dart';
import '../../../../core/theme/app_theme.dart';

class MonitorDetailScreen extends ConsumerWidget {
  final String monitorId;
  const MonitorDetailScreen({super.key, required this.monitorId});

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
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.bgSurface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monitor.nickname,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            icon: '♥',
                            value: monitor.votes.toString(),
                            label: 'Votes',
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            icon: '🔥',
                            value: '${monitor.sightingStreak} days',
                            label: 'Streak',
                          ),
                          const SizedBox(width: 8),
                          _StatCard(
                            icon: '📏',
                            value: monitor.size,
                            label: 'Size',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Last seen
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📍 LAST SEEN',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${monitor.parkName} (${monitor.parkNameEn})',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Personality
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🧬 PERSONALITY',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(monitor.personality,
                                style: Theme.of(context).textTheme.bodyLarge),
                            Text(monitor.personalityEn,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Vote
                              },
                              icon: const Text('♥'),
                              label: const Text('Vote Cute!'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.heart,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Share
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
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

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
