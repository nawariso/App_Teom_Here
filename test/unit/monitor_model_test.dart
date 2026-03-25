import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/features/monitor/domain/models/monitor.dart';

void main() {
  group('Monitor Model', () {
    test('should create Monitor from JSON', () {
      final json = {
        'id': 'test-id',
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
        'lastSeenAt': '2026-03-25T10:00:00.000Z',
        'lastSeenBy': 'user-123',
        'photoGallery': <String>[],
        'tags': <String>[],
      };

      final monitor = Monitor.fromJson(json);

      expect(monitor.id, 'test-id');
      expect(monitor.name, 'ลุงสมชาย');
      expect(monitor.nickname, 'Uncle Somchai');
      expect(monitor.votes, 2847);
      expect(monitor.rarity, MonitorRarity.legendary);
      expect(monitor.sightingStreak, 12);
    });

    test('should default sightingStreak to 0', () {
      final json = {
        'id': 'test-id',
        'name': 'test',
        'nickname': 'test',
        'parkName': 'test',
        'parkNameEn': 'test',
        'latitude': 0.0,
        'longitude': 0.0,
        'votes': 0,
        'size': 'small',
        'personality': 'test',
        'personalityEn': 'test',
        'badge': '🦎',
        'rarity': 'common',
        'lastSeenAt': '2026-03-25T10:00:00.000Z',
        'lastSeenBy': 'user-123',
      };

      final monitor = Monitor.fromJson(json);
      expect(monitor.sightingStreak, 0);
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
    test('should create MonitorSighting from JSON', () {
      final json = {
        'id': 'sighting-1',
        'monitorId': 'monitor-1',
        'userId': 'user-1',
        'photoUrl': 'https://example.com/sighting.jpg',
        'latitude': 13.73,
        'longitude': 100.54,
        'parkName': 'สวนลุมพินี',
        'notes': 'อาบแดดอยู่',
        'spottedAt': '2026-03-25T14:30:00.000Z',
      };

      final sighting = MonitorSighting.fromJson(json);

      expect(sighting.id, 'sighting-1');
      expect(sighting.monitorId, 'monitor-1');
      expect(sighting.notes, 'อาบแดดอยู่');
    });
  });
}
