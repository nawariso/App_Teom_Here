# MVP Scope

The MVP should prove the core discovery and collection loop before adding advanced AI, full social features, or production release automation.

## In Scope

- Onboarding and basic sign-in.
- Home screen with recent sightings and ranking preview.
- Monitor list and monitor detail screen.
- Ranking screen with all-time ranking.
- Map screen showing known monitor locations.
- Camera or image picker flow for submitting a sighting.
- Firestore-backed monitor and sighting data.
- Vote/unvote behavior.
- Basic user profile and collection count.
- Local development setup documentation.
- Basic unit and widget tests for core logic.

## Out of Scope For MVP

- Full production app store release.
- Advanced ML model training.
- Real-time push notification alerts.
- Complex anti-abuse moderation.
- Weekly/new ranking filters unless data model is ready.
- Achievement system beyond simple placeholders.
- Full bilingual content management system.
- Payment, subscriptions, or monetization.

## Milestone Plan

### Milestone 0: Project Health

- Fix dependency installation.
- Restore platform folders.
- Repair asset folder structure.
- Regenerate generated Dart files.
- Run `flutter analyze` and `flutter test`.

### Milestone 1: Read-Only App

- App launches locally.
- Home, ranking, map, profile, and detail routes render.
- Demo data works without requiring production Firebase.
- Existing tests pass.

### Milestone 2: Firebase MVP

- Firebase options configured.
- Firestore reads monitors and sightings.
- Security rules reviewed.
- Repository tests cover core data behavior where practical.

### Milestone 3: Sighting Flow

- User can choose/take a photo.
- User can submit a sighting.
- Monitor last-seen data updates.
- Submission errors are visible and recoverable.

### Milestone 4: Voting And Collection

- User can vote/unvote.
- Ranking updates.
- Profile shows basic collection/progress.
- QA regression checklist is passing.
