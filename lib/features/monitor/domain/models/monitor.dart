import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monitor.freezed.dart';
part 'monitor.g.dart';

enum MonitorRarity {
  common,
  rare,
  epic,
  legendary,
}

@freezed
class Monitor with _$Monitor {
  const factory Monitor({
    required String id,
    required String name,
    required String nickname,
    String? photoUrl,
    required String parkName,
    required String parkNameEn,
    required double latitude,
    required double longitude,
    required int votes,
    required String size,
    required String personality,
    required String personalityEn,
    required String badge,
    required MonitorRarity rarity,
    @Default(0) int sightingStreak,
    required DateTime lastSeenAt,
    required String lastSeenBy,
    @Default([]) List<String> photoGallery,
    @Default([]) List<String> tags,
    DateTime? createdAt,
  }) = _Monitor;

  factory Monitor.fromJson(Map<String, dynamic> json) =>
      _$MonitorFromJson(json);

  factory Monitor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Monitor.fromJson({
      'id': doc.id,
      ...data,
      'lastSeenAt': (data['lastSeenAt'] as Timestamp).toDate().toIso8601String(),
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }
}

@freezed
class MonitorSighting with _$MonitorSighting {
  const factory MonitorSighting({
    required String id,
    required String monitorId,
    required String userId,
    required String photoUrl,
    required double latitude,
    required double longitude,
    required String parkName,
    String? notes,
    required DateTime spottedAt,
  }) = _MonitorSighting;

  factory MonitorSighting.fromJson(Map<String, dynamic> json) =>
      _$MonitorSightingFromJson(json);
}

@freezed
class UserCollection with _$UserCollection {
  const factory UserCollection({
    required String monitorId,
    required String photoUrl,
    required DateTime collectedAt,
    required String location,
  }) = _UserCollection;

  factory UserCollection.fromJson(Map<String, dynamic> json) =>
      _$UserCollectionFromJson(json);
}
