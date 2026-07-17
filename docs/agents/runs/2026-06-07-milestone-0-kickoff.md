# Milestone 0 Agent Kickoff

Date: 2026-06-07

## Mission

Restore project health so the app has a reliable local development baseline before feature work continues.

## Current Known State

- `pubspec.yaml` has an unresolved merge conflict and must be resolved before normal Flutter commands are reliable.
- `.agents/` contains local Pixel Agents tooling and should stay untracked.
- `.claude/worktrees/` contains local agent worktrees and should stay untracked.
- The app is intended to remain runnable in local demo mode without production Firebase.
- Firebase configuration is placeholder-only.
- Windows Flutter web builds have had issues from non-ASCII paths.

## Lead Agent

PM Agent

Use: `docs/agents/roles/pm.md`

### PM Objective

Keep Milestone 0 focused on build health, local reproducibility, and safe demo mode.

### PM Output

- Confirm what is in and out of Milestone 0.
- Track open risks.
- Decide whether any requested feature work must wait until health checks pass.

## Agent Assignments

### BA Agent

Use: `docs/agents/roles/ba.md`

Objective:

- Convert Milestone 0 into acceptance criteria.
- Define what "project health restored" means in testable terms.

Deliverable:

- Update or propose updates to `docs/product/mvp-scope.md` if Milestone 0 acceptance criteria are missing.

### SA Agent

Use: `docs/agents/roles/sa.md`

Objective:

- Review current architecture risks that block build/test reliability.
- Identify minimum safe fixes before feature implementation.

Deliverable:

- Architecture risk notes, especially around generated files, Firebase options, demo mode, and feature structure.

### Infra Agent

Use: `docs/agents/roles/infra.md`

Objective:

- Make local setup commands accurate for the current repo state.
- Resolve outdated setup notes.

Deliverable:

- Update `docs/infra/setup.md` and README setup notes if needed.

### DevOps Agent

Use: `docs/agents/roles/devops.md`

Objective:

- Review CI expectations against local commands.
- Identify workflow failures likely to happen while `pubspec.yaml` is conflicted or generated files are absent.

Deliverable:

- CI risk notes and recommended quality gates.

### Dev Agent

Use: `docs/agents/roles/dev.md`

Objective:

- Resolve only assigned implementation blockers.
- First likely task is resolving `pubspec.yaml` after reviewing both conflict sides.

Deliverable:

- Code/config changes with verification output.

### QA Agent

Use: `docs/agents/roles/qa.md`

Objective:

- Define the minimum regression checklist for declaring Milestone 0 complete.

Deliverable:

- QA checklist covering `flutter pub get`, build runner, analyze, test, and web build.

## Milestone 0 Acceptance Criteria

- `pubspec.yaml` has no merge conflict markers.
- `flutter pub get` completes.
- `dart run build_runner build --delete-conflicting-outputs` completes or has a documented blocker.
- `flutter analyze` completes with known, triaged issues only.
- `flutter test` completes or has a documented blocker.
- `flutter build web --no-tree-shake-icons` completes from the supported local path or the blocker is documented.
- Demo mode still runs without production Firebase.
- Local-only agent tooling remains untracked.

## Out Of Scope

- New product features.
- Production Firebase rollout.
- App store release automation.
- Large architecture refactors.
- Pixel Agents Codex adapter.

## Immediate Next Task

Assign Dev Agent to resolve `pubspec.yaml`, then assign Infra and QA agents to verify local setup commands.

## Initial Dev Agent Handoff

Summary:

- Resolved the `pubspec.yaml` merge conflict by keeping `assets/data/`, because README states demo data is bundled there.
- Marked `pubspec.yaml` resolved in Git.
- Ran `flutter pub get` twice. It timed out after 120 seconds and then after 300 seconds.

Observed changes:

- `pubspec.lock` was rewritten by the Flutter tool before timeout.
- Linux, macOS, and Windows generated plugin registrant files were touched by Flutter tooling.

Risks:

- The current path contains a non-ASCII folder segment, which existing README notes identify as a Flutter web risk on this machine.
- `pubspec.lock` now reflects newer transitive package resolution from the installed Flutter/Dart toolchain, but the command did not exit cleanly.
- Infra should verify from the recommended ASCII path before accepting the lockfile/tooling updates.

Recommended next owner:

- Infra Agent to verify `flutter pub get` from the supported local path and update setup docs.
- QA Agent to define whether the touched generated plugin files are expected and acceptable.

## Follow-Up Verification

Date: 2026-06-07

Actions:

- Stopped stale Dart processes left by the timed-out Flutter run.
- Verified raw Dart SDK works.
- Confirmed Flutter commands require elevated access because the Flutter SDK cache lives outside the repository at `C:\Users\mickey\Downloads\flutter\bin\cache`.
- Reran checks from the supported ASCII workspace: `C:\Users\mickey\Desktop\Git\App_Teom_Here`.

Results:

- `flutter --version`: passed. Flutter 3.41.5, Dart 3.11.3.
- `flutter devices`: passed. Windows, Chrome, and Edge detected.
- `flutter pub get`: passed. It updated `pubspec.lock` and generated plugin registrants.
- `dart run build_runner build --delete-conflicting-outputs`: passed. Wrote 7 outputs. Warning: SDK language version 3.11.0 is newer than analyzer language version 3.9.0.
- `flutter test`: passed. 25 tests passed.
- `flutter build web --no-tree-shake-icons`: passed.
- `flutter analyze`: completed but failed the quality gate with 85 issues. Most are style/info lints, plus warnings for a removed lint, unused import, and inferred `List` types in tests.

Decision:

- The original Flutter hang is resolved as a permissions/cache-access issue, not a broken SDK.
- The lockfile and plugin registrant changes are reproducible from a clean `flutter pub get` run in the ASCII workspace.

## Analyze Cleanup

Actions:

- Applied automatic Dart fixes.
- Replaced deprecated `withOpacity` calls with `withValues(alpha: ...)`.
- Removed the obsolete `avoid_returning_null_for_future` lint.
- Replaced placeholder TODO comments that were tripping `flutter_style_todos`.
- Added explicit `List<String>` literals in model tests.
- Formatted Dart source/test files, excluding local agent tooling.

Final results from active workspace:

- `flutter analyze`: passed with no issues.
- `flutter test`: passed. 25 tests passed.
- `flutter build web --no-tree-shake-icons`: passed.

Decision:

- Milestone 0 health gate is now green for dependency restore, code generation, analyze, tests, and web build.

## Handoff Requirement

Every agent must finish with `docs/agents/templates/handoff.md`.
