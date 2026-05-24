# Data Model

This is the MVP Firestore model. It should stay simple until the core product loop works.

## Collections

### `monitors`

Represents a known monitor lizard profile.

Fields:

- `name`: Thai display name.
- `nickname`: English or short display name.
- `photoUrl`: primary photo.
- `parkName`: Thai park name.
- `parkNameEn`: English park name.
- `latitude`: latest known latitude.
- `longitude`: latest known longitude.
- `votes`: current vote count.
- `size`: display size label.
- `personality`: Thai personality text.
- `personalityEn`: English personality text.
- `badge`: display badge.
- `rarity`: `common`, `rare`, `epic`, or `legendary`.
- `sightingStreak`: current streak count.
- `lastSeenAt`: timestamp.
- `lastSeenBy`: user id.
- `photoGallery`: list of photo URLs.
- `tags`: searchable/display tags.
- `createdAt`: timestamp.

Subcollections:

- `voters/{userId}`: tracks whether a user voted for this monitor.

### `sightings`

Represents a submitted sighting event.

Fields:

- `monitorId`: related monitor id.
- `userId`: submitting user id.
- `photoUrl`: sighting photo.
- `latitude`: sighting latitude.
- `longitude`: sighting longitude.
- `parkName`: park display name.
- `notes`: optional notes.
- `spottedAt`: timestamp.

### `users`

Represents app user profile and progress.

Fields:

- `displayName`: public display name.
- `level`: current level.
- `totalCollected`: collection count.
- `achievements`: achievement ids.
- `collectedMonitorIds`: monitor ids.

## Ranking Rules

MVP ranking is all-time votes descending.

Later ranking modes:

- Weekly: votes or sightings in the current week.
- New: recently created monitors.
- Nearby: monitors close to the user.

## Security Rules Notes

Current Firestore rules allow public reads for monitors, sightings, and users. That is acceptable for an early public discovery app, but private profile fields should not be added to public user docs.

Before production:

- Validate required fields on create.
- Prevent arbitrary vote count updates outside trusted logic if possible.
- Add Storage rules for monitor and sighting photos.
- Consider moderation state for submitted sightings.
