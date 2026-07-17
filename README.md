# Toem Here!

Toem Here! is a Flutter app for discovering, photographing, naming, ranking, and collecting monitor lizards across Bangkok parks.

The project is currently in an early recovery/MVP setup phase. The immediate goal is to keep the app runnable locally, then build the core discovery loop in small milestones.

## Current Status

Working baseline:

- Flutter project scaffold is restored for Android, iOS, web, Windows, macOS, and Linux.
- Web build works from an ASCII-only local path.
- Runtime environment selection is explicit. Demo mode never initializes Firebase; development and production fail closed when configuration is missing or mismatched.
- Demo monitor and sighting data is bundled under `assets/data/`.
- Project operating documents live under `docs/`.

Known limitations:

- Firebase config is placeholder-only and not production-ready.
- Demo mode is read-only. Creating monitors, reporting sightings, and real voting still require Firebase setup.
- Thai and emoji text in older source files is corrupted and needs cleanup.
- Custom font files are not committed yet; `pubspec.yaml` no longer declares missing fonts.
- Production Firebase, release signing, App Check, and final privacy hardening
  are intentionally not enabled yet; the checked-in foundation fails closed.

## Recommended Local Path

Use an ASCII-only path for Flutter web builds on Windows.

Current working path:

```text
C:\Users\mickey\Desktop\Git\App_Teom_Here
```

Avoid running Flutter web from this path:

```text
C:\Users\mickey\Desktop\Mickey™\Git\App_Teom_Here
```

The `TM` symbol in the folder name caused Flutter web asset output issues on this machine.

## Prerequisites

- Flutter SDK
- Dart SDK, bundled with Flutter
- Chrome, Edge, or another Flutter-supported browser
- Android Studio for Android work
- Xcode on macOS for iOS work
- Firebase CLI and FlutterFire CLI when Firebase setup resumes

## Setup

```powershell
cd C:\Users\mickey\Desktop\Git\App_Teom_Here
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Run Locally

### Web Server

```powershell
flutter run -d web-server --web-hostname localhost --web-port 52345 --dart-define=APP_ENV=demo
```

Open:

```text
http://localhost:52345
```

### Chrome

```powershell
flutter run -d chrome --dart-define=APP_ENV=demo
```

### Windows Desktop

```powershell
flutter run -d windows --dart-define=APP_ENV=demo
```

## Verify

```powershell
flutter build web --no-tree-shake-icons
flutter analyze
flutter test
```

`flutter build web --no-tree-shake-icons` is the currently verified build command. Icon tree shaking previously failed in the non-ASCII path.

## Project Docs

- Team roles: `docs/team/roles.md`
- Agent workspace: `docs/agents/README.md`
- Agent roster: `docs/agents/agent-roster.md`
- Agent task routing: `docs/agents/task-routing.md`
- Product vision: `docs/product/vision.md`
- MVP scope: `docs/product/mvp-scope.md`
- Production launch plan: `docs/product/production-launch-plan.md`
- User stories: `docs/product/user-stories.md`
- Future feature ideas: `docs/product/future-features.md`
- Architecture overview: `docs/architecture/overview.md`
- Data model: `docs/architecture/data-model.md`
- Production Firebase plan: `docs/architecture/production-firebase-plan.md`
- Infrastructure setup: `docs/infra/setup.md`
- QA test plan: `docs/qa/test-plan.md`
- UX/UI guidelines: `docs/design/ux-ui-guidelines.md`

## Tech Stack

| Layer | Technology |
| --- | --- |
| App framework | Flutter |
| Language | Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| Backend target | Firebase Auth, Firestore, Storage, Messaging |
| Maps target | Google Maps Flutter |
| Local storage | Hive, Shared Preferences |
| Models/codegen | Freezed, JSON Serializable, Build Runner |
| CI/CD | GitHub Actions |

## Project Structure

```text
lib/
  main.dart
  app.dart
  firebase_options.dart
  core/
    constants/
    router/
    theme/
  features/
    auth/
    camera/
    home/
    map/
    monitor/
    profile/
    ranking/
    shell/
docs/
  architecture/
  design/
  infra/
  product/
  qa/
  team/
test/
  helpers/
  unit/
```

## Development Workflow

Use small branches and conventional commits.

Branch examples:

```text
feature/demo-data
fix/firebase-web-startup
docs/readme-update
chore/project-health
```

Commit examples:

```text
feat: add demo monitor data
fix: handle missing firebase config on web
docs: update local run instructions
chore: restore runnable Flutter scaffold
```

## Next Milestone

The next production milestone is the report sighting flow.

Build in this order:

1. Configure Firebase dev and production projects.
2. Deploy and test Firestore and Storage rules.
3. Deploy and test Cloud Functions for moderation, vote counters, and monitor last-seen updates.
4. Build the report sighting flow.
5. Connect home, ranking, map, and profile to production data.

See `docs/product/production-launch-plan.md` for the full launch roadmap.
