import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/models/monitor.dart';

final monitorRepositoryProvider = Provider<MonitorRepository>((ref) {
  throw StateError(
    'monitorRepositoryProvider must be overridden during application bootstrap.',
  );
});

class MonitorRepository {
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
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final AssetBundle? _assetBundle;

  bool get _isDemo => _assetBundle != null;

  CollectionReference get _monitorsRef =>
      _firestore!.collection(AppConstants.monitorsCollection);
  CollectionReference get _sightingsRef =>
      _firestore!.collection(AppConstants.sightingsCollection);

  Stream<List<Monitor>> watchMonitorsByVotes() {
    if (_isDemo) {
      return Stream.fromFuture(_loadDemoMonitors()).map((monitors) {
        return [...monitors]..sort((a, b) => b.votes.compareTo(a.votes));
      });
    }

    return _publicMonitorsQuery
        .orderBy('votes', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Monitor.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Monitor>> watchMonitorsByPark(String parkId) {
    if (_isDemo) {
      return Stream.fromFuture(_loadDemoMonitors()).map((monitors) {
        return monitors.where((monitor) => monitor.parkId == parkId).toList();
      });
    }

    return _publicMonitorsQuery
        .where('parkId', isEqualTo: parkId)
        .snapshots()
        .map(
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

    throw UnsupportedError('Creating monitors requires admin tooling.');
  }

  Future<void> vote(String monitorId, String userId) async {
    if (_isDemo) {
      return;
    }

    final voteRef =
        _monitorsRef.doc(monitorId).collection('voters').doc(userId);
    final voteDoc = await voteRef.get();

    if (voteDoc.exists) {
      await voteRef.delete();
      return;
    }

    await voteRef.set({
      'votedAt': FieldValue.serverTimestamp(),
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
    String? monitorId,
    required bool submittedAsUnknown,
    required String userId,
    required File photo,
    required double latitude,
    required double longitude,
    required String parkId,
    required String parkName,
    String? notes,
  }) async {
    if (_isDemo) {
      throw UnsupportedError('Reporting sightings requires Firebase setup.');
    }

    final sightingRef = _sightingsRef.doc();
    final storagePath = 'sightings/$userId/${sightingRef.id}/photo.jpg';
    final upload = await _uploadPhoto(
      storagePath: storagePath,
      photo: photo,
      userId: userId,
      sightingId: sightingRef.id,
    );

    try {
      await sightingRef.set({
        'schemaVersion': 1,
        'monitorId': monitorId,
        'submittedAsUnknown': submittedAsUnknown,
        'userId': userId,
        'photoUrl': upload.url,
        'storagePath': storagePath,
        'latitude': latitude,
        'longitude': longitude,
        'parkId': parkId,
        'parkName': parkName,
        'notes': notes,
        'moderationStatus': 'pending',
        'rejectionReason': null,
        'spottedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error, stackTrace) {
      try {
        await upload.reference.delete();
      } on FirebaseException {
        // Preserve the original Firestore error. A scheduled cleanup job can
        // remove the object if this best-effort deletion also fails.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
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
        .where('moderationStatus', isEqualTo: 'approved')
        .orderBy('spottedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(MonitorSighting.fromFirestore).toList(),
        );
  }

  Future<Map<String, int>> getParkMonitorCounts() async {
    if (_isDemo) {
      final monitors = await _loadDemoMonitors();
      final counts = <String, int>{};
      for (final monitor in monitors) {
        counts[monitor.parkId] = (counts[monitor.parkId] ?? 0) + 1;
      }
      return counts;
    }

    final snapshot = await _publicMonitorsQuery.get();
    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final parkId = (doc.data() as Map<String, dynamic>)['parkId'] as String;
      counts[parkId] = (counts[parkId] ?? 0) + 1;
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

  Query get _publicMonitorsQuery =>
      _monitorsRef.where('moderationStatus', isEqualTo: 'approved');

  Future<({Reference reference, String url})> _uploadPhoto({
    required String storagePath,
    required File photo,
    required String userId,
    required String sightingId,
  }) async {
    final photoRef = _storage!.ref().child(storagePath);
    await photoRef.putFile(
      photo,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'ownerId': userId,
          'sightingId': sightingId,
        },
      ),
    );
    return (reference: photoRef, url: await photoRef.getDownloadURL());
  }
}
