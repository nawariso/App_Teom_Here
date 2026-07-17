import { initializeApp } from "firebase-admin/app";
import {
  FieldValue,
  Timestamp,
  Transaction,
  getFirestore,
} from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import {
  onDocumentCreated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { setGlobalOptions } from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";

import {
  VoteEventKind,
  canonicalEventKey,
  isCanonicalFirebaseDownloadUrl,
  parseModerationRequest,
  requireDocumentId,
  requireStableParkId,
} from "./domain";

initializeApp();

setGlobalOptions({
  region: "asia-southeast1",
  maxInstances: 10,
});

const db = getFirestore();
const storageBucket = getStorage().bucket().name;

interface Sighting {
  monitorId?: string | null;
  submittedAsUnknown?: boolean;
  userId: string;
  photoUrl: string;
  storagePath: string;
  latitude: number;
  longitude: number;
  parkId: string;
  parkName: string;
  notes?: string | null;
  moderationStatus: "pending" | "approved" | "rejected";
  rejectionReason?: string | null;
  spottedAt?: Timestamp;
}

function requireModerator(
  auth: { token: Record<string, unknown> } | undefined,
): void {
  if (!auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to moderate sightings.",
    );
  }

  if (auth.token.admin !== true && auth.token.moderator !== true) {
    throw new HttpsError(
      "permission-denied",
      "Moderator privileges are required.",
    );
  }
}

export const onVoteCreated = onDocumentCreated(
  "monitors/{monitorId}/voters/{userId}",
  async (event) => {
    await reconcileVoteCount("vote-created", event.id, event.params.monitorId);
  },
);

export const onVoteDeleted = onDocumentDeleted(
  "monitors/{monitorId}/voters/{userId}",
  async (event) => {
    await reconcileVoteCount("vote-deleted", event.id, event.params.monitorId);
  },
);

