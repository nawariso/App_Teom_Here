# Team Roles

This project uses role-based ownership to keep decisions clear without slowing down development.

## PM

Owns product direction, milestones, priority, and release scope.

- Maintains the roadmap.
- Decides what is in or out of the MVP.
- Keeps work grouped into small, shippable milestones.
- Tracks open risks and unresolved decisions.

## BA

Owns user stories, feature rules, and acceptance criteria.

- Turns product ideas into clear user stories.
- Defines expected behavior and edge cases.
- Keeps acceptance criteria testable.
- Confirms that implemented features match the intended workflow.

## SA

Owns technical architecture and system boundaries.

- Defines Flutter feature structure.
- Defines Firebase integration patterns.
- Reviews data model, security rules, and dependency choices.
- Keeps architecture aligned with the MVP and future growth.

## Dev

Owns implementation.

- Builds Flutter screens, widgets, repositories, and providers.
- Follows existing project structure and lint rules.
- Adds focused tests for behavior touched by each change.
- Keeps changes scoped and reviewable.

## Data

Owns data model, ranking rules, analytics, and seed data.

- Maintains Firestore schema.
- Defines ranking, voting, collection, rarity, and achievement logic.
- Plans analytics events.
- Creates safe demo or seed data for development.

## Infra

Owns developer setup, Firebase setup, CI/CD, secrets, and release pipeline.

- Restores local build health.
- Maintains GitHub Actions.
- Documents Firebase, Google Maps, signing, and deployment setup.
- Keeps environment configuration reproducible.

## QA

Owns quality gates and testing strategy.

- Maintains the test plan.
- Defines manual regression checks.
- Reviews bug reports and reproduction steps.
- Confirms release readiness.

## UX/UI

Owns user flows, visual direction, interaction quality, and accessibility.

- Defines screen flows and navigation.
- Maintains visual guidelines.
- Reviews usability on mobile viewports.
- Ensures Thai and English text display correctly.

## Codex Agent Usage

Use subagents only for clear parallel work.

- Explorer agents: codebase audits, CI review, Firebase rules review, test gap review.
- Worker agents: isolated implementation tasks with clear file ownership.
- Lead agent: final integration, consistency checks, and release notes.

For now, the project should use these documents as the source of truth. Custom Codex skills can be added later if the same workflow repeats often enough to justify them.
