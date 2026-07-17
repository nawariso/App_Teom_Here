import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { Timestamp, doc, setDoc } from 'firebase/firestore';
import {
  deleteObject,
  getBytes,
  ref,
  uploadBytes,
} from 'firebase/storage';
import { afterAll, afterEach, beforeAll, describe, test } from 'vitest';

const projectId = 'toem-here-test';
let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({ projectId });
});

afterEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
});

afterAll(async () => {
  await env.cleanup();
});

const image = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
const metadata = (ownerId = 'alice', sightingId = 'sighting-1') => ({
  contentType: 'image/jpeg',
  customMetadata: { ownerId, sightingId },
});

async function uploadAs(uid, path, fileMetadata = metadata(uid)) {
  const storage = env.authenticatedContext(uid).storage();
  return uploadBytes(ref(storage, path), image, fileMetadata);
}

async function seedApprovedSighting(uid = 'alice', sightingId = 'sighting-1') {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), `sightings/${sightingId}`), {
      userId: uid,
      storagePath: `sightings/${uid}/${sightingId}/photo.jpg`,
      moderationStatus: 'approved',
      createdAt: Timestamp.now(),
    });
  });
}

describe('sighting photos', () => {
  test('owner can upload a small image with path-bound metadata', async () => {
    await assertSucceeds(
      uploadAs(
        'alice',
        'sightings/alice/sighting-1/photo.jpg',
        metadata('alice', 'sighting-1'),
      ),
    );
  });

  test('rejects cross-owner paths and missing or mismatched metadata', async () => {
    await assertFails(
      uploadAs(
        'alice',
        'sightings/bob/sighting-1/photo.jpg',
        metadata('alice', 'sighting-1'),
      ),
    );
    await assertFails(
      uploadAs('alice', 'sightings/alice/sighting-1/photo.jpg', {
        contentType: 'image/jpeg',
      }),
    );
    await assertFails(
      uploadAs(
        'alice',
        'sightings/alice/sighting-1/photo.jpg',
        metadata('alice', 'another-sighting'),
      ),
    );
  });

  test('rejects non-image content', async () => {
    await assertFails(
      uploadAs('alice', 'sightings/alice/sighting-1/photo.jpg', {
        ...metadata('alice', 'sighting-1'),
        contentType: 'text/plain',
      }),
    );
  });

  test('owner can delete an upload to clean up a failed submission', async () => {
    await uploadAs(
      'alice',
      'sightings/alice/sighting-1/photo.jpg',
      metadata('alice', 'sighting-1'),
    );
    const storage = env.authenticatedContext('alice').storage();

    await assertSucceeds(
      deleteObject(ref(storage, 'sightings/alice/sighting-1/photo.jpg')),
    );
  });

  test('pending photos remain private', async () => {
    await uploadAs(
      'alice',
      'sightings/alice/sighting-1/photo.jpg',
      metadata('alice', 'sighting-1'),
    );
    const anonymous = env.unauthenticatedContext().storage();

    await assertFails(
      getBytes(ref(anonymous, 'sightings/alice/sighting-1/photo.jpg')),
    );
  });

  test('an approved path-bound photo is public', async () => {
    await seedApprovedSighting();
    await uploadAs(
      'alice',
      'sightings/alice/sighting-1/photo.jpg',
      metadata('alice', 'sighting-1'),
    );
    const anonymous = env.unauthenticatedContext().storage();

    await assertSucceeds(
      getBytes(ref(anonymous, 'sightings/alice/sighting-1/photo.jpg')),
    );
  });

  test('an approved document cannot expose a differently bound path', async () => {
    await seedApprovedSighting('mallory', 'sighting-1');
    await uploadAs(
      'alice',
      'sightings/alice/sighting-1/photo.jpg',
      metadata('alice', 'sighting-1'),
    );
    const anonymous = env.unauthenticatedContext().storage();

    await assertFails(
      getBytes(ref(anonymous, 'sightings/alice/sighting-1/photo.jpg')),
    );
  });
});
