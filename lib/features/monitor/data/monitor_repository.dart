import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/monitor.dart';

final monitorRepositoryProvider = Provider<MonitorRepository>((ref) {
  if (Firebase.apps.isEmpty) {
    return MonitorRepository.demo(assetBundle: rootBundle);
  }

  return MonitorRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

class MonitorRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final AssetBundle? _assetBundle;

  MonitorRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage,
        _assetBundle = null;

  MonitorRepository.demo({
    required AssetBundle assetBundle,
  })  : _firestore = null,
        _storage = null,
        _assetBundle = assetBundle;

  bool get _isDemo => _assetBundle != null;

  CollectionReference get _monitorsRef => _firestore!.collection('monitors');
  CollectionReference get _sightingsRef => _firestore!.collection('sightings');

  Stream<List<Monitor>> watchMonitorsByVotes() {
    if (_isDemo) {
      return Stream.fromFuture(_loadDemoMonitors()).map((monitors) {
        return [...monitors]..sort((a, b) => b.votes.compareTo(a.votes));
      });
    }

    return _monitorsRef.orderBy('votes', descending: true).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Monitor.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Monitor>> watchMonitorsByPark(String parkName) {
    if (_isDemo) {
      return Stream.fromFuture(_loadDemoMonitors()).map((monitors) {
        return monitors
            .where((monitor) => monitor.parkName == parkName)
            .toList();
      });
    }

    return _monitorsRef.where('parkName', isEqualTo: parkName).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Monitor.fromFirestore(doc)).toList(),
        );
  }

  Future<Monitor?> getMonitor(String id) async {
    if (_isDemo) {
      final monitors = await _loadDemoMonitors();
      for (final monitor in monitors) {
        if (monitor.id == id) return monitor;
      }
      return null;
    }

    final doc = await _monitorsRef.doc(id).get();
    if (!doc.exists) return null;
    return Monitor.fromFirestore(doc);
  }

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
    if (_isDemo) {
      throw UnsupportedError('Creating monitors requires Firebase setup.');
    }

    final photoRef = _storage!
        .ref()
        .child('monitors')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await photoRef.putFile(photo);
    final photoUrl = await photoRef.getDownloadURL();

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
      'tags': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> vote(String monitorId, String userId) async {
    if (_isDemo) {
      return;
    }

    final voteRef =
        _monitorsRef.doc(monitorId).collection('voters').doc(userId);

    final voteDoc = await voteRef.get();

    await _firestore!.runTransaction((transaction) async {
      if (voteDoc.exists) {
        transaction.delete(voteRef);
        transaction.update(_monitorsRef.doc(monitorId), {
          'votes': FieldValue.increment(-1),
        });
      } else {
        transaction.set(voteRef, {
          'votedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(_monitorsRef.doc(monitorId), {
          'votes': FieldValue.increment(1),
        });
      }
    });
  }

  Future<bool> hasVoted(String monitorId, String userId) async {
    if (_isDemo) {
      return false;
    }

    final doc = await _monitorsRef
        .doc(monitorId)
        .collection('voters')
        .doc(userId)
        .get();
    return doc.exists;
  }

  Future<void> reportSighting({
    required String monitorId,
    required String userId,
    required File photo,
    required double latitude,
    required double longitude,
    required String parkName,
    String? notes,
  }) async {
    if (_isDemo) {
      throw UnsupportedError('Reporting sightings requires Firebase setup.');
    }

    final photoRef = _storage!
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

    await _monitorsRef.doc(monitorId).update({
      'lastSeenAt': FieldValue.serverTimestamp(),
      'lastSeenBy': userId,
      'latitude': latitude,
      'longitude': longitude,
      'photoGallery': FieldValue.arrayUnion([photoUrl]),
    });
  }

  Stream<List<MonitorSighting>> watchRecentSightings({int limit = 20}) {
    if (_isDemo) {
      return Stream.fromFuture(_loadDemoSightings()).map((sightings) {
        return ([...sightings]
              ..sort((a, b) => b.spottedAt.compareTo(a.spottedAt)))
            .take(limit)
            .toList();
      });
    }

    return _sightingsRef
        .orderBy('spottedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return MonitorSighting.fromJson({
              'id': doc.id,
              ...data,
              'spottedAt':
                  (data['spottedAt'] as Timestamp).toDate().toIso8601String(),
            });
          }).toList(),
        );
  }

  Future<Map<String, int>> getParkMonitorCounts() async {
    if (_isDemo) {
      final monitors = await _loadDemoMonitors();
      final counts = <String, int>{};
      for (final monitor in monitors) {
        counts[monitor.parkName] = (counts[monitor.parkName] ?? 0) + 1;
      }
      return counts;
    }

    final snapshot = await _monitorsRef.get();
    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final park = (doc.data() as Map<String, dynamic>)['parkName'] as String;
      counts[park] = (counts[park] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<Monitor>> _loadDemoMonitors() async {
    final records = await _loadDemoRecords('assets/data/demo_monitors.json');
    return records.map(Monitor.fromJson).toList();
  }

  Future<List<MonitorSighting>> _loadDemoSightings() async {
    final records = await _loadDemoRecords('assets/data/demo_sightings.json');
    return records.map(MonitorSighting.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _loadDemoRecords(String path) async {
    final rawJson = await _assetBundle!.loadString(path);
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  String _getBadgeForRarity(MonitorRarity rarity) {
    switch (rarity) {
      case MonitorRarity.common:
        return 'C';
      case MonitorRarity.rare:
        return 'R';
      case MonitorRarity.epic:
        return 'E';
      case MonitorRarity.legendary:
        return 'L';
    }
  }
}
