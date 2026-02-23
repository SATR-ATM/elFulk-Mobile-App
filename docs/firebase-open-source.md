# Firebase Setup for Public Repository

This repository follows a split policy:

- Development Firebase config is committed.
- Production Firebase config is local/CI only and must not be committed.

## Committed (development)

- `android/app/src/development/google-services.json`
- `ios/config/development/GoogleService-Info.plist`
- `lib/firebase_options_development.dart`

## Not committed (production)

- `android/app/src/production/google-services.json`
- `ios/config/production/GoogleService-Info.plist`
- `lib/firebase_options_production.dart`

Production files are ignored by `.gitignore`.

## Templates

Reference templates are included:

- `android/app/src/production/google-services.example.json`
- `ios/config/production/GoogleService-Info.example.plist`
- `lib/firebase_options_production.example.dart`

## Contributor setup (development)

1. Install dependencies:
```bash
flutter pub get
```
2. Run development flavor:
```bash
flutter run --flavor development -t lib/main_development.dart
```

## Maintainer setup (production, local only)

Generate production files locally:

```bash
flutterfire configure \
  --project=<PROD_FIREBASE_PROJECT_ID> \
  --platforms=android,ios \
  --android-package-name=com.elfulk \
  --ios-bundle-id=com.elfulk \
  --out=lib/firebase_options_production.dart \
  --android-out=android/app/src/production/google-services.json \
  --ios-out=ios/config/production/GoogleService-Info.plist \
  --yes
```

Run production flavor:

```bash
flutter run --flavor production -t lib/main_production.dart
```

## Safe commit check

Before pushing, verify no production config is staged:

```bash
git status --short
```
