# Real Project Roadmap

Date: 2026-06-07

This roadmap integrates the PM, BA, SA, UX/UI, Data, and DBA agent handoffs for turning Toem Here! into a real MVP.

## Product Direction

The real MVP is not a marketing prototype. It is a working mobile-first discovery loop:

```text
Open app -> browse live/ranked monitors -> inspect monitor -> browse by map/park -> submit sighting -> vote/collect -> see profile progress
```

## Delivery Strategy

Build in this order:

1. Stabilize the project.
2. Ship a read-only demo MVP that feels real.
3. Harden the data layer.
4. Enable Firebase reads.
5. Enable authenticated writes only after security rules are ready.
6. Add production readiness gates.

## Milestone 0: Project Health

Goal:

Restore a reliable local baseline before feature work.

Required outcomes:

- `pubspec.yaml` has no conflict markers.
- `flutter pub get` completes from the supported local path.
- `dart run build_runner build --delete-conflicting-outputs` completes or has a documented blocker.
- `flutter analyze` has only known and triaged issues.
- `flutter test` completes or failures are owned.
- `flutter build web --no-tree-shake-icons` completes from the supported path or the blocker is documented.
- Demo mode still runs without production Firebase.
- `.agents/` and `.claude/worktrees/` stay untracked.

Current status:

- `pubspec.yaml` conflict was resolved by keeping `assets/data/`.
- `flutter pub get` timed out twice from the current non-ASCII path after modifying lock/plugin files.
- Infra must verify from the recommended ASCII path before accepting tooling-generated changes.
- Infra also found `flutter --version` and `flutter devices` time out even from the ASCII path, with lingering Dart processes. Flutter/Dart tooling health is the immediate hard blocker.

## Milestone 1: Read-Only Demo MVP

Goal:

Make the app feel like a real product without requiring production Firebase.

Required outcomes:

- App launches into a usable shell.
- Home shows recent sightings, ranking preview, and collection preview from demo data.
- Ranking shows monitors sorted by votes descending.
- Monitor Detail shows name, nickname, park, rarity, photo/fallback, votes, latest sighting, personality, and gallery.
- Map provides Bangkok/park discovery using demo data before real Google Maps dependency is required.
- Profile shows guest/demo progress and collection state.
- Camera/Add Sighting is present as the primary action but clearly staged if real uploads are not ready.
- Loading, empty, and error states are visible.
- Corrupted Thai/emoji text is fixed before UI QA.

## Milestone 2: Data Layer Hardening

Goal:

Make demo and Firebase data behavior consistent, testable, and safe to extend.

Required outcomes:

- Demo data grows from 4 monitors/3 sightings to 12-20 monitors across at least 5 Bangkok parks.
- Ranking rule is documented and implemented: `votes DESC`, tie-break by `lastSeenAt DESC`, then stable name or created time.
- Collection rule is documented: a monitor is collected when the user submits an accepted sighting.
- Repository tests cover demo JSON parsing, ranking, monitor lookup, and recent sightings.
- Firestore timestamp parsing handles null and server timestamp edge cases.
- UI avoids showing `sightingStreak` as authoritative until update logic exists.

## Milestone 3: Firebase Read MVP

Goal:

Connect real backend reads while keeping demo mode available.

Required outcomes:

- Real `firebase_options.dart` is generated for dev Firebase.
- App can read monitors and sightings from Firestore.
- Empty and error states render instead of crashing.
- Firestore indexes are documented.
- Security rules are reviewed before writes.
- Secrets are not committed.

## Milestone 4: Authenticated Sighting Flow

Goal:

Allow real user participation through sightings.

Required outcomes:

- Auth mode is decided, with anonymous auth preferred for MVP unless PM rejects it.
- User can choose/capture a photo.
- User can handle location permission grant, denial, and retry.
- User can select or confirm park.
- Submit creates a sighting record with validation.
- Submission has loading, success, and retryable failure states.
- Duplicate submit taps do not create duplicate records.
- Monitor latest-seen fields update only through trusted logic or a reviewed transaction path.
- Sightings include moderation-ready status: `pending`, `approved`, or `rejected`.

## Milestone 5: Voting And Collection

Goal:

Complete the lightweight social and collection loop.

Required outcomes:

- User can vote and unvote once per monitor.
- Vote count updates safely.
- Ranking reflects updated vote counts.
- Collection count updates from accepted sightings, not votes.
- Profile shows collection progress.
- Vote count is not blindly client-controlled in production.

## Milestone 6: Production Readiness

Goal:

Prepare for external testing or release.

Required outcomes:

- CI runs format/analyze/test/build gates.
- Platform IDs/package names are final.
- Firebase rules and indexes are deployable.
- Storage rules exist for photos.
- Location privacy behavior is approved.
- QA regression checklist passes on mobile-sized viewports.

## Required QA Gates

Before a milestone is accepted:

- Automated checks run from the supported ASCII path.
- Demo mode is tested without production Firebase.
- Thai and English visible text is readable.
- Small Android and iPhone-sized viewports have no text overlap or clipped controls.
- Firebase unavailable state does not crash demo mode.
- Write flows have DBA and Security/Privacy signoff before QA approves them for real users.

Required automated commands:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --no-tree-shake-icons
```

## Required Security Gates

Before production writes:

- Exact user-submitted location and photos are treated as sensitive.
- User-submitted sightings include `status: pending|approved|rejected`.
- Public sighting reads show only approved records or park-level/rounded locations.
- Clients cannot directly update `votes`, latest-sighting fields, `photoGallery`, or `sightingStreak`.
- `users/{userId}` contains only public-safe fields.
- Storage rules exist before image upload.
- Authenticated users can write only to scoped upload paths.
- No service accounts, signing keys, app store credentials, or private Firebase Admin credentials are committed.

## Required DevOps Gates

Before CI is considered real:

- PR CI must not require production Firebase secrets.
- CI checks formatting instead of pushing formatting commits.
- CI mirrors local commands.
- Web build is the first required build target.
- Android/iOS release automation stays manual or disabled until package IDs, signing, Firebase config, and store credentials are real.

## Explicitly Deferred

- App store release automation.
- Advanced ML identification.
- Push notifications.
- Complex moderation.
- Weekly rankings.
- Full achievements system.
- Monetization.
- Pixel Agents Codex adapter.
- Broad architecture rewrite.

## Key Product Decisions To Confirm

- Can MVP users submit sightings as anonymous-auth users?
- Is demo mode read-only, or can it simulate local vote/collection behavior?
- Are exact sighting coordinates public, rounded, or hidden behind park-level display?
- Are new monitor profiles admin-seeded only for MVP?
- Is collection strictly from accepted sightings?

## Top Risks

- Build/tooling instability blocks all feature work.
- Flutter/Dart commands are currently hanging even before feature work can be verified.
- Public location and photo data create privacy risk.
- Client-controlled votes create abuse risk.
- Firebase setup could break demo mode if not isolated.
- Corrupted Thai/emoji text visibly damages trust.
- Demo data is too thin to validate real UX.