async function reconcileVoteCount(
  kind: VoteEventKind,
  eventId: string,
  monitorId: string,
): Promise<void> {
  const eventKey = canonicalEventKey(kind, eventId);
  const eventRef = db.doc(`functionEvents/${eventKey}`);
  const monitorRef = db.doc(`monitors/${monitorId}`);

  const result = await db.runTransaction(async (transaction) => {
    const eventSnapshot = await transaction.get(eventRef);
    const monitorSnapshot = await transaction.get(monitorRef);
    const votersSnapshot = await transaction.get(
      db.collection(`monitors/${monitorId}/voters`),
    );

    if (eventSnapshot.exists) {
      return "duplicate";
    }
    if (!monitorSnapshot.exists) {
      return "missing-monitor";
    }

    const votes = votersSnapshot.size;
    transaction.update(monitorRef, {
      votes,
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.create(eventRef, {
      kind,
      eventId,
      monitorId,
      status: "reconciled",
      votes,
      processedAt: FieldValue.serverTimestamp(),
    });
    return "reconciled";
  });

  logger.info("Vote event handled", { eventId, kind, monitorId, result });
}

export const onSightingCreated = onDocumentCreated(
  "sightings/{sightingId}",
  async (event) => {
    if (!event.data) {
      logger.warn("Sighting create trigger had no snapshot", event.params);
      return;
    }

    const sightingId = event.params.sightingId;
    const sightingRef = db.doc(`sightings/${sightingId}`);
    const queueRef = db.doc(`moderationQueue/${sightingId}`);
    const result = await db.runTransaction(async (transaction) => {
      const currentSightingSnapshot = await transaction.get(sightingRef);
      const queueSnapshot = await transaction.get(queueRef);
      if (!currentSightingSnapshot.exists) {
        return "missing-sighting";
      }
      if (queueSnapshot.exists) {
        return "queue-exists";
      }

      const sighting = currentSightingSnapshot.data() as Sighting;
      if (sighting.moderationStatus !== "pending") {
        return "not-pending";
      }
      const expectedStoragePath =
        `sightings/${sighting.userId}/${sightingId}/photo.jpg`;
      if (
        sighting.storagePath !== expectedStoragePath ||
        !isCanonicalFirebaseDownloadUrl(
          sighting.photoUrl,
          storageBucket,
          expectedStoragePath,
        )
      ) {
        logger.warn("Sighting has a non-canonical photo binding", {
          sightingId,
        });
        return "invalid-photo-binding";
      }

      transaction.create(queueRef, {
        sightingId,
        monitorId: sighting.monitorId ?? null,
        userId: sighting.userId,
        photoUrl: sighting.photoUrl,
        parkName: sighting.parkName,
        status: "open",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      return "queued";
    });

    logger.info("Sighting create event handled", { sightingId, result });
  },
);

export const moderateSighting = onCall(async (request) => {
  requireModerator(request.auth);

  let payload;
  try {
    payload = parseModerationRequest(request.data);
  } catch (error) {
    throw new HttpsError(
      "invalid-argument",
      error instanceof Error ? error.message : "Invalid moderation request.",
    );
  }

  const result = await db.runTransaction(async (transaction) => {
    const sightingRef = db.doc(`sightings/${payload.sightingId}`);
    const sightingSnapshot = await transaction.get(sightingRef);

    if (!sightingSnapshot.exists) {
      throw new HttpsError("not-found", "Sighting was not found.");
    }

    const sighting = sightingSnapshot.data() as Sighting;
    if (sighting.moderationStatus === payload.status) {
      return {
        sightingId: payload.sightingId,
        status: payload.status,
        changed: false,
      };
    }
    if (sighting.moderationStatus !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Only pending sightings can be moderated.",
      );
    }

    let hasCollectedMonitor = false;
    let parkId: string | undefined;
    let parkName: string | undefined;
    let isFirstParkVisit = false;

    if (payload.status === "approved") {
      let userId: string;
      try {
        userId = requireDocumentId(sighting.userId, "userId");
        parkId = requireStableParkId(sighting.parkId);
      } catch {
        throw new HttpsError(
          "failed-precondition",
          "The sighting owner or park ID is invalid.",
        );
      }

      const userSnapshot = await transaction.get(db.doc(`users/${userId}`));
      if (!userSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "The sighting owner profile does not exist.",
        );
      }

      if (sighting.monitorId) {
        try {
          requireDocumentId(sighting.monitorId, "monitorId");
        } catch {
          throw new HttpsError(
            "failed-precondition",
            "The sighting monitor ID is invalid.",
          );
        }
        const monitorSnapshot = await transaction.get(
          db.doc(`monitors/${sighting.monitorId}`),
        );
        if (
          !monitorSnapshot.exists ||
          monitorSnapshot.data()?.moderationStatus !== "approved"
        ) {
          throw new HttpsError(
            "failed-precondition",
            "The sighting monitor is not approved.",
          );
        }
      }

      const parkSnapshot = await transaction.get(db.doc(`parks/${parkId}`));
      const canonicalParkName = parkSnapshot.data()?.name;
      if (
        !parkSnapshot.exists ||
        parkSnapshot.data()?.active !== true ||
        typeof canonicalParkName !== "string" ||
        canonicalParkName.trim().length < 1
      ) {
        throw new HttpsError(
          "failed-precondition",
          "The sighting park is not active.",
        );
      }
      parkName = canonicalParkName.trim();

      const expectedStoragePath =
        `sightings/${userId}/${payload.sightingId}/photo.jpg`;
      if (
        sighting.storagePath !== expectedStoragePath ||
        !isCanonicalFirebaseDownloadUrl(
          sighting.photoUrl,
          storageBucket,
          expectedStoragePath,
        )
      ) {
        throw new HttpsError(
          "failed-precondition",
          "The sighting photo does not match its canonical storage object.",
        );
      }

      const visitedParkSnapshot = await transaction.get(
        db.doc(`users/${userId}/visitedParks/${parkId}`),
      );
      isFirstParkVisit = !visitedParkSnapshot.exists;

      const collectedMonitorIds =
        userSnapshot.data()?.collectedMonitorIds as unknown[] | undefined;
      hasCollectedMonitor =
        typeof sighting.monitorId === "string" &&
        collectedMonitorIds?.includes(sighting.monitorId) === true;
    }

    const updatedAt = FieldValue.serverTimestamp();
    transaction.update(sightingRef, {
      moderationStatus: payload.status,
      rejectionReason:
        payload.status === "rejected" ? payload.rejectionReason ?? null : null,
      ...(payload.status === "approved" ? { parkId, parkName } : {}),
      updatedAt,
    });
    transaction.set(
      db.doc(`moderationQueue/${payload.sightingId}`),
      {
        status: payload.status,
        rejectionReason:
          payload.status === "rejected"
            ? payload.rejectionReason ?? null
            : null,
        moderatedBy: request.auth?.uid,
        updatedAt,
      },
      { merge: true },
    );

    if (payload.status === "approved") {
      applyApprovedSightingUpdates(
        transaction,
        payload.sightingId,
        sighting,
        hasCollectedMonitor,
        parkId!,
        parkName!,
        isFirstParkVisit,
      );
    }

    return {
      sightingId: payload.sightingId,
      status: payload.status,
      changed: true,
    };
  });

  logger.info("Sighting moderated", result);
  return result;
});

export const cleanupOrphanedSightingPhotos = onSchedule(
  "every 24 hours",
  async () => {
    const bucket = getStorage().bucket();
    const [files] = await bucket.getFiles({ prefix: "sightings/" });
    const cutoff = Date.now() - 24 * 60 * 60 * 1000;
    let deleted = 0;

    await Promise.all(
      files.map(async (file) => {
        const parts = file.name.split("/");
        if (
          parts.length !== 4 ||
          parts[0] !== "sightings" ||
          parts[3] !== "photo.jpg"
        ) {
          return;
        }

        const [, userId, sightingId] = parts;
        const [metadata] = await file.getMetadata();
        const createdAt = Date.parse(metadata.timeCreated ?? "");
        if (!Number.isFinite(createdAt) || createdAt > cutoff) {
          return;
        }

        const sightingSnapshot = await db.doc(`sightings/${sightingId}`).get();
        const sighting = sightingSnapshot.data();
        const isBound =
          sightingSnapshot.exists &&
          sighting?.userId === userId &&
          sighting?.storagePath === file.name;
        if (!isBound) {
          await file.delete({ ignoreNotFound: true });
          deleted += 1;
        }
      }),
    );

    logger.info("Orphaned sighting photo cleanup completed", {
      scanned: files.length,
      deleted,
    });
  },
);

function applyApprovedSightingUpdates(
  transaction: Transaction,
  sightingId: string,
  sighting: Sighting,
  hasCollectedMonitor: boolean,
  parkId: string,
  parkName: string,
  isFirstParkVisit: boolean,
): void {
  const updatedAt = FieldValue.serverTimestamp();
  const spottedAt = sighting.spottedAt ?? FieldValue.serverTimestamp();
  const userRef = db.doc(`users/${sighting.userId}`);

  transaction.set(
    userRef,
    {
      totalSightings: FieldValue.increment(1),
      xp: FieldValue.increment(10),
      ...(isFirstParkVisit
        ? { parksVisited: FieldValue.increment(1) }
        : {}),
      updatedAt,
    },
    { merge: true },
  );
  transaction.update(db.doc(`parks/${parkId}`), {
    sightingCount: FieldValue.increment(1),
    updatedAt,
  });

  if (isFirstParkVisit) {
    transaction.create(
      db.doc(`users/${sighting.userId}/visitedParks/${parkId}`),
      {
        parkId,
        parkName,
        firstVisitedAt: updatedAt,
        firstSightingId: sightingId,
      },
    );
  }

  if (sighting.monitorId) {
    transaction.update(db.doc(`monitors/${sighting.monitorId}`), {
      lastSeenAt: spottedAt,
      lastSeenBy: sighting.userId,
      latitude: sighting.latitude,
      longitude: sighting.longitude,
      photoGallery: FieldValue.arrayUnion(sighting.photoUrl),
      sightingCount: FieldValue.increment(1),
      updatedAt,
    });

    if (!hasCollectedMonitor) {
      transaction.set(
        userRef,
        {
          collectedMonitorIds: FieldValue.arrayUnion(sighting.monitorId),
          totalCollected: FieldValue.increment(1),
          updatedAt,
        },
        { merge: true },
      );
    }
  }

  transaction.create(
    db.doc(`users/${sighting.userId}/approvedSightings/${sightingId}`),
    {
      sightingId,
      monitorId: sighting.monitorId ?? null,
      parkId,
      parkName,
      approvedAt: updatedAt,
    },
  );
}
