import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw StateError(
    'authRepositoryProvider must be overridden during application bootstrap.',
  );
});

abstract class AuthRepository {
  Stream<AppUser?> watchCurrentUser();

  Future<AppUser> signInAnonymously();

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _ensureUserProfile(user);
    });
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase returned no user after anonymous sign-in.');
    }

    return _ensureUserProfile(user);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<AppUser> _ensureUserProfile(firebase_auth.User firebaseUser) {
    final docRef = _usersRef.doc(firebaseUser.uid);
    return _firestore.runTransaction<AppUser>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        return AppUser.fromFirestore(snapshot);
      }

      final user = AppUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : 'Park Explorer',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );

      transaction.set(docRef, {
        'schemaVersion': user.schemaVersion,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'level': user.level,
        'totalCollected': user.totalCollected,
        'totalSightings': user.totalSightings,
        'parksVisited': user.parksVisited,
        'xp': user.xp,
        'achievementIds': user.achievementIds,
        'favoriteMonitorIds': user.favoriteMonitorIds,
        'collectedMonitorIds': user.collectedMonitorIds,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    });
  }
}

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final user = AppUser(
      uid: 'demo-user',
      displayName: 'Demo Explorer',
      email: 'demo@toem-here.local',
      level: 3,
      totalCollected: 3,
      totalSightings: 5,
      parksVisited: 2,
      xp: 320,
      achievementIds: const ['first_sighting', 'park_explorer'],
      collectedMonitorIds: const [
        'lumpini-uncle-somchai',
        'benjakitti-mango',
        'chatuchak-banana',
      ],
      createdAt: DateTime(2026, 1, 1),
    );

    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
