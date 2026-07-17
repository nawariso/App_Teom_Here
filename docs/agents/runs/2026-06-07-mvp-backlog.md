# MVP Backlog

Date: 2026-06-07

## P0: Stabilize The Repo

Owner: Dev, Infra, QA

- Clear or restart stuck Flutter/Dart tooling before rerunning checks.
- Verify `flutter --version` and `flutter devices` complete from the supported ASCII path.
- Verify `flutter pub get` from the recommended ASCII path.
- Decide whether to accept or revert the generated `pubspec.lock` and plugin registrant changes from the timed-out run.
- Run build runner and document results.
- Run analyze/test/web build and document blockers.
- Update setup docs with commands that work on this machine.

Acceptance:

- Milestone 0 quality gate is either passing or has named blockers with owners.

Current status:

- Flutter commands pass when run with SDK cache access from `C:\Users\mickey\Desktop\Git\App_Teom_Here`.
- `flutter analyze`, `flutter test`, and `flutter build web --no-tree-shake-icons` now pass in the active workspace.
- `pubspec.lock` and plugin registrant changes are reproducible from a successful `flutter pub get`.

## P0: Fix Visible Text Corruption

Owner: UX/UI, Dev, QA

- Audit visible UI strings for corrupted Thai/emoji text.
- Replace broken text with clean English or verified Thai.
- Avoid emoji if encoding is unreliable.
- Add QA check for Thai/English rendering.

Acceptance:

- Main screens render readable text.
- No corrupted visible strings on Home, Ranking, Detail, Map, Camera, or Profile.

## P1: Read-Only Map/Park Browse

Owner: UX/UI, Data, Dev, QA

- Use demo monitor/sighting coordinates to show Bangkok park discovery.
- If Google Maps is not configured, provide a clear park list/map-placeholder experience.
- Support tap from park/monitor item to Monitor Detail.
- Include empty and error states.

Acceptance:

- User can browse known monitor locations by park without Firebase.

## P1: Real Demo Profile

Owner: UX/UI, Data, Dev, QA

- Replace placeholder profile with guest/demo profile.
- Show display name, collection count, level/progress, and collected monitor placeholders.
- Explain cloud sync/auth requirement only when needed.

Acceptance:

- Profile communicates progress even in demo mode.

## P1: Monitor Detail Upgrade

Owner: UX/UI, Data, Dev, QA

- Render primary photo or polished fallback.
- Show rarity, votes, park, last seen, personality, and gallery.
- Add disabled/pending states for vote/share if not ready.
- Avoid showing misleading streak values until data logic is real.

Acceptance:

- Monitor Detail feels like a real profile page using demo data.

## P1: Expand Demo Data

Owner: Data, QA

- Add 12-20 monitor profiles.
- Cover at least 5 Bangkok parks.
- Include multiple rarity levels.
- Include realistic vote spread and tie cases.
- Include recent and stale sightings.
- Include missing-photo cases and gallery cases.

Acceptance:

- Home, Ranking, Map, Detail, and Profile can all be tested from demo data.

## P2: Data Layer Tests

Owner: SA, Dev, QA

- Test demo monitor JSON parsing.
- Test demo sighting JSON parsing.
- Test ranking sort and tie-breaks.
- Test monitor lookup.
- Test recent sightings.

Acceptance:

- Repository behavior is protected before Firebase changes.

## P2: Firebase Read Mode

Owner: Infra, DBA, Security, Dev

- Generate real dev Firebase options.
- Read monitors and sightings from Firestore.
- Keep demo mode as fallback.
- Document required indexes.
- Keep secrets out of Git.
- Install or expose Firebase CLI and FlutterFire CLI on `PATH`.
- Keep Google Maps deferred unless API keys and platform wiring are ready.

Acceptance:

- App can switch between demo and Firebase reads without breaking local dev.

## P3: Security-Reviewed Write Design

Owner: DBA, Security, SA, Dev

- Decide anonymous auth behavior.
- Add sighting moderation fields.
- Define Storage paths for photos.
- Prevent direct client ownership of derived counters.
- Validate Firestore create/update fields.
- Add Firebase Storage rules for photo upload paths.
- Add moderation status before public sighting reads.
- Decide public coordinate precision for sightings.

Acceptance:

- Write implementation has approved rule and data-integrity design before coding.

## P3: Add Sighting Flow

Owner: UX/UI, BA, Dev, QA

- Photo selection/capture.
- Location permission handling.
- Park selection.
- Existing monitor selection.
- Submission validation.
- Loading, success, failure states.

Acceptance:

- User can submit a sighting in dev mode without losing data on retryable failures.

## P4: Voting And Collection

Owner: Data, DBA, Dev, QA

- Vote/unvote once per user per monitor.
- Update ranking.
- Collect monitor from accepted sighting.
- Show collection progress in Profile.

Acceptance:

- Social/collection loop works with duplicate protection.

## P5: CI And Release Gates

Owner: DevOps, Infra, QA

- Align CI with local commands.
- Ensure PR checks do not require production secrets.
- Add web build gate.
- Remove or disable CI behavior that formats and pushes commits.
- Keep production CD disabled/manual until Milestone 1 is green.
- Document release readiness checklist.

Acceptance:

- Main branch has reliable automated quality gates.
