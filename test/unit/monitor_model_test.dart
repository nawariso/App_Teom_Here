import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/features/monitor/domain/models/monitor.dart';

Map<String, dynamic> monitorJson({
  Object? lastSeenAt = '2026-03-25T10:00:00.000Z',
  Object? lastSeenBy = 'user-123',
}) {
  return {
    'id': 'test-id',
    'name': 'ลุงสมชาย',
    'nickname': 'Uncle Somchai',
    'photoUrl': 'https://example.com/photo.jpg',
    'parkId': 'lumpini',
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
    'sightingCount': 12,
    'lastSeenAt': lastSeenAt,
    'lastSeenBy': lastSeenBy,
    'photoGallery': <String>[],
    'tags': <String>[],
    'moderationStatus': 'approved',
  };
}

void main() {
  group('Monitor Model', () {
    test('should create Monitor from canonical JSON', () {
      final monitor = Monitor.fromJson(monitorJson());

      expect(monitor.id, 'test-id');
      expect(monitor.name, 'ลุงสมชาย');
      expect(monitor.nickname, 'Uncle Somchai');
      expect(monitor.votes, 2847);
      expect(monitor.rarity, MonitorRarity.legendary);
      expect(monitor.sightingCount, 12);
      expect(monitor.moderationStatus, ModerationStatus.approved);
    });

    test('supports monitors that have never been seen', () {
      final json = monitorJson(lastSeenAt: null, lastSeenBy: null)
        ..remove('sightingCount');
      final monitor = Monitor.fromJson(json);

      expect(monitor.sightingCount, 0);
      expect(monitor.lastSeenAt, isNull);
      expect(monitor.lastSeenBy, isNull);
    });

    test('reads legacy sightingStreak during migration', () {
      final json = monitorJson()..remove('sightingCount');
      json['sightingStreak'] = 4;

      final monitor = Monitor.fromJson(json);

      expect(monitor.sightingCount, 4);
    });

    test('rarity enum should parse correctly', () {
      expect(MonitorRarity.values.length, 4);
      expect(MonitorRarity.common.name, 'common');
      expect(MonitorRarity.rare.name, 'rare');
      expect(MonitorRarity.epic.name, 'epic');
      expect(MonitorRarity.legendary.name, 'legendary');
    });
  });

  group('MonitorSighting Model', () {
    test('should create known MonitorSighting from JSON', () {
      final sighting = MonitorSighting.fromJson({
        'id': 'sighting-1',
        'monitorId': 'monitor-1',
        'submittedAsUnknown': false,
        'userId': 'user-1',
        'photoUrl': 'https://example.com/sighting.jpg',
        'latitude': 13.73,
        'longitude': 100.54,
        'parkName': 'สวนลุมพินี',
        'notes': 'อาบแดดอยู่',
        'spottedAt': '2026-03-25T14:30:00.000Z',
      });

      expect(sighting.id, 'sighting-1');
      expect(sighting.monitorId, 'monitor-1');
      expect(sighting.notes, 'อาบแดดอยู่');
      expect(sighting.submittedAsUnknown, isFalse);
    });

    test('represents an unknown sighting with no monitor ID', () {
      final sighting = MonitorSighting.fromJson({
        'id': 'unknown-sighting',
        'monitorId': null,
        'submittedAsUnknown': true,
        'userId': 'user-1',
        'photoUrl': 'https://example.com/unknown.jpg',
        'storagePath': 'sightings/user-1/unknown-sighting/photo.jpg',
        'parkId': 'lumpini',
        'parkName': 'Lumpini Park',
        'latitude': 13.73,
        'longitude': 100.54,
        'moderationStatus': 'pending',
        'spottedAt': '2026-03-25T14:30:00.000Z',
      });

      expect(sighting.monitorId, isNull);
      expect(sighting.submittedAsUnknown, isTrue);
    });
  });
}
