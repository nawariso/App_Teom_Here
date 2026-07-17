import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/features/auth/domain/models/user.dart';

void main() {
  group('AppUser Model', () {
    test('should create AppUser from canonical JSON', () {
      final json = {
        'uid': 'user-123',
        'displayName': 'Mickey',
        'email': 'mickey@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'level': 5,
        'totalCollected': 12,
        'totalSightings': 30,
        'parksVisited': 4,
        'xp': 850,
        'achievementIds': ['first_catch', 'park_explorer'],
        'favoriteMonitorIds': ['monitor-2'],
        'collectedMonitorIds': ['monitor-1', 'monitor-2'],
      };

      final user = AppUser.fromJson(json);

      expect(user.uid, 'user-123');
      expect(user.displayName, 'Mickey');
      expect(user.email, 'mickey@example.com');
      expect(user.level, 5);
      expect(user.totalCollected, 12);
      expect(user.totalSightings, 30);
      expect(user.xp, 850);
      expect(user.achievementIds, ['first_catch', 'park_explorer']);
      expect(user.favoriteMonitorIds, ['monitor-2']);
      expect(user.collectedMonitorIds.length, 2);
    });

    test('should apply default values for new user', () {
      final user = AppUser.fromJson({
        'uid': 'new-user',
        'displayName': 'New User',
      });

      expect(user.level, 1);
      expect(user.totalCollected, 0);
      expect(user.totalSightings, 0);
      expect(user.parksVisited, 0);
      expect(user.xp, 0);
      expect(user.achievementIds, isEmpty);
      expect(user.favoriteMonitorIds, isEmpty);
      expect(user.collectedMonitorIds, isEmpty);
    });

    test('copyWith should produce updated instance', () {
      const user = AppUser(uid: 'u1', displayName: 'Old Name', xp: 100);
      final updated = user.copyWith(displayName: 'New Name', xp: 200);

      expect(updated.uid, 'u1');
      expect(updated.displayName, 'New Name');
      expect(updated.xp, 200);
    });

    test('equality: two users with same data should be equal', () {
      const a = AppUser(uid: 'u1', displayName: 'Alice');
      const b = AppUser(uid: 'u1', displayName: 'Alice');

      expect(a, equals(b));
    });

    test('reads legacy user field names during migration', () {
      final user = AppUser.fromJson({
        'uid': 'legacy-user',
        'displayName': 'Legacy User',
        'totalPhotos': 7,
        'achievements': ['legacy-achievement'],
      });

      expect(user.totalSightings, 7);
      expect(user.achievementIds, ['legacy-achievement']);
    });

    test('serializes only canonical public profile field names', () {
      const user = AppUser(
        uid: 'private-path-id',
        displayName: 'Mickey',
        email: 'private@example.com',
        totalSightings: 2,
        achievementIds: ['first_sighting'],
      );

      final json = user.toJson();

      expect(json['totalSightings'], 2);
      expect(json['achievementIds'], ['first_sighting']);
      expect(json, isNot(contains('totalPhotos')));
      expect(json, isNot(contains('achievements')));
      expect(json, isNot(contains('uid')));
      expect(json, isNot(contains('email')));
    });
  });

  group('Achievement Model', () {
    test('should create Achievement from JSON', () {
      final achievement = Achievement.fromJson({
        'id': 'first_catch',
        'icon': '🦎',
        'title': 'First Catch',
        'description': 'Spotted your first monitor',
        'descriptionTh': 'พบวารานัสตัวแรก',
        'requiredCount': 1,
        'unlocked': true,
        'unlockedAt': '2026-03-25T10:00:00.000Z',
      });

      expect(achievement.id, 'first_catch');
      expect(achievement.icon, '🦎');
      expect(achievement.unlocked, true);
      expect(achievement.requiredCount, 1);
    });

    test('unlocked should default to false', () {
      final achievement = Achievement.fromJson({
        'id': 'park_explorer',
        'icon': '🗺️',
        'title': 'Park Explorer',
        'description': 'Visit 5 different parks',
        'descriptionTh': 'เยี่ยมชม 5 สวน',
        'requiredCount': 5,
      });

      expect(achievement.unlocked, false);
      expect(achievement.unlockedAt, isNull);
    });
  });
}
