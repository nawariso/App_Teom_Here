import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String displayName,
    String? email,
    String? photoUrl,
    @Default(1) int level,
    @Default(0) int totalCollected,
    @Default(0) int totalPhotos,
    @Default(0) int parksVisited,
    @Default(0) int xp,
    @Default([]) List<String> achievements,
    @Default([]) List<String> collectedMonitorIds,
    DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser.fromJson({
      'uid': doc.id,
      ...data,
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }
}

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String icon,
    required String title,
    required String description,
    required String descriptionTh,
    required int requiredCount,
    @Default(false) bool unlocked,
    DateTime? unlockedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}
