# 🦎 Toem Here!

> Discover, photograph, name, and collect monitor lizards across Bangkok's parks!

[![CI](https://github.com/YOUR_USERNAME/toem-here/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/toem-here/actions/workflows/ci.yml)
[![CD](https://github.com/YOUR_USERNAME/toem-here/actions/workflows/cd-release.yml/badge.svg)](https://github.com/YOUR_USERNAME/toem-here/actions/workflows/cd-release.yml)
[![codecov](https://codecov.io/gh/YOUR_USERNAME/toem-here/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/toem-here)

---

## Features

- 📸 **Snap & Name** — Photograph monitor lizards and give each one a unique name
- 🗺️ **Live Map** — See real-time sighting locations across Bangkok parks
- 🏆 **Cuteness Ranking** — Vote for the cutest monitor lizard (All Time / Weekly / New)
- 🎯 **Collection System** — Collect all discovered monitors, track your progress
- 🏅 **Achievements** — Unlock badges for completing challenges
- ⚡ **Rarity System** — Common, Rare, Epic, Legendary classifications
- 🔔 **Live Alerts** — Get notified when someone spots a monitor nearby
- 🧬 **Personality Profiles** — Each lizard has a unique personality description
- 🔥 **Sighting Streaks** — Track consecutive days a monitor is spotted
- 📤 **Social Sharing** — Share your finds with friends

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.24+ (Dart 3.5+) |
| State Management | Riverpod + Freezed |
| Navigation | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage, Messaging) |
| Maps | Google Maps Flutter |
| AI Detection | Google ML Kit + TFLite |
| Local Storage | Hive |
| CI/CD | GitHub Actions → Google Play + TestFlight |

---

## Project Structure

```
lib/
├── main.dart                       # App entry point
├── app.dart                        # Root widget
├── firebase_options.dart           # Firebase config (generated)
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Colors, typography, theme
│   ├── router/
│   │   └── app_router.dart         # GoRouter configuration
│   ├── constants/                  # App-wide constants
│   ├── utils/                      # Helpers, extensions
│   └── widgets/                    # Shared widgets
├── features/
│   ├── auth/
│   │   ├── domain/models/          # User, Achievement models
│   │   ├── data/                   # Auth repository
│   │   └── presentation/screens/  # Login, Onboarding
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/            # HomeScreen
│   │       └── widgets/            # LiveSighting, RankingPreview...
│   ├── monitor/
│   │   ├── domain/models/          # Monitor, Sighting models
│   │   ├── data/                   # MonitorRepository
│   │   └── presentation/
│   │       ├── providers/          # Riverpod providers
│   │       └── screens/            # MonitorDetailScreen
│   ├── map/                        # Map feature
│   ├── camera/                     # Camera + AI detection
│   ├── ranking/                    # Voting & rankings
│   ├── profile/                    # User profile & stats
│   └── shell/                      # MainShell (bottom nav)
└── test/
    ├── unit/                       # Unit tests
    ├── widget/                     # Widget tests
    └── integration/                # Integration tests
```

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.24.0
- Dart >= 3.5.0
- Android Studio / Xcode
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### 1. Clone & Install

```bash
git clone https://github.com/YOUR_USERNAME/toem-here.git
cd toem-here
flutter pub get
```

### 2. Firebase Setup

```bash
# Login to Firebase
firebase login

# Configure Firebase for this project
flutterfire configure --project=toem-here

# This generates lib/firebase_options.dart automatically
```

### 3. Google Maps API Key

Add your API key:

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 4. Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run

```bash
# Debug
flutter run

# Release
flutter run --release
```

---

## Git Workflow & Branching Strategy

We use **Git Flow**:

```
main          ← Production releases (tagged v1.x.x)
  └── develop ← Integration branch
        ├── feature/camera-ai       ← New features
        ├── bugfix/vote-count        ← Bug fixes
        ├── hotfix/crash-on-launch   ← Urgent production fixes
        └── chore/update-deps        ← Maintenance
```

### Branch Naming Convention

```
feature/short-description     # New feature
bugfix/short-description      # Bug fix
hotfix/short-description      # Urgent production fix
chore/short-description       # Maintenance / deps
refactor/short-description    # Code refactor
docs/short-description        # Documentation
test/short-description        # Test improvements
```

### Commit Convention (Conventional Commits)

```
feat: add monitor voting system
fix: resolve crash on camera screen
docs: update README setup steps
style: format ranking screen
refactor: extract sighting card widget
test: add monitor model unit tests
chore: update Flutter to 3.24.3
ci: add iOS build to pipeline
```

---

## CI/CD Pipeline

### CI (Every Push & PR → `main`, `develop`)

```
┌──────────┐    ┌──────────┐    ┌───────────────┐
│ Analyze  │───▶│   Test   │───▶│ Build Android │
│ & Lint   │    │ (unit +  │    │ (APK / AAB)   │
│          │    │  widget) │    └───────────────┘
└──────────┘    └──────────┘    ┌───────────────┐
                            ───▶│  Build iOS    │
                                │ (no codesign) │
                                └───────────────┘
```

### CD (On version tag `v*.*.*`)

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────┐
│ Create GitHub   │───▶│ Build & Deploy   │───▶│ Google Play │
│ Release +       │    │ Android AAB      │    │ (Internal)  │
│ Changelog       │    └──────────────────┘    └─────────────┘
│                 │    ┌──────────────────┐    ┌─────────────┐
│                 │───▶│ Build & Deploy   │───▶│ TestFlight  │
│                 │    │ iOS IPA          │    │             │
└─────────────────┘    └──────────────────┘    └─────────────┘
```

### Release a New Version

```bash
# 1. Bump version in pubspec.yaml
# version: 1.1.0+2

# 2. Commit
git add .
git commit -m "chore: bump version to 1.1.0"

# 3. Tag & Push
git tag v1.1.0
git push origin main --tags

# CD pipeline auto-deploys to Play Store & TestFlight ✨
```

---

## GitHub Secrets Required

Set these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `.jks` keystore file |
| `ANDROID_KEY_PROPERTIES` | Content of `key.properties` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | Google Play service account JSON |
| `IOS_BUILD_CERTIFICATE_BASE64` | Base64-encoded `.p12` certificate |
| `IOS_P12_PASSWORD` | Certificate password |
| `IOS_PROVISION_PROFILE_BASE64` | Base64-encoded provisioning profile |
| `IOS_KEYCHAIN_PASSWORD` | Temporary keychain password |
| `APP_STORE_API_KEY_ID` | App Store Connect API Key ID |
| `APP_STORE_ISSUER_ID` | App Store Connect Issuer ID |
| `APP_STORE_API_KEY` | App Store Connect API Key (`.p8` content) |
| `CODECOV_TOKEN` | Codecov upload token |

### Generate Android Keystore

```bash
keytool -genkey -v -keystore toem-here.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias toem-here

# Encode to base64
base64 -i toem-here.jks | pbcopy
```

---

## Firestore Data Structure

```
monitors/
  {monitorId}/
    name: "ลุงสมชาย"
    nickname: "Uncle Somchai"
    photoUrl: "..."
    parkName: "สวนลุมพินี"
    votes: 2847
    rarity: "legendary"
    lastSeenAt: Timestamp
    voters/
      {userId}/
        votedAt: Timestamp

sightings/
  {sightingId}/
    monitorId: "..."
    userId: "..."
    photoUrl: "..."
    latitude: 13.73
    longitude: 100.54
    spottedAt: Timestamp

users/
  {uid}/
    displayName: "..."
    level: 5
    totalCollected: 3
    achievements: [...]
    collectedMonitorIds: [...]
```

---

## Contributing

1. Fork the repo
2. Create your branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is proprietary. All rights reserved.

---

<p align="center">
  Made with 🦎💚 in Bangkok
</p>
