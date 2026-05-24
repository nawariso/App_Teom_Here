# Infrastructure Setup

This document tracks what is needed to make the project build and release reliably.

## Local Prerequisites

- Flutter SDK.
- Dart SDK included with Flutter.
- Firebase CLI.
- FlutterFire CLI.
- Android Studio for Android builds.
- Xcode for iOS builds on macOS.

## Current Local Blockers

- `flutter pub get` previously failed in the OneDrive copy because `pubspec.lock` could not be rewritten.
- `android/` and `ios/` folders are missing.
- Expected `assets/` folders are missing.
- Actual malformed folder is named `{assets`.
- Generated Dart files are missing until build runner runs.

## Recovery Steps

1. Work from the writable Desktop copy:

```text
C:\Users\mickey\Desktop\Mickey™\Git\App_Teom_Here
```

2. Run:

```bash
flutter pub get
```

3. Restore platform folders if they are not intentionally excluded:

```bash
flutter create .
```

4. Repair assets to match `pubspec.yaml`:

```text
assets/
  images/
  icons/
  animations/
  models/
  fonts/
```

5. Configure Firebase:

```bash
flutterfire configure --project=toem-here
```

6. Generate model code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

7. Verify:

```bash
flutter analyze
flutter test
```

## GitHub Actions

Current workflows expect:

- `FIREBASE_OPTIONS`
- Android signing secrets.
- iOS signing secrets.
- Codecov token.

CI currently writes `lib/firebase_options.dart` from the `FIREBASE_OPTIONS` secret. This can work, but the secret must contain the full generated Dart file content.

## Release Readiness

Before using CD:

- Confirm Android package id.
- Confirm iOS bundle id.
- Confirm app signing assets.
- Confirm Play Store and App Store Connect accounts.
- Add `distribution/whatsnew` if Google Play upload requires it.
