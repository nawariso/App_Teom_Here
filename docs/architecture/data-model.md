# Canonical Data Model

This file is the source of truth for schema version 1. Dart models, Firebase
Rules, Cloud Functions, demo fixtures, indexes, and migrations must agree with
it. Client writes that contain undocumented fields are rejected.

## General conventions

- Document IDs are carried by Firestore paths, not duplicated in document data.
- Every client-created production document uses `schemaVersion: 1`.
- Server-owned counters and progression fields are never client-editable.
- Public user documents never contain email addresses or other private identity
  data.
- `createdAt` and `updatedAt` are Firestore timestamps in production.
- Stable IDs are lowercase ASCII slugs. Localized display names are not IDs.

## `users/{userId}`

Public profile and server-owned progression:

- `schemaVersion: 1`
- `displayName: string` (1-60 characters)
- `photoUrl: string | null`
- `level: int`
- `totalCollected: int`
- `totalSightings: int`
- `parksVisited: int`
- `xp: int`
- `achievementIds: string[]`
- `favoriteMonitorIds: string[]`
- `collectedMonitorIds: string[]`
- `createdAt: timestamp`
- `updatedAt: timestamp`

A client may create only its own zero-progress profile and may subsequently
change only `displayName`, `photoUrl`, and `updatedAt`. Progress is changed by
trusted backend code.

Subcollection `approvedSightings/{sightingId}` is private to its owner and is
written by Cloud Functions.

## `monitors/{monitorId}`

Known monitor-lizard profile:

- `schemaVersion: 1`
- `name`, `nickname`, `parkName`, `parkNameEn`: display strings
- `photoUrl: string | null`
- `parkId: string`: stable park slug
- `latitude`, `longitude: number`
- `votes: int`
- `size`, `personality`, `personalityEn`, `badge: string`
- `rarity: common | rare | epic | legendary`
- `sightingCount: int`
- `lastSeenAt: timestamp | null`
- `lastSeenBy: string | null`
- `photoGallery`, `tags: string[]`
- `moderationStatus: approved | hidden`
- `createdAt`, `updatedAt: timestamp`

Public clients can read approved monitors but cannot write monitor documents.

Subcollection `voters/{userId}` contains only `votedAt: timestamp`. The voter
ID must match the authenticated user and the parent monitor must already exist
and be approved.

## `sightings/{sightingId}`

Submitted sighting:

- `schemaVersion: 1`
- `monitorId: string | null`
- `submittedAsUnknown: bool`
- `userId: string`
- `photoUrl: string`
- `storagePath: sightings/{userId}/{sightingId}/photo.jpg`
- `latitude: number` (-90 through 90)
- `longitude: number` (-180 through 180)
- `parkId: string`: stable park slug
- `parkName: string`: display name
- `notes: string | null` (maximum 500 characters)
- `moderationStatus: pending | approved | rejected`
- `rejectionReason: string | null`
- `spottedAt`, `createdAt`, `updatedAt: timestamp`

Invariant:

- Known sighting: `submittedAsUnknown == false`, `monitorId` is the ID of an
  existing approved monitor.
- Unknown sighting: `submittedAsUnknown == true`, `monitorId == null`.

Only the owner can read a pending/rejected sighting. Approved sightings are
public. Clients cannot update or delete submitted records.

## Storage

`/sightings/{userId}/{sightingId}/photo.jpg`

- Create: owner only, image under 5 MiB.
- Required custom metadata: `ownerId == userId` and
  `sightingId == sightingId`.
- Read: owner, or public after the corresponding Firestore sighting is approved
  and its `userId` and `storagePath` match the object path.
- Delete: owner only while the related sighting is absent, pending, or rejected;
  deletion is denied after approval so public records retain their media.
- Update: denied.

## Backend-only collections

- `moderationQueue/{sightingId}`: moderation workflow state.
- `functionEvents/{eventKey}`: idempotency ledger for event-triggered counters.
- `parks/{parkId}`: park aggregate keyed only by stable `parkId`.
- `reports/{reportId}`: client-created abuse report, unreadable by clients.

## Legacy read compatibility

The Flutter decoder temporarily accepts:

- `totalPhotos` as `totalSightings`
- `achievements` as `achievementIds`
- `sightingStreak` as `sightingCount`

New writes must use only canonical names. Remove compatibility after production
data migration and verification.
