import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized.putIfAbsent(
    'totalSightings',
    () => normalized['totalPhotos'] ?? 0,
  );
  normalized.putIfAbsent(
    'achievementIds',
    () => normalized['achievements'] ?? const <String>[],
  );
  return normalized;
}

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    @JsonKey(includeToJson: false) required String uid,
    required String displayName,
    @JsonKey(includeToJson: false) String? email,
    String? photoUrl,
    @Default(1) int schemaVersion,
    @Default(1) int level,
    @Default(0) int totalCollected,
    @Default(0) int totalSightings,
    @Default(0) int parksVisited,
    @Default(0) int xp,
    @Default([]) List<String> achievementIds,
    @Default([]) List<String> favoriteMonitorIds,
    @Default([]) List<String> collectedMonitorIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AppUser;

  const AppUser._();

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(_normalizeUserJson(json));

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser.fromJson({
      'uid': doc.id,
      ...data,
      'createdAt': _timestampToIsoString(data['createdAt']),
      'updatedAt': _timestampToIsoString(data['updatedAt']),
    });
  }

  @Deprecated('Use totalSightings.')
  int get totalPhotos => totalSightings;

  @Deprecated('Use achievementIds.')
  List<String> get achievements => achievementIds;
}

String? _timestampToIsoString(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is String) return value;
  throw FormatException('Expected a timestamp-compatible value, got $value.');
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
