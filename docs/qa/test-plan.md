# QA Test Plan

QA should focus on keeping the core discovery loop reliable.

## Automated Checks

Run before every PR merge:

```bash
dart format .
flutter analyze
flutter test
```

When generated files or models change:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test
```

## Unit Test Targets

- Monitor model JSON parsing.
- Sighting model JSON parsing.
- Rarity handling.
- Repository vote behavior.
- Ranking sorting logic.
- Collection progress calculations.

## Widget Test Targets

- Home screen loads empty, loading, error, and data states.
- Ranking screen renders sorted monitors.
- Monitor detail handles missing optional image fields.
- Profile screen renders empty and populated collection states.

## Manual Regression Checklist

- App launches without crashing.
- Bottom navigation switches tabs correctly.
- Home screen shows recent sightings.
- Ranking screen shows monitors in vote order.
- Monitor detail opens from ranking/home.
- Vote/unvote works.
- Map screen loads and centers on Bangkok.
- Camera/image picker flow handles permission denial.
- Sighting submission handles success and failure.
- Thai and English text render correctly.
- UI works on small Android and iPhone-sized viewports.

## Bug Report Template

Include:

- Device or emulator.
- OS version.
- App build/version.
- Steps to reproduce.
- Expected result.
- Actual result.
- Screenshot or screen recording if UI-related.
- Logs if crash or Firebase error.
