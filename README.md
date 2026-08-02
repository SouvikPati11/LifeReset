# LifeReset

**LifeReset** is an AI-powered self‑recovery application. **Version 1 supports Breakup Recovery.**

This repository currently contains the **production project foundation** — the
architecture, theming, routing, state management, localization and reusable UI
scaffolding on top of which the feature modules will be built. Feature logic
(auth, database, screens) is intentionally **not** implemented yet; only a
branded splash placeholder ships in this build.

## Tech stack

- **Flutter** (latest stable) · **Material 3**
- **Riverpod** for state management
- **GoRouter** for navigation
- **Firebase** — Authentication, Cloud Firestore, Storage, Cloud Messaging, Cloud Functions
- **Google Gemini API** for AI coaching
- **Razorpay** for subscriptions
- **GitHub Actions** for CI

## Architecture

Clean architecture with a feature‑first layout:

```
lib/
├── main.dart                  # Entry point: bootstrap + ProviderScope
├── app.dart                   # Root MaterialApp.router (theme, l10n, router)
├── firebase_options.dart      # Placeholder — regenerate with `flutterfire configure`
├── config/                    # AppConfig, Environment, config providers
├── core/                      # Cross-cutting foundation
│   ├── constants/             # App/size/asset constants
│   ├── errors/                # Exceptions + Failures
│   ├── localization/          # Locale controller + supported locales
│   └── utils/                 # Result type, logger
├── theme/                     # Material 3 light/dark themes, colors, typography
├── routing/                   # GoRouter config + route names
├── shared/                    # Reusable, cross-feature building blocks
│   ├── widgets/               # Loading / Error / Empty / Success states, buttons, layout
│   ├── services/              # FirebaseService (init)
│   ├── repositories/          # BaseRepository (exception → Failure mapping)
│   └── models/                # Entity / Serializable base types
├── features/                  # Feature modules (data / domain / presentation)
│   ├── authentication/
│   ├── onboarding/            # ← splash placeholder implemented here
│   ├── subscription/
│   ├── home/
│   ├── coach/
│   ├── journal/
│   ├── progress/
│   ├── profile/
│   └── admin/
└── l10n/                      # ARB translation sources (en, es)
```

Each feature follows the same three layers:

- **data** — data sources, DTO models, repository implementations
- **domain** — entities, repository contracts, use cases
- **presentation** — screens, widgets, Riverpod controllers

## Getting started

> Requires the Flutter SDK (latest stable).

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Generate platform folders (android/ios/web/…) — kept out of VCS
flutter create .

# 3. Configure Firebase (overwrites the placeholder firebase_options.dart)
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Run
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=GEMINI_API_KEY=your_key \
  --dart-define=RAZORPAY_KEY_ID=your_key
```

Localizations are generated automatically on build (`generate: true` in
`pubspec.yaml`); run `flutter gen-l10n` to regenerate them manually.

## Configuration & secrets

Secrets are **never** committed. They are injected at build time via
`--dart-define` and read through `AppConfig` / `Environment`:

| Variable          | Purpose                          |
| ----------------- | -------------------------------- |
| `APP_ENV`         | `development` / `staging` / `production` |
| `GEMINI_API_KEY`  | Google Gemini API key            |
| `RAZORPAY_KEY_ID` | Razorpay public key id           |

Firebase credentials live in `firebase_options.dart` (and the native
`google-services.json` / `GoogleService-Info.plist`), all of which are
git‑ignored and generated per environment.

## Continuous integration

`.github/workflows/ci.yaml` runs on every push and pull request:
`pub get` → `gen-l10n` → format check → `flutter analyze` → `flutter test`.
