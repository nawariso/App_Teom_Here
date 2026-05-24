# User Stories

## Onboarding And Auth

As a new user, I want to understand what Toem Here! does so that I know why I should continue.

Acceptance criteria:

- The first experience explains discovery, sightings, ranking, and collection.
- The user can continue to sign in.
- The user can reach the main app after authentication or demo mode.

As a returning user, I want to open the app directly to the main experience so that I can quickly check sightings.

Acceptance criteria:

- Authenticated users are routed to the main shell.
- Loading and error states are handled.

## Home

As a user, I want to see recent sightings and popular monitors so that I can quickly understand current activity.

Acceptance criteria:

- Home shows recent sighting cards.
- Home shows a ranking preview.
- Tapping a monitor opens its detail screen.

## Monitor Detail

As a user, I want to view a monitor profile so that I can learn its name, park, rarity, photos, and latest sighting.

Acceptance criteria:

- Detail screen shows profile fields from Firestore or demo data.
- Missing optional photos do not break layout.
- User can vote if authenticated.

## Ranking

As a user, I want to rank monitors by cuteness/popularity so that the community can celebrate favorites.

Acceptance criteria:

- Ranking list is sorted by votes.
- Vote count is visible.
- Vote/unvote updates the count.

## Map

As a user, I want to see where monitors were spotted so that I can explore park activity.

Acceptance criteria:

- Map centers on Bangkok by default.
- Known monitor locations appear as markers or park summaries.
- Tapping a marker opens related monitor or park detail.

## Sighting Submission

As a user, I want to submit a monitor sighting with a photo and location so that others can discover it.

Acceptance criteria:

- User can select or capture a photo.
- App captures or requests location.
- User can select/confirm park.
- Submit creates a sighting record.
- Related monitor last-seen information updates.

## Profile And Collection

As a user, I want to see my collected monitors and stats so that I feel progression.

Acceptance criteria:

- Profile shows display name.
- Profile shows total collected.
- Profile shows simple progress toward collection goal.
