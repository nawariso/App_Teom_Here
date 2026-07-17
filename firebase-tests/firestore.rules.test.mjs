import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { afterAll, afterEach, beforeAll, describe, test } from 'vitest';

const projectId = 'toem-here-test';
let env;

const publicProfile = (overrides = {}) => ({
  schemaVersion: 1,
  displayName: 'Mickey',
  photoUrl: null,
  level: 1,
  totalCollected: 0,
  totalSightings: 0,
  parksVisited: 0,
  xp: 0,
  achievementIds: [],
  favoriteMonitorIds: [],
  collectedMonitorIds: [],
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...overrides,
});

const pendingSighting = (uid, overrides = {}) => ({
  schemaVersion: 1,
  monitorId: 'monitor-1',
  submittedAsUnknown: false,
  userId: uid,
  photoUrl: `https://firebasestorage.googleapis.com/v0/b/toem-here-test.appspot.com/o/sightings%2F${uid}%2Fsighting-1%2Fphoto.jpg?alt=media&token=test_token`,
  storagePath: `sightings/${uid}/sighting-1/photo.jpg`,
  latitude: 13.7308,
  longitude: 100.5412,
  parkId: 'lumpini',
  parkName: 'Lumpini Park',
  notes: null,
  moderationStatus: 'pending',
  rejectionReason: null,
  spottedAt: serverTimestamp(),
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...overrides,
});

beforeAll(async () => {
  env = await initializeTestEnvironment({ projectId });
});

afterEach(async () => {
  await env.clearFirestore();
});

afterAll(async () => {
  await env.cleanup();
});

async function seed(path, data) {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

async function seedSightingReferences() {
  await seed('monitors/monitor-1', {
    moderationStatus: 'approved',
    votes: 0,
  });
  await seed('parks/lumpini', {
    active: true,
    name: 'Lumpini Park',
  });
}

describe('public user profiles', () => {
  test('owner can create only the canonical zero-progress profile', async () => {
    const db = env.authenticatedContext('alice').firestore();

    await assertSucceeds(setDoc(doc(db, 'users/alice'), publicProfile()));
    await assertFails(
      setDoc(doc(db, 'users/alice-forged'), publicProfile()),
    );
  });

  test('client cannot forge progression or add private fields', async () => {
    const db = env.authenticatedContext('alice').firestore();

    await assertFails(
      setDoc(doc(db, 'users/alice'), publicProfile({ xp: 5000, level: 20 })),
    );
    await assertFails(
      setDoc(
        doc(db, 'users/alice'),
        publicProfile({ email: 'private@example.com' }),
      ),
    );
  });

  test('client cannot forge profile timestamps', async () => {
    const db = env.authenticatedContext('alice').firestore();
    const forged = Timestamp.fromMillis(1);

    await assertFails(
      setDoc(doc(db, 'users/alice'), publicProfile({ createdAt: forged })),
    );
    await seed('users/alice', publicProfile());
    await assertFails(
      updateDoc(doc(db, 'users/alice'), {
        displayName: 'Forged time',
        updatedAt: forged,
      }),
    );
  });

  test('owner can edit display fields but not progression', async () => {
    await seed('users/alice', publicProfile());
    const db = env.authenticatedContext('alice').firestore();

    await assertSucceeds(
      updateDoc(doc(db, 'users/alice'), {
        displayName: 'New Name',
        updatedAt: serverTimestamp(),
      }),
    );
    await assertFails(updateDoc(doc(db, 'users/alice'), { xp: 1 }));
    await assertFails(deleteDoc(doc(db, 'users/alice')));
  });
});

describe('sightings', () => {
  test('owner can submit a canonical pending sighting', async () => {
    await seedSightingReferences();
    const db = env.authenticatedContext('alice').firestore();

    await assertSucceeds(
      setDoc(doc(db, 'sightings/sighting-1'), pendingSighting('alice')),
    );
  });

  test('rejects spoofed owners, invalid coordinates, and mismatched storage paths', async () => {
    await seedSightingReferences();
    const db = env.authenticatedContext('alice').firestore();

    await assertFails(
      setDoc(doc(db, 'sightings/sighting-1'), pendingSighting('mallory')),
    );
    await assertFails(
      setDoc(
        doc(db, 'sightings/sighting-1'),
        pendingSighting('alice', { latitude: 100 }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'sightings/sighting-1'),
        pendingSighting('alice', {
          storagePath: 'sightings/alice/another-id/photo.jpg',
        }),
      ),
    );
  });

  test('enforces known versus unknown monitor invariants', async () => {
    await seed('parks/lumpini', { active: true, name: 'Lumpini Park' });
    const db = env.authenticatedContext('alice').firestore();

    await assertFails(
      setDoc(
        doc(db, 'sightings/sighting-1'),
        pendingSighting('alice', { monitorId: null, submittedAsUnknown: false }),
      ),
    );
    await assertFails(
      setDoc(
        doc(db, 'sightings/sighting-1'),
        pendingSighting('alice', {
          monitorId: 'monitor-1',
          submittedAsUnknown: true,
        }),
      ),
    );
    await assertSucceeds(
      setDoc(
        doc(db, 'sightings/sighting-1'),
        pendingSighting('alice', {
          monitorId: null,
          submittedAsUnknown: true,
        }),
      ),
    );
  });

  test('pending sightings are private to their owner', async () => {
    await seed('sightings/sighting-1', pendingSighting('alice'));

    await assertSucceeds(
      getDoc(doc(env.authenticatedContext('alice').firestore(), 'sightings/sighting-1')),
    );
    await assertFails(
      getDoc(doc(env.authenticatedContext('bob').firestore(), 'sightings/sighting-1')),
    );
    await assertFails(
      getDoc(doc(env.unauthenticatedContext().firestore(), 'sightings/sighting-1')),
    );
  });
});

describe('votes', () => {
  test('authenticated user can vote once only on an existing approved monitor', async () => {
    await seed('monitors/monitor-1', { moderationStatus: 'approved', votes: 0 });
    const db = env.authenticatedContext('alice').firestore();
    const vote = doc(db, 'monitors/monitor-1/voters/alice');

    await assertSucceeds(setDoc(vote, { votedAt: serverTimestamp() }));
    await assertFails(setDoc(vote, { votedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(vote));
    await assertFails(
      setDoc(doc(db, 'monitors/missing/voters/alice'), {
        votedAt: serverTimestamp(),
      }),
    );
  });
});
