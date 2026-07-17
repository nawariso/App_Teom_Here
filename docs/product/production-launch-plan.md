# Toem Here Production Launch Plan

This plan turns Toem Here from a runnable prototype into a production app people can understand, trust, and come back to.

## Product Promise

Toem Here helps people discover Bangkok's monitor lizards as real park characters: spot them, submit sightings, collect profiles, vote on favorites, and build a living city wildlife map together.

The app should feel playful, but not like a joke. It should be safe, respectful of wildlife, and useful enough that park visitors understand why they should open it again.

## Core Gimmick

The strongest gimmick is real-world collection:

> Spot real monitor lizards in Bangkok parks, collect them like local wildlife characters, and help build a live community map.

This combines:

- Discovery: nearby and recent sightings.
- Collection: each monitor has a profile, rarity, badge, and personality.
- Community: users add sightings, vote, and improve the shared map.
- Local identity: Bangkok parks and named local wildlife.
- Responsibility: safe-distance and wildlife respect guidance.

Do not make the product only about ranking. Ranking is fun, but the durable loop is discovery, sighting, collection, and return.

## Target Users

Primary users:

- Bangkok park visitors who see monitor lizards and want a fun way to document them.
- Tourists who want a memorable local nature experience.
- Wildlife-curious locals who enjoy maps, rankings, and collections.

Secondary users:

- Park communities.
- Educators and parents.
- Local creators who can share sighting cards.

## Production User Loop

The first production loop must be simple and obvious:

1. User opens the app.
2. Home shows recent sightings, top monitors, and collection progress.
3. User opens the map or camera.
4. User submits a sighting with photo, location, park, and optional notes.
5. App creates a sighting and updates the monitor's last-seen state.
6. User earns collection progress or XP.
7. Other users can view and vote.
8. User returns to check rankings, map activity, and their profile.

Every launch feature should support this loop. Features outside this loop should wait.

## MVP Launch Scope

### Must Have

- Firebase Auth sign-in.
- User profile creation on first sign-in.
- Home screen with recent sightings, ranking preview, and collection progress.
- Ranking screen using Firestore data.
- Monitor detail screen with photo fallback and sighting context.
- Map screen with park markers and monitor/sighting counts.
- Report sighting flow:
  - camera or gallery photo,
  - location permission,
  - park selection,
  - monitor selection or "new unknown monitor",
  - notes,
  - submit success and failure states.
- Firebase Storage upload for sighting photos.
- Firestore-backed monitors, sightings, votes, and user progress.
- Basic moderation state for user-submitted sightings.
- Firestore and Storage security rules.
- Privacy policy and terms links.
- Crash/error reporting.
- Production app icon, splash, package id, bundle id, and app display name.
- Automated verification: format, analyze, tests, web build.

### Should Have

- Lizard passport/profile collection.
- XP and basic levels.
- Shareable sighting card.
- Safe wildlife guidance during onboarding and submission.
- Empty/loading/error states for every production screen.
- Admin-only verified sighting flag.

### Later

- Weekly ranking.
- Comments.
- Push notifications.
- ML-assisted lizard detection.
- Advanced quests.
- Bilingual content management.
- Public web landing page.
- Store review automation.

## Launch Milestones

### Milestone 0: Project Health

Goal: make the project reliable to build and change.

- Keep `flutter analyze` clean.
- Keep `flutter test` passing.
- Remove corrupted text from app source and docs.
- Decide supported launch platforms: Android first, then iOS.
- Confirm package id and bundle id.
- Confirm Firebase project names for dev and production.
- Separate demo mode from production mode.

Exit criteria:

- Local web run works.
- Analyzer and tests pass.
- Production blockers are tracked.

### Milestone 1: Production Foundation

Goal: create the real backend foundation.

- Configure Firebase dev and production projects.
- Generate real `firebase_options.dart`.
- Implement Auth providers.
- Implement user profile document creation.
- Implement Firestore repositories for monitors, sightings, votes, and users.
- Add Storage upload path conventions.
- Add security rules for Firestore and Storage.
- Add local seed data script or documented manual seed process.

Exit criteria:

- A signed-in test user can read production-like monitor data.
- Test user profile is created safely.
- Rules reject unauthenticated writes.

### Milestone 2: Sighting Submission

Goal: complete the core contribution loop.

- Build report sighting screen.
- Support image picker and camera.
- Support location permission and manual fallback.
- Let user select existing monitor or submit unknown sighting.
- Upload photo to Storage.
- Create `sightings` document with `pending` moderation status.
- Update monitor last-seen fields only through safe server-side logic or tightly constrained rules.
- Show success, retry, and permission-denied states.

Exit criteria:

