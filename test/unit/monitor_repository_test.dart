import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:toem_here/features/monitor/data/monitor_repository.dart';
import 'package:toem_here/features/monitor/domain/models/monitor.dart';

import '../helpers/test_helpers.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockCollectionReference mockMonitorsRef;
  late MockCollectionReference mockSightingsRef;
  late MonitorRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockMonitorsRef = MockCollectionReference();
    mockSightingsRef = MockCollectionReference();

    when(mockFirestore.collection('monitors')).thenReturn(mockMonitorsRef);
    when(mockFirestore.collection('sightings')).thenReturn(mockSightingsRef);

    repository = MonitorRepository(
      firestore: mockFirestore,
      storage: mockStorage,
    );
  });

  group('getMonitor', () {
    test('returns null when document does not exist', () async {
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();

      when(mockMonitorsRef.doc('missing-id')).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      final result = await repository.getMonitor('missing-id');

      expect(result, isNull);
    });

    test('returns Monitor when document exists', () async {
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();

      when(mockMonitorsRef.doc('monitor-1')).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.id).thenReturn('monitor-1');
      when(mockDocSnapshot.data()).thenReturn({
        'name': 'ลุงสมชาย',
        'nickname': 'Uncle Somchai',
        'photoUrl': 'https://example.com/photo.jpg',
        'parkName': 'สวนลุมพินี',
        'parkNameEn': 'Lumpini Park',
        'latitude': 13.7308,
        'longitude': 100.5412,
        'votes': 2847,
        'size': 'ใหญ่มาก (~2m)',
        'personality': 'ชอบอาบแดดริมสระน้ำ',
        'personalityEn': 'Loves sunbathing by the pond',
        'badge': '👑',
        'rarity': 'legendary',
        'sightingStreak': 12,
        'lastSeenAt': Timestamp.fromDate(DateTime(2026, 3, 25)),
        'lastSeenBy': 'user-123',
        'photoGallery': <String>[],
        'tags': <String>[],
      });

      final result = await repository.getMonitor('monitor-1');

      expect(result, isNotNull);
      expect(result!.id, 'monitor-1');
      expect(result.name, 'ลุงสมชาย');
      expect(result.rarity, MonitorRarity.legendary);
      expect(result.votes, 2847);
    });
  });

  group('hasVoted', () {
    test('returns true when voter document exists', () async {
      final mockDocRef = MockDocumentReference();
      final mockVotersRef = MockCollectionReference();
      final mockVoterDocRef = MockDocumentReference();
      final mockVoterSnapshot = MockDocumentSnapshot();

      when(mockMonitorsRef.doc('monitor-1')).thenReturn(mockDocRef);
      when(mockDocRef.collection('voters')).thenReturn(mockVotersRef);
      when(mockVotersRef.doc('user-1')).thenReturn(mockVoterDocRef);
      when(mockVoterDocRef.get()).thenAnswer((_) async => mockVoterSnapshot);
      when(mockVoterSnapshot.exists).thenReturn(true);

      final result = await repository.hasVoted('monitor-1', 'user-1');

      expect(result, isTrue);
    });

    test('returns false when voter document does not exist', () async {
      final mockDocRef = MockDocumentReference();
      final mockVotersRef = MockCollectionReference();
      final mockVoterDocRef = MockDocumentReference();
      final mockVoterSnapshot = MockDocumentSnapshot();

      when(mockMonitorsRef.doc('monitor-1')).thenReturn(mockDocRef);
      when(mockDocRef.collection('voters')).thenReturn(mockVotersRef);
      when(mockVotersRef.doc('user-new')).thenReturn(mockVoterDocRef);
      when(mockVoterDocRef.get()).thenAnswer((_) async => mockVoterSnapshot);
      when(mockVoterSnapshot.exists).thenReturn(false);

      final result = await repository.hasVoted('monitor-1', 'user-new');

      expect(result, isFalse);
    });
  });

  group('getParkMonitorCounts', () {
    test('returns counts grouped by park', () async {
      final mockSnapshot = MockQuerySnapshot();
      final doc1 = MockQueryDocumentSnapshot();
      final doc2 = MockQueryDocumentSnapshot();
      final doc3 = MockQueryDocumentSnapshot();

      when(mockMonitorsRef.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn([doc1, doc2, doc3]);
      when(doc1.data()).thenReturn({'parkName': 'สวนลุมพินี'});
      when(doc2.data()).thenReturn({'parkName': 'สวนลุมพินี'});
      when(doc3.data()).thenReturn({'parkName': 'สวนจตุจักร'});

      final result = await repository.getParkMonitorCounts();

      expect(result['สวนลุมพินี'], 2);
      expect(result['สวนจตุจักร'], 1);
    });

    test('returns empty map when no monitors', () async {
      final mockSnapshot = MockQuerySnapshot();

      when(mockMonitorsRef.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn([]);

      final result = await repository.getParkMonitorCounts();

      expect(result, isEmpty);
    });
  });
}
