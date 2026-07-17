# Agent Operating Model

The agent workspace runs like a small product delivery team. Each agent owns a clear slice of work, produces explicit artifacts, and hands off decisions instead of hiding assumptions in implementation.

## Delivery Flow

1. PM defines goal, milestone, priority, and release boundary.
2. BA turns the goal into user stories, rules, and acceptance criteria.
3. UX/UI defines user flow, screen behavior, copy needs, and accessibility constraints.
4. SA and EA align feature architecture with app boundaries, platform constraints, and long-term direction.
5. Data and DBA define data semantics, Firestore schema, indexes, rules, migrations, and seed data.
6. Dev implements the feature in small changes.
7. Infra and DevOps update environment, CI/CD, build, release, and operational setup.
8. QA verifies acceptance criteria, regression risk, and release readiness.
9. PM closes the loop by updating roadmap, risks, and next milestone.

## Collaboration Rules

- Work from existing docs before inventing new direction.
- Keep every task small enough to review in one pull request.
- Document assumptions in the handoff.
- Escalate cross-role decisions instead of making silent changes.
- Prefer demo-safe and local-first behavior until Firebase production setup is approved.
- Do not overwrite user work or unresolved merge conflicts.

## Shared Quality Gates

- Product behavior has acceptance criteria.
- UI behavior is usable on mobile viewport sizes.
- Data changes include schema, rule, and index impact.
- Code changes include focused tests or a clear reason tests were not added.
- Infra changes include reproducible local commands.
- Release candidates have QA sign-off.

## Current Project Constraints

- The project is in MVP recovery/setup.
- `pubspec.yaml` currently has an unresolved merge conflict.
- Firebase config is placeholder-only.
- Demo data should continue working without production Firebase.
- Flutter web has had issues under non-ASCII local paths on Windows.
