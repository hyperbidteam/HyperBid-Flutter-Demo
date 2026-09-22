# HyperBid Flutter SDK Demo

A minimal, public-facing reference app for integrating the **HyperBid Flutter
SDK** (`mc_sdk`). Every API call in this project follows the official
HyperBid Flutter integration documentation verbatim, so it can be used as a
copy-paste starting point for a real integration.

One screen per ad format, each screen mapped to exactly one documentation page.

## Ad format coverage

| Screen        | Integration paths            |
| ------------- | ---------------------------- |
| Interstitial  | Smart Cache + Manual Loading |
| Rewarded Video| Smart Cache + Manual Loading |
| App Open      | Smart Cache + Manual Loading |
| Banner        | Programmatic + Widget        |
| MREC          | Programmatic + Widget        |
| Native        | Widget (self-rendering)      |

> Smart Cache is the recommended default for full-screen formats — it manages
> parallel loading, caching and the waterfall automatically and needs no
> Mediation Unit ID.

## Project structure

```
lib/
├── main.dart                  SDK initialization + app entry
├── ad_config.dart             App ID / App Key / Mediation Unit ID placeholders
├── widgets/
│   └── event_console.dart     Shared in-app callback log (no SDK dependency)
└── screens/
    ├── home_screen.dart       Navigation menu
    ├── interstitial_screen.dart
    ├── rewarded_screen.dart
    ├── app_open_screen.dart
    ├── banner_screen.dart
    ├── mrec_screen.dart
    └── native_screen.dart
```

## Getting started

### 1. Install dependencies

Verified with Flutter 3.47.4 (`fvm`); other recent stable versions should work
as well.

```bash
flutter pub get
```

The HyperBid Flutter SDK (`mc_sdk ^1.1.0`) is pulled from pub.dev as a
regular dependency — no manual download or path setup is required after
cloning.

To update to a newer SDK version, bump the `mc_sdk` version in
`pubspec.yaml` and run `flutter pub upgrade mc_sdk`.

### 2. Configure your credentials

Open [`lib/ad_config.dart`](lib/ad_config.dart) and replace every placeholder
with the real values from your HyperBid dashboard:

- `appId`, `appKey` — used by `McSdk.initialize()`
- the per-format `*AdUnitId` values — Mediation Unit IDs

### 3. Ad Network adapters

- **Android** — the core SDK and a default set of Ad Network adapters are
  already wired in via [`android/app/mcsdk.gradle`](android/app/mcsdk.gradle),
  applied from `android/app/build.gradle.kts`. Regenerate that file from the
  [SDK Download Center](https://portal.hyperbid.com/m/sdk/download) to change
  SDK versions or the set of integrated networks.
- **iOS** — the core SDK and the matching Ad Network adapter pods are listed
  in [`ios/Podfile`](ios/Podfile). Install them with
  `cd ios && pod install --repo-update`, then open `ios/Runner.xcworkspace`.

The required `Info.plist` / `AndroidManifest.xml` entries are already in place
in this project (AdMob application id, ATT usage description, SKAdNetwork items,
permissions).

### 4. Run

```bash
# Android
flutter run

# iOS — install pods first, then run (or open ios/Runner.xcworkspace in Xcode)
cd ios && pod install --repo-update && cd ..
flutter run
```

## Initialization

`McSdk.initialize()` is called once in `main.dart`. **All** global
configuration — verbose logging, custom traffic segmentation, privacy
compliance (GDPR / CCPA / COPPA), and preset strategy — must be called
**before** `initialize()`. The optional calls are present as commented
examples in `_initializeSdk()`.

## Notes

- `McSdk.setVerboseLogging(true)` is enabled for development. **Disable it
  before releasing to production.**
- The in-app event console surfaces every SDK callback so integration can be
  verified on-device without reading platform logs.
- Privacy compliance APIs are intentionally left commented out — enable and
  configure them according to the regions your app ships to.
