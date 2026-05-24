# Architecture Overview

Toem Here! is a Flutter mobile app using Riverpod, GoRouter, Firebase, and generated immutable models.

## App Layers

- `lib/main.dart`: app bootstrap, Firebase initialization, local storage initialization.
- `lib/app.dart`: root `MaterialApp.router`.
- `lib/core`: theme, router, constants, shared utilities/widgets.
- `lib/features`: vertical feature modules.
- `test`: unit, widget, and integration tests.

## Feature Structure

Preferred feature layout:

```text
lib/features/<feature>/
  domain/
    models/
  data/
    repositories/
  presentation/
    providers/
    screens/
    widgets/
```

The current repo partly follows this pattern. Future work should move gradually toward it without large unrelated refactors.

## State Management

Riverpod is the default state management tool.

- Use providers for repositories and read models.
- Use `StreamProvider` for Firestore streams.
- Use `FutureProvider` for one-shot reads.
- Use controller/notifier classes when workflows have multi-step state.

## Navigation

GoRouter owns route definitions.

- Main tabs live inside `MainShell`.
- Full-screen detail flows can live outside the shell.
- Route names should be stable because widgets may navigate by name later.

## Data Access

Repositories should isolate Firebase calls from UI code.

- UI reads providers.
- Providers call repositories.
- Repositories call Firestore, Storage, Auth, or other services.

## Generated Models

Freezed and JSON Serializable are used for immutable models.

Required generated files:

- `*.freezed.dart`
- `*.g.dart`

These are currently ignored by git, so every local and CI setup must run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Immediate Architecture Risks

- `firebase_options.dart` is imported by `main.dart` but ignored by git.
- Generated model files are missing until build runner runs.
- Platform folders are missing, so native builds cannot work yet.
- The asset folder is malformed and does not match `pubspec.yaml`.
- Text encoding damage affects Thai text, emoji, comments, and docs.
