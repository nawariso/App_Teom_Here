import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:toem_here/features/monitor/data/monitor_repository.dart';

// Run after editing:
//   dart run build_runner build --delete-conflicting-outputs
// This generates test/helpers/test_helpers.mocks.dart

@GenerateMocks(
  [MonitorRepository, FirebaseFirestore, FirebaseStorage],
  customMocks: [
    MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockCollectionReference,
    ),
    MockSpec<DocumentReference<Map<String, dynamic>>>(
      as: #MockDocumentReference,
    ),
    MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
      as: #MockDocumentSnapshot,
    ),
    MockSpec<QuerySnapshot<Map<String, dynamic>>>(
      as: #MockQuerySnapshot,
    ),
    MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
      as: #MockQueryDocumentSnapshot,
    ),
    MockSpec<Query<Map<String, dynamic>>>(as: #MockQuery),
    MockSpec<Transaction>(as: #MockTransaction),
  ],
)
void main() {}
