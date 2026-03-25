import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/features/auth/domain/models/user.dart';

void main() {
  group('AppUser Model', () {
    test('should create AppUser from JSON', () {
      final json = {
        'uid': 'user-123',
        'displayName': 'Mickey',
        'email': 'mickey@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'level': 5,
        'totalCollected': 12,
        'totalPhotos': 30,
        'parksVisited': 4,
        'xp': 850,
        'achievements': ['first_catch', 'park_explorer'],
        'collectedMonitorIds': ['monitor-1', 'monitor-2'],
      };

      final user = AppUser.fromJson(json);

      expect(user.uid, 'user-123');
      expect(user.displayName, 'Mickey');
      expect(user.email, 'mickey@example.com');
      expect(user.level, 5);
      expect(user.totalCollected, 12);
      expect(user.xp, 850);
      expect(user.achievements, ['first_catch', 'park_explorer']);
      expect(user.collectedMonitorIds.length, 2);
    });

    test('should apply default values for new user', () {
      final json = {
        'uid': 'new-user',
        'displayName': 'New User',
      };

      final user = AppUser.fromJson(json);

      expect(user.level, 1);
      expect(user.totalCollected, 0);
      expect(user.totalPhotos, 0);
      expect(user.parksVisited, 0);
      expect(user.xp, 0);
      expect(user.achievements, isEmpty);
      expect(user.collectedMonitorIds, isEmpty);
    });

    test('copyWith should produce updated instance', () {
      final user = AppUser(uid: 'u1', displayName: 'Old Name', xp: 100);
      final updated = user.copyWith(displayName: 'New Name', xp: 200);

      expect(updated.uid, 'u1');
      expect(updated.displayName, 'New Name');
      expect(updated.xp, 200);
    });

    test('equality: two users with same data should be equal', () {
      final a = AppUser(uid: 'u1', displayName: 'Alice');
      final b = AppUser(uid: 'u1', displayName: 'Alice');

      expect(a, equals(b));
    });
  });

  group('Achievement Model', () {
    test('should create Achievement from JSON', () {
      final json = {
        'id': 'first_catch',
        'icon': '🦎',
        'title': 'First Catch',
        'description': 'Spotted your first monitor',
        'descriptionTh': 'พบวารานัสตัวแรก',
        'requiredCount': 1,
        'unlocked': true,
        'unlockedAt': '2026-03-25T10:00:00.000Z',
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.id, 'first_catch');
      expect(achievement.icon, '🦎');
      expect(achievement.unlocked, true);
      expect(achievement.requiredCount, 1);
    });

    test('unlocked should default to false', () {
      final json = {
        'id': 'park_explorer',
        'icon': '🗺️',
        'title': 'Park Explorer',
        'description': 'Visit 5 different parks',
        'descriptionTh': 'เยี่ยมชม 5 สวน',
        'requiredCount': 5,
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.unlocked, false);
      expect(achievement.unlockedAt, isNull);
    });
  });
}
