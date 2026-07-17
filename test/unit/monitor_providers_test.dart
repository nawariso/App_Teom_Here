import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:toem_here/features/monitor/data/monitor_repository.dart';
import 'package:toem_here/features/monitor/domain/models/monitor.dart';
import 'package:toem_here/features/monitor/presentation/providers/monitor_providers.dart';

import '../helpers/test_helpers.mocks.dart';

// Shared test fixture
Monitor _makeMonitor({
  String id = 'monitor-1',
  String name = 'ลุงสมชาย',
  int votes = 100,
  MonitorRarity rarity = MonitorRarity.common,
}) {
  return Monitor(
    id: id,
    name: name,
    nickname: 'Nick',
    parkName: 'สวนลุมพินี',
    parkNameEn: 'Lumpini Park',
    latitude: 13.73,
    longitude: 100.54,
    votes: votes,
    size: 'medium',
    personality: 'chill',
    personalityEn: 'chill',
    badge: '🦎',
    rarity: rarity,
    lastSeenAt: DateTime(2026, 3, 25),
    lastSeenBy: 'user-1',
  );
}

void main() {
  late MockMonitorRepository mockRepo;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        monitorRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  setUp(() {
    mockRepo = MockMonitorRepository();
  });

  group('monitorsRankedProvider', () {
    test('emits list of monitors from repository', () async {
      final monitors = [
        _makeMonitor(id: 'a', votes: 200),
        _makeMonitor(id: 'b', votes: 100),
      ];

      when(mockRepo.watchMonitorsByVotes())
          .thenAnswer((_) => Stream.value(monitors));

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(monitorsRankedProvider.future);

      expect(result.length, 2);
      expect(result.first.id, 'a');
      expect(result.first.votes, 200);
    });

    test('emits empty list when no monitors', () async {
      when(mockRepo.watchMonitorsByVotes()).thenAnswer((_) => Stream.value([]));

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(monitorsRankedProvider.future);

      expect(result, isEmpty);
    });
  });

  group('monitorDetailProvider', () {
    test('returns monitor when found', () async {
      final monitor = _makeMonitor(id: 'monitor-1');
      when(mockRepo.getMonitor('monitor-1')).thenAnswer((_) async => monitor);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(monitorDetailProvider('monitor-1').future);

      expect(result, isNotNull);
      expect(result!.id, 'monitor-1');
    });

    test('returns null when monitor not found', () async {
      when(mockRepo.getMonitor('unknown')).thenAnswer((_) async => null);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(monitorDetailProvider('unknown').future);

      expect(result, isNull);
    });
  });

  group('parkMonitorCountsProvider', () {
    test('returns park counts from repository', () async {
      when(mockRepo.getParkMonitorCounts()).thenAnswer(
        (_) async => {
          'สวนลุมพินี': 5,
          'สวนจตุจักร': 3,
        },
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(parkMonitorCountsProvider.future);

      expect(result['สวนลุมพินี'], 5);
      expect(result['สวนจตุจักร'], 3);
    });
  });

  group('hasVotedProvider', () {
    test('returns true when user has voted', () async {
      when(mockRepo.hasVoted('monitor-1', 'user-1'))
          .thenAnswer((_) async => true);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        hasVotedProvider((monitorId: 'monitor-1', userId: 'user-1')).future,
      );

      expect(result, isTrue);
    });

    test('returns false when user has not voted', () async {
      when(mockRepo.hasVoted('monitor-1', 'user-new'))
          .thenAnswer((_) async => false);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        hasVotedProvider((monitorId: 'monitor-1', userId: 'user-new')).future,
      );

      expect(result, isFalse);
    });
  });

  group('rankingFilterProvider', () {
    test('defaults to allTime', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      expect(container.read(rankingFilterProvider), RankingFilter.allTime);
    });

    test('can be changed to weekly', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(rankingFilterProvider.notifier).state =
          RankingFilter.weekly;

      expect(container.read(rankingFilterProvider), RankingFilter.weekly);
    });
  });
}
