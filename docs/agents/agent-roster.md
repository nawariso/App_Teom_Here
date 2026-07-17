# Agent Roster

## Product Manager Agent

Owns product priority, milestone scope, release boundaries, roadmap, risks, and decision records.

Primary docs:

- `docs/product/vision.md`
- `docs/product/mvp-scope.md`
- `docs/product/future-features.md`

## Business Analyst Agent

Owns user stories, business rules, edge cases, acceptance criteria, and workflow completeness.

Primary docs:

- `docs/product/user-stories.md`
- `docs/product/mvp-scope.md`

## Solution Architect Agent

Owns Flutter architecture, feature boundaries, dependency choices, app layering, and technical tradeoffs.

Primary docs:

- `docs/architecture/overview.md`
- `docs/architecture/data-model.md`

## Enterprise Architect Agent

Owns long-term platform direction, integration boundaries, non-functional requirements, governance, and technology fit.

Primary docs:

- `docs/product/vision.md`
- `docs/architecture/overview.md`
- `docs/infra/setup.md`

## Data Agent

Owns data semantics, ranking rules, analytics events, demo data, and collection/voting logic.

Primary docs:

- `docs/architecture/data-model.md`
- `assets/data/`

## DBA Agent

Owns Firestore schema, indexes, security-rule data access review, migration approach, and data integrity.

Primary docs:

- `docs/architecture/data-model.md`
- `firestore.rules`

## UX/UI Agent

Owns flows, screen behavior, visual design, accessibility, responsive layout, and Thai/English text display quality.

Primary docs:

- `docs/design/ux-ui-guidelines.md`
- `lib/features/*/presentation/`

## Developer Agent

Owns implementation, tests, local verification, and scoped code changes.

Primary docs:

- `README.md`
- `docs/architecture/overview.md`
- `analysis_options.yaml`

## QA Agent

Owns test strategy, regression checklists, reproduction steps, release readiness, and quality risk.

Primary docs:

- `docs/qa/test-plan.md`
- `test/`

## Infrastructure Agent

Owns local setup, Firebase setup, Google Maps setup, secrets documentation, platform build setup, and environment reproducibility.

Primary docs:

- `docs/infra/setup.md`
- `.env.example`
- `.github/workflows/`

## DevOps Agent

Owns CI/CD, quality gates, release automation, deployment workflow, branch strategy, and build reliability.

Primary docs:

- `.github/workflows/`
- `README.md`

## Security And Privacy Agent

Owns privacy, location safety, Firestore rules review, abuse-risk review, and secret-handling review.

Primary docs:

- `firestore.rules`
- `docs/architecture/data-model.md`
- `docs/infra/setup.md`
