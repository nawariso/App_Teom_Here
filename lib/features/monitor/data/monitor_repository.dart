import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/monitor.dart';

final monitorRepositoryProvider = Provider<MonitorRepository>((ref) {
  return MonitorRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

class MonitorRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MonitorRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference get _monitorsRef => _firestore.collection('monitors');
  CollectionReference get _sightingsRef => _firestore.collection('sightings');

  // ─── Fetch all monitors sorted by votes ───
  Stream<List<Monitor>> watchMonitorsByVotes() {
    return _monitorsRef
        .orderBy('votes', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Monitor.fromFirestore(doc))
            .toList());
  }

  // ─── Fetch monitors by park ───
  Stream<List<Monitor>> watchMonitorsByPark(String parkName) {
    return _monitorsRef
        .where('parkName', isEqualTo: parkName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Monitor.fromFirestore(doc))
            .toList());
  }

  // ─── Get single monitor ───
  Future<Monitor?> getMonitor(String id) async {
    final doc = await _monitorsRef.doc(id).get();
    if (!doc.exists) return null;
    return Monitor.fromFirestore(doc);
  }

  // ─── Create new monitor ───
  Future<String> createMonitor({
    required String name,
    required String nickname,
    required File photo,
    required String parkName,
    required String parkNameEn,
    required double latitude,
    required double longitude,
    required String size,
    required String personality,
    required String personalityEn,
    required String userId,
    MonitorRarity rarity = MonitorRarity.common,
  }) async {
    // Upload photo
    final photoRef = _storage
        .ref()
        .child('monitors')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await photoRef.putFile(photo);
    final photoUrl = await photoRef.getDownloadURL();

    // Create document
    final docRef = await _monitorsRef.add({
      'name': name,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'parkName': parkName,
      'parkNameEn': parkNameEn,
      'latitude': latitude,
      'longitude': longitude,
      'votes': 0,
      'size': size,
      'personality': personality,
      'personalityEn': personalityEn,
      'badge': _getBadgeForRarity(rarity),
      'rarity': rarity.name,
      'sightingStreak': 1,
      'lastSeenAt': FieldValue.serverTimestamp(),
      'lastSeenBy': userId,
      'photoGallery': [photoUrl],
      'tags': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // ─── Vote for a monitor ───
  Future<void> vote(String monitorId, String userId) async {
    final voteRef = _monitorsRef
        .doc(monitorId)
        .collection('voters')
        .doc(userId);

    final voteDoc = await voteRef.get();

    await _firestore.runTransaction((transaction) async {
      if (voteDoc.exists) {
        // Remove vote
        transaction.delete(voteRef);
        transaction.update(_monitorsRef.doc(monitorId), {
          'votes': FieldValue.increment(-1),
        });
      } else {
        // Add vote
        transaction.set(voteRef, {
          'votedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(_monitorsRef.doc(monitorId), {
          'votes': FieldValue.increment(1),
        });
      }
    });
  }

  // ─── Check if user voted ───
  Future<bool> hasVoted(String monitorId, String userId) async {
    final doc = await _monitorsRef
        .doc(monitorId)
        .collection('voters')
        .doc(userId)
        .get();
    return doc.exists;
  }

  // ─── Report sighting ───
  Future<void> reportSighting({
    required String monitorId,
    required String userId,
    required File photo,
    required double latitude,
    required double longitude,
    required String parkName,
    String? notes,
  }) async {
    final photoRef = _storage
        .ref()
        .child('sightings')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await photoRef.putFile(photo);
    final photoUrl = await photoRef.getDownloadURL();

    await _sightingsRef.add({
      'monitorId': monitorId,
      'userId': userId,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'parkName': parkName,
      'notes': notes,
      'spottedAt': FieldValue.serverTimestamp(),
    });

    // Update monitor's last seen
    await _monitorsRef.doc(monitorId).update({
      'lastSeenAt': FieldValue.serverTimestamp(),
      'lastSeenBy': userId,
      'latitude': latitude,
      'longitude': longitude,
      'photoGallery': FieldValue.arrayUnion([photoUrl]),
    });
  }

  // ─── Get recent sightings ───
  Stream<List<MonitorSighting>> watchRecentSightings({int limit = 20}) {
    return _sightingsRef
        .orderBy('spottedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return MonitorSighting.fromJson({
                'id': doc.id,
                ...data,
                'spottedAt':
                    (data['spottedAt'] as Timestamp).toDate().toIso8601String(),
              });
            }).toList());
  }

  // ─── Park statistics ───
  Future<Map<String, int>> getParkMonitorCounts() async {
    final snapshot = await _monitorsRef.get();
    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final park = (doc.data() as Map<String, dynamic>)['parkName'] as String;
      counts[park] = (counts[park] ?? 0) + 1;
    }
    return counts;
  }

  String _getBadgeForRarity(MonitorRarity rarity) {
    switch (rarity) {
      case MonitorRarity.common:
        return '🦎';
      case MonitorRarity.rare:
        return '🌟';
      case MonitorRarity.epic:
        return '💪';
      case MonitorRarity.legendary:
        return '👑';
    }
  }
}
