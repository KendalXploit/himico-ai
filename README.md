# HIMICO AI

**Institutional Futures Trading Assistant** — a native Flutter mobile app
(Android + iOS) for USDT-M crypto futures traders: market scanning,
AI-scored trade signals, deep technical analysis, backtesting, and a
persistent trade journal — wrapped in a dark, cyberpunk, glassmorphic UI.

This is a full Flutter application, not a bot or a web app. It compiles
to a native Android APK (and iOS, with one extra one-time step — see
`ios/README.md`).

---

## Features

| Module | What it does |
|---|---|
| **Dashboard** | BTC/ETH/SOL/XRP/BNB/ADA/DOGE watch row, Fear & Greed + BTC Dominance gauges, top gainers/losers |
| **Market Scanner** | Scans USDT-M futures pairs for breakouts, retests, order blocks, FVGs, volume spikes, supply/demand zones, S/R |
| **AI Signals** | Full signal cards — direction, entry, SL, TP1–3, confidence. **Signals below 90% confidence always render as "NO TRADE."** |
| **AI Analysis** | Per-symbol scorecard across EMA, ADX, ATR, S/R, Supply/Demand, Order Blocks, Liquidity, BOS/CHoCH, FVG, VWAP, Volume, Price Action, Trend, Sentiment, Open Interest, Funding Rate |
| **Chart** | Candlestick-style price chart with timeframe switcher |
| **Backtest** | Win rate, profit factor, max drawdown, equity curve, monthly performance, trade log, CSV export |
| **Trade Journal** | Persisted (Hive) log of every trade: entry, exit, reason, screenshot, result, notes |
| **Portfolio** | Equity, open positions, allocation breakdown |
| **Settings** | Theme, notifications, language, exchange, API keys (encrypted), risk-per-trade & leverage defaults |

## Design

Dark-only, Material 3, cyberpunk black/blue neon palette, glassmorphic
cards (`BackdropFilter` + translucent borders + neon glow shadows),
Orbitron display type + Inter body type, smooth micro-animations
(`animate_do`, animated confidence meters, live-price pulse dot).

---

## Architecture

**Clean Architecture, feature-first**, so every module can be developed,
tested, and reasoned about independently:

```
lib/
  core/                      # Cross-cutting: shared by every feature
    config/                  # Env loading (.env)
    constants/               # App-wide constants (symbols, thresholds, box names)
    di/                      # Root Riverpod DI graph (Dio, SecureStorage)
    errors/                  # Sealed AppException hierarchy
    network/                 # DioClient (Binance Futures REST base)
    router/                  # go_router config (StatefulShellRoute)
    theme/                   # AppColors, AppTypography, AppTheme
    widgets/                 # GlassCard, NeonBadge, LiveDot — the shared design system

  features/
    <feature>/
      data/
        models/              # Hive/JSON models (e.g. JournalEntryModel)
        repositories/        # Concrete repository implementations
      domain/
        entities/            # Pure Dart domain entities
        repositories/        # Repository interfaces (contracts)
      presentation/
        providers/           # Riverpod providers / controllers
        screens/              
        widgets/
```

Features included: `dashboard`, `scanner`, `signals`, `ai_analysis`,
`chart`, `backtest`, `journal`, `watchlist`, `portfolio`, `settings`,
`shell` (bottom-nav scaffold).

**Principles applied:**
- **Repository pattern** — presentation never talks to Dio/Hive directly;
  it goes through providers that abstract the data source, so swapping
  mock data for a live exchange feed touches only the `data/` layer.
- **SOLID** — e.g. `AppException` is a small sealed hierarchy so UI code
  branches on failure *kind*, not on Dio/Hive-specific exception types.
- **Dependency Injection** — `core/di/core_providers.dart` is the single
  source of `Dio`/`FlutterSecureStorage` instances; Hive boxes are opened
  once in `main.dart` and injected via `ProviderScope` overrides.
- **State management** — Riverpod throughout (`Provider`, `StateProvider`,
  `StateNotifierProvider`, `Provider.family`).

