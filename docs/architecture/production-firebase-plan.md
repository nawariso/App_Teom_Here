# Production Firebase Plan

This document describes deployment and operational work. The authoritative
schema is [`data-model.md`](data-model.md); do not duplicate or rename its
fields here.

## Environments

Use separate Firebase projects:

- `toem-here-dev` for development and integration testing.
- `toem-here-prod` for public production data.

The Flutter app requires an explicit `APP_ENV` compile-time value. Demo mode
never initializes Firebase. Dev and production validate the selected project
and reject placeholder or mismatched options before initialization.

Production options intentionally remain placeholders in source control. CI
builds demo artifacts only until signing and production Firebase configuration
are supplied through an approved secret-management workflow.

## Implemented Backend Foundation

- Canonical schema version 1 in `data-model.md`.
- Firestore and Storage deny-by-default rules.
- Firebase Emulator rule tests under `firebase-tests/`.
- Cloud Functions TypeScript build and unit tests under `functions/`.
- Stable `parkId` references backed by active `parks/{parkId}` documents.
- Source-of-truth vote recounting from `monitors/{monitorId}/voters`.
- Retry-safe event ledger under `functionEvents/{eventKey}`.
- Non-regressive moderation queue creation.
- Moderator/admin callable validation and canonical photo binding.
- Transactional progression, collection, park-visit, monitor, and park updates.
- Orphaned sighting-photo cleanup after a 24-hour grace period.
- Committed composite indexes in `firestore.indexes.json`.

## Canonical Storage Paths

```text
sightings/{userId}/{sightingId}/photo.jpg
monitors/{monitorId}/primary.jpg
monitors/{monitorId}/gallery/{photoId}.jpg
users/{userId}/profile.jpg
```

Sighting uploads must be JPEG-path-bound to their owner and sighting metadata.
The owner can clean up an orphaned, pending, or rejected upload. Once its
Firestore sighting is approved, owner deletion is denied so public records do
not become broken. Public reads require an approved Firestore sighting whose
`userId` and `storagePath` match the object.

## Client and Trusted-Backend Boundaries

Clients may create only:

- their zero-progress public profile,
- their own pending sighting for an active canonical park,
- their own voter document on an approved monitor,
- their own abuse report.

Clients cannot write progression, aggregate counters, moderation state,
monitor records, park records, moderation queue entries, or function-event
ledger entries. Those writes are performed only by trusted backend code.

## Required Before Production

1. Create and secure the dev and production Firebase projects.
2. Generate environment- and platform-specific Firebase options without
   committing credentials; validate project ID, bucket, app ID, and bundle ID.
3. Enable Firebase App Check and configure abuse/rate controls.
4. Add trusted image inspection/re-encoding rather than relying only on MIME
   metadata and file-size rules.
5. Complete a privacy review of public coordinates and persistent media URLs.
6. Seed verified active parks and approved starter monitors with stable IDs.
7. Create test moderator/admin accounts with narrowly scoped custom claims.
8. Add Functions emulator integration tests for concurrent votes, repeated
   moderation, delayed triggers, and first-park visits.
9. Add explicit rule cases for inactive parks, timestamp bounds, hidden
   monitors, rejected-image cleanup, and approved-image deletion denial.
10. Pin third-party CI actions to immutable commit SHAs.
11. Configure Android/iOS signing and restore release jobs only after production
    Firebase configuration is validated in CI.
12. Deploy to dev first, execute smoke/rollback tests, then promote the same
    reviewed revisions to production.

## Verification Commands

```bash
flutter analyze
flutter test

cd functions
npm ci
npm run lint
npm run build
npm test

cd ../firebase-tests
npm ci
npm test
```

Deployment is deliberately outside CI until production readiness is approved:

```bash
firebase use toem-here-dev
firebase deploy --only firestore:rules,firestore:indexes,storage,functions
```

Never deploy directly to production without a successful dev deployment,
emulator tests, smoke tests, and an explicit rollback plan.
