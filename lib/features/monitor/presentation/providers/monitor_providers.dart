import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/monitor_repository.dart';
import '../domain/models/monitor.dart';

// ─── Monitors ranked by votes ───
final monitorsRankedProvider = StreamProvider<List<Monitor>>((ref) {
  final repo = ref.watch(monitorRepositoryProvider);
  return repo.watchMonitorsByVotes();
});

// ─── Single monitor detail ───
final monitorDetailProvider =
    FutureProvider.family<Monitor?, String>((ref, id) async {
  final repo = ref.watch(monitorRepositoryProvider);
  return repo.getMonitor(id);
});

// ─── Recent sightings ───
final recentSightingsProvider = StreamProvider<List<MonitorSighting>>((ref) {
  final repo = ref.watch(monitorRepositoryProvider);
  return repo.watchRecentSightings();
});

// ─── Park monitor counts (for map) ───
final parkMonitorCountsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(monitorRepositoryProvider);
  return repo.getParkMonitorCounts();
});

// ─── Vote state ───
final hasVotedProvider =
    FutureProvider.family<bool, ({String monitorId, String userId})>(
        (ref, params) async {
  final repo = ref.watch(monitorRepositoryProvider);
  return repo.hasVoted(params.monitorId, params.userId);
});

// ─── Ranking filter ───
enum RankingFilter { allTime, weekly, newest }

final rankingFilterProvider = StateProvider<RankingFilter>((ref) {
  return RankingFilter.allTime;
});