- Real user can submit a sighting.
- Sighting appears in home/recent feed after allowed moderation state.
- Failed submissions are recoverable.

### Milestone 3: Retention Layer

Goal: give users a reason to return.

- Implement collection progress.
- Add XP and level calculations.
- Add basic achievements:
  - first sighting,
  - first park,
  - first vote,
  - three sightings,
  - legendary sighting.
- Add profile progress UI.
- Add share card for sighting or monitor profile.

Exit criteria:

- User can see progress after submitting or voting.
- Profile communicates why to keep using the app.

### Milestone 4: Trust, Safety, And Moderation

Goal: make public usage safe.

- Add report abuse flow.
- Add moderation states: `pending`, `approved`, `rejected`.
- Hide pending/rejected content from public feeds unless owner/admin.
- Add admin workflow outside the app or through a protected admin screen.
- Prevent arbitrary vote count manipulation.
- Add rate limits where possible.
- Add privacy copy for location and photo usage.

Exit criteria:

- Public feeds only show approved content.
- User-submitted content can be reviewed or removed.
- Rules protect user and app data.

### Milestone 5: Launch Polish

Goal: make the app credible in a store listing and first session.

- Finalize onboarding.
- Add wildlife safety guidance.
- Add permission pre-prompts.
- Add app icon and splash assets.
- Add store screenshots.
- Add privacy policy and terms.
- Add analytics events.
- Add crash reporting.
- Run manual QA on real Android devices.
- Build release APK/AAB.

Exit criteria:

- Release build installs on a real device.
- Core loop passes manual QA.
- Store listing assets are ready.

## Screen Priorities

### Home

Home must answer: "What is happening now?"

- Recent sighting card.
- Top 3 ranking.
- Collection progress.
- Primary action to report a sighting.
- Nearby/park activity teaser.

### Map

Map must answer: "Where can I find activity?"

- Bangkok centered by default.
- Park markers with sighting counts.
- Recent sighting pins.
- Tap marker to see park summary.
- Manual fallback list if map fails.

### Report Sighting

Report sighting must be the best flow in the app.

- Clear photo step.
- Clear location step.
- Existing monitor or unknown monitor choice.
- Park selection.
- Optional notes.
- Submission confirmation.
- Friendly failure states.

### Monitor Detail

Monitor detail must answer: "Why is this lizard interesting?"

- Name, nickname, rarity, badge.
- Primary image or polished fallback.
- Last seen park/time.
- Personality.
- Vote action.
- Sighting history preview.
- Share card action.

### Profile

Profile must answer: "What have I achieved?"

- Collection count.
- XP/level.
- Submitted sightings.
- Favorite monitors.
- Badges.

## Data And Backend Principles

- Public discovery data can be public-read.
- Personal/private fields should not be stored in public user documents.
- User-submitted content should default to `pending` until approved or trusted.
- Vote counts should not rely only on client trust long-term.
- Storage paths should include user id and generated ids.
- Location precision should be intentional. Do not expose more precision than the product needs.
- Demo mode should never write to production.

See `docs/architecture/production-firebase-plan.md` for schema and rules details.

## Quality Gates

Before each merge:

```bash
dart format .
flutter analyze
flutter test
```

Before launch candidate:

```bash
flutter build web --no-tree-shake-icons
flutter build apk --release
flutter build appbundle --release
```

Manual QA must cover:

- fresh install,
- sign-in,
- denied permissions,
- report sighting success,
- report sighting failure,
- vote/unvote,
- map load failure,
- slow network,
- small screen,
- logout/restart.

## Success Metrics

Early launch metrics:

- Activation: user reaches home and understands the report action.
- Contribution: user submits a sighting.
- Retention: user returns within 7 days.
- Collection: user opens profile after activity.
- Sharing: user shares a sighting or monitor card.
- Trust: rejected/abusive content rate stays manageable.

Suggested event names:

- `onboarding_completed`
- `auth_signed_in`
- `home_report_tapped`
- `sighting_photo_added`
- `sighting_submitted`
- `sighting_submit_failed`
- `monitor_opened`
- `monitor_voted`
- `map_marker_tapped`
- `profile_opened`
- `share_card_created`

## Immediate Next Build Sequence

Build in this order:

1. Auth and user profile foundation.
2. Production Firestore/Storage schema and rules.
3. Deploy and test Cloud Functions for moderation and derived counters.
4. Report sighting flow with demo-safe UI.
5. Firestore sighting submission.
6. Home recent sightings from Firestore.
7. Profile collection progress.
8. Vote/unvote hardening.
9. Moderation status and public feed filtering.
10. Launch polish and release build.

The next engineering task should be the report sighting UI and repository flow. The trusted backend path is now scaffolded, so the app can submit pending sightings without exposing them publicly before moderation.
