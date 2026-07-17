import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monitor.freezed.dart';
part 'monitor.g.dart';

enum MonitorRarity { common, rare, epic, legendary }

enum ModerationStatus { pending, approved, rejected, hidden }

Map<String, dynamic> _normalizeMonitorJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized.putIfAbsent(
    'sightingCount',
    () => normalized['sightingStreak'] ?? 0,
  );
  return normalized;
}

String? _timestampToIsoString(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is String) return value;
  throw FormatException('Expected a timestamp-compatible value, got $value.');
}

@freezed
class Monitor with _$Monitor {
  const factory Monitor({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    required String nickname,
    String? photoUrl,
    @Default(1) int schemaVersion,
    @Default('') String parkId,
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
    @Default(0) int sightingCount,
    DateTime? lastSeenAt,
    String? lastSeenBy,
    @Default([]) List<String> photoGallery,
    @Default([]) List<String> tags,
    @Default(ModerationStatus.approved) ModerationStatus moderationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Monitor;

  const Monitor._();

  factory Monitor.fromJson(Map<String, dynamic> json) =>
      _$MonitorFromJson(_normalizeMonitorJson(json));

  factory Monitor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Monitor.fromJson({
      'id': doc.id,
      ...data,
      'lastSeenAt': _timestampToIsoString(data['lastSeenAt']),
      'createdAt': _timestampToIsoString(data['createdAt']),
      'updatedAt': _timestampToIsoString(data['updatedAt']),
    });
  }

  @Deprecated('Use sightingCount.')
  int get sightingStreak => sightingCount;
}

@freezed
class MonitorSighting with _$MonitorSighting {
  const factory MonitorSighting({
    @JsonKey(includeToJson: false) required String id,
    @Default(1) int schemaVersion,
    String? monitorId,
    @Default(false) bool submittedAsUnknown,
    required String userId,
    required String photoUrl,
    @Default('') String storagePath,
    @Default('') String parkId,
    required double latitude,
    required double longitude,
    required String parkName,
    String? notes,
    @Default(ModerationStatus.approved) ModerationStatus moderationStatus,
    String? rejectionReason,
    required DateTime spottedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MonitorSighting;

  factory MonitorSighting.fromJson(Map<String, dynamic> json) =>
      _$MonitorSightingFromJson(json);

  factory MonitorSighting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonitorSighting.fromJson({
      'id': doc.id,
      ...data,
      'spottedAt': _timestampToIsoString(data['spottedAt']),
      'createdAt': _timestampToIsoString(data['createdAt']),
      'updatedAt': _timestampToIsoString(data['updatedAt']),
    });
  }
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