### Current data status

Market data, scanner results, signals, and backtest history currently
ship with **deterministic mock generators** (seeded `Random`) so the full
UI is explorable and demoable with zero configuration. Each mock lives
next to a comment pointing at the extension seam — e.g.
`market_data_providers.dart` documents exactly where to swap in a real
`MarketDataRepository` backed by the Binance Futures REST/WebSocket API
(`DioClient` is already wired to `https://fapi.binance.com`). The Trade
Journal and Settings are **not** mocked — they're backed by real Hive
boxes and `flutter_secure_storage`, and persist across restarts today.

---

## Tech stack

- **State management:** flutter_riverpod
- **Routing:** go_router (`StatefulShellRoute.indexedStack` — each bottom
  tab keeps its own back stack)
- **Networking:** dio + web_socket_channel
- **Local database:** hive / hive_flutter (Trade Journal, Settings)
- **Secure storage:** flutter_secure_storage (exchange API keys)
- **Charts:** fl_chart (line, bar/candlestick, pie)
- **UI:** google_fonts (Orbitron + Inter), glassmorphism-style custom
  `GlassCard`, percent_indicator, shimmer, animate_do
- **CSV export:** csv + share_plus
- **Dart 3, null safety, Material 3, flutter_lints**

---

## Getting started

### Prerequisites
- Flutter SDK ≥ 3.19 (Dart ≥ 3.3), stable channel
- Android Studio or a configured Android SDK (`ANDROID_HOME`) for the APK build
- Xcode 15+ only if you intend to build for iOS

### Setup

```bash
flutter pub get
cp .env.example .env   # already provided with sensible public-API defaults
```

`android/local.properties` ships with placeholder SDK paths — Android
Studio will rewrite it automatically on first open, or set it manually:

```properties
sdk.dir=/path/to/Android/sdk
flutter.sdk=/path/to/flutter
```

### Run

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

(The default `release` build type signs with the debug keystore so this
succeeds out of the box for testing/distribution to yourself. Replace
`android/app/build.gradle`'s `signingConfig` with a real release keystore
before publishing to the Play Store.)

### iOS

The `ios/` folder contains every hand-customized file (Info.plist,
AppDelegate, storyboards, app icons, Podfile). The one file intentionally
not included is the machine-generated `project.pbxproj` — see
`ios/README.md` for the one-command step to generate it.

### Tests

```bash
flutter test
```

Includes a widget smoke test for the Dashboard and unit tests for the
core "≥90% confidence or NO TRADE" signal rule.

### Code generation (optional)

Hive's `JournalEntryModelAdapter` is checked in hand-written (matching
build_runner's output exactly) so the project builds with zero codegen
steps. If you modify `@HiveField`s or add `freezed`/`json_serializable`
models, regenerate with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Project structure at a glance

```
himico_ai/
  android/              # Complete Gradle project (Kotlin, Material3 launch theme, HIMICO icon)
  ios/                  # Info.plist, AppDelegate, storyboards, AppIcon set, Podfile
  assets/
    images/             # app_logo.png
    icons/
    fonts/              # reserved for future bundled fonts (currently unused — see note)
    lottie/
  lib/
    core/
    features/
    main.dart
  test/
  pubspec.yaml
  analysis_options.yaml
  .env / .env.example
```

> **Note on fonts:** every text style in the app is driven by `AppTypography`
> (`lib/core/theme/app_typography.dart`), which uses `google_fonts` to fetch
> Orbitron, Inter, and JetBrains Mono at runtime and cache them on-device.
> No static `.ttf` files need to be bundled for the app to look correct —
> `assets/fonts/` is kept as an empty, ready-to-use folder if you'd rather
> ship fonts offline for fully airplane-mode first-run rendering; just drop
> the `.ttf` files in and add a matching `fonts:` block to `pubspec.yaml`.

---

## Disclaimer

HIMICO AI is a trading **assistant**, not an automated execution system.
It never places trades on your behalf. All signals, backtests, and
analytics are for informational purposes — trading crypto futures
carries substantial risk of loss.
