# Talko — Daily Questions

[![Download on the App Store](https://img.shields.io/badge/Download-App%20Store-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/ua/app/talko-daily-questions/id6780755565)

A daily question app that sparks meaningful conversations between couples, families, and friends.

**[Download on the App Store →](https://apps.apple.com/ua/app/talko-daily-questions/id6780755565)**

**Platform:** iOS 17+ (iPhone & iPad)  
**Category:** Word Games  
**Languages:** English · Ukrainian

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Content & Data](#content--data)
- [Localization](#localization)
- [Widgets (WidgetKit)](#widgets-widgetkit)
- [Premium & Subscriptions](#premium--subscriptions)
- [Persistence](#persistence)
- [Badges System](#badges-system)
- [Theming](#theming)
- [Navigation](#navigation)
- [Content Guidelines](#content-guidelines)
- [Adding New Content](#adding-new-content)

---

## Overview

Talko is a SwiftUI app that delivers daily conversation-starter questions organized by category and subcategory. Users swipe through question cards, like favorites, unlock premium content, and add home-screen widgets that surface questions at a glance.

---

## Project Structure

```
Talk/
├── TalkApp.swift               # App entry point, DI root
├── Core/
│   ├── AppCoordinator.swift    # Navigation state (push / sheet / fullScreenCover)
│   └── Views/
│       └── NavigationBar.swift # Custom nav bar (never use .navigationTitle)
├── Clients/
│   ├── QuestionClient.swift    # Loads JSON content, syncs widget data
│   ├── PremiumClient.swift     # StoreKit 2 purchases & entitlement checks
│   ├── LanguageClient.swift    # Language selection & bundle switching
│   ├── ThemeClient.swift       # Light / Dark theme + Combine publisher
│   ├── BadgesClient.swift      # Badge calculation logic (pure function)
│   ├── BadgeImageClient.swift  # Remote badge image download + disk/memory cache
│   ├── UserDefaultsClient.swift# Typed UserDefaults wrapper
│   ├── LikesStore.swift        # @MainActor @Observable; manages liked question IDs
│   └── MigrationClient.swift   # One-time migration from legacy UserDefaults keys
├── Model/
│   ├── Category.swift          # Category / Subcategory / CardQuestion models
│   └── DailyQuestion.swift     # DailyQuestion + DailyQuestionsPayload
├── Feature/
│   ├── Splash/                 # SplashView + SplashState (@Observable)
│   ├── TabBar/                 # TabBarView, LiquidGlassTabBar, AppTab
│   ├── Home/                   # HomeView + HomeViewModel
│   ├── Question/               # QuestionView + QuestionViewModel
│   ├── LikedQuestions/         # LikedQuestionsView + LikedQuestionsViewModel
│   ├── Badges/                 # BadgesView + BadgesViewModel + BadgeDetailView
│   │   └── Components/
│   │       ├── BadgeRow.swift          # Grid cell; earned → RemoteBadgeImage
│   │       └── RemoteBadgeImage.swift  # Async image with loading/error states
│   ├── Settings/               # SettingsView + SettingsViewModel
│   ├── Subscription/           # SubscriptionView + SubscriptionViewModel
│   └── Document/               # DocumentView — in-app HTML viewer (ToS, Privacy)
├── Utility/
│   └── Colors.swift            # Colors enum with asset catalog references
└── Resources/
    ├── Localizable.xcstrings   # String catalog (EN + UK)
    ├── Colors.xcassets/        # Brand color assets
    └── Documents/              # privacy_policy_*.html, terms_of_use_*.html, support_*.html

Shared/                         # Compiled into both the app and the widget extension
├── AppGroupKey.swift           # App Group suite name & shared UserDefaults keys
├── WidgetCategoryPayload.swift # Codable payload for category widgets
└── WidgetCenterProtocol.swift  # WidgetCenter abstraction for tests

DailyQuestionWidget/
├── WidgetFallback.swift        # Localized fallback strings for widgets
├── Localizable.xcstrings       # Widget-target String catalog (EN + UK)
├── Daily/                      # DailyQuestionWidget (small + medium)
│   ├── DailyProvider.swift     # 7-day timeline generated from bundled daily.json
│   └── DailyQuestionWidget.swift
└── Category/                   # Per-category widgets (large only)
    ├── CategoryProvider.swift
    ├── CategoryQuestionWidget.swift
    ├── Views/
    │   └── LargeWidgetView.swift
    └── WidgetCategoryIntent.swift  # NextQuestionIntent, PrevQuestionIntent
```

---

## Architecture

- **SwiftUI** with `@Observable` (iOS 17 Observation framework) — no Combine in ViewModels. Combine is used only in `LanguageClient` (`languagePublisher`) and `ThemeClient` (`themePublisher`) where external observers need a publisher interface.
- **Environment-driven DI** — all clients (`PremiumClient`, `LanguageClient`, `ThemeClient`, `QuestionClientHolder`) are injected via a single `appEnvironment(...)` view modifier at the app root (`TalkApp`).
- **Splash gate** — `TalkApp` checks `SplashState.isFinished` (`@Observable`) before switching from `SplashView` to `TabBarView`. Both branches share the same `appEnvironment(...)` set of environment objects.
- **One-shot ViewModel setup** — ViewModels receive their client dependencies once via `setup(...)` (called from the view's `onAppear`/`task`); async methods like `loadContent()`, `purchase()` and `restorePurchases()` are parameterless and explicitly `async` so tests can await them directly.
- **Actor-isolated data layer** — `QuestionClient` and `BadgeImageClient` are Swift `actor`s to guarantee thread-safe data access.
- **Coordinator pattern** — `AppCoordinator` owns `NavigationPath`, `sheet`, and `fullScreenCover` state. Views call `coordinator.push()`, `coordinator.present()`, `coordinator.dismiss()`.
- **BaseViewModel** — shared base class for `isLoading` and `errorMessage` state.

### Client Responsibilities

| Client | Role |
|---|---|
| `QuestionClient` | Loads `couple.json`, `family.json`, `friends.json`, `daily.json` from the localized bundle; writes the per-category widget payload to App Group UserDefaults |
| `PremiumClient` | StoreKit 2 — `fetchAvailableProducts`, `purchase`, `restorePurchases`, `checkPremiumStatus`, background transaction listener; persists `isPremium` to the App Group and reloads widgets on every change |
| `LanguageClient` | Persists selected language; exposes `bundle` computed property and `languagePublisher` (Combine) for observers |
| `ThemeClient` | Persists selected theme; exposes `themePublisher` (Combine); controls `preferredColorScheme` at app root |
| `BadgesClient` | Pure static function — computes badge earned/locked state from subcategory progress in `UserDefaults` |
| `BadgeImageClient` | Actor — downloads earned badge PNGs from `Talko-content` CDN, caches on disk (`Caches/BadgeImages/`) and in memory; deduplicates parallel requests |
| `UserDefaultsClient` | Generic `Codable` read/write wrapper around `UserDefaults.standard` (app-only keys) |
| `LikesStore` | `@MainActor @Observable` — manages liked question IDs; replaces direct `UserDefaultsClient.likedQuestions` access from views |
| `MigrationClient` | One-time migration from legacy keys (`favorites`, `lastQuestionIndex_*`, standard-defaults `isPremium`) to current storage (`likedQuestions`, `subcategoryProgress`, App Group `isPremium`); run in `TalkApp.init()` |
| `SplashState` | `@Observable` class; `isFinished` gates the transition from `SplashView` to `TabBarView` |

---

## Content & Data

All question content lives in **JSON files inside localized `.lproj` bundles** — no backend, no network calls for questions. Badge images are fetched remotely (see [Badges System](#badges-system)).

### Category JSON (`couple.json`, `family.json`, `friends.json`)

```json
{
  "id": "couple",
  "name": "Couple",
  "emoji": "💑",
  "subcategories": [
    {
      "id": "couple_romance",
      "name": "Romance",
      "emoji": "❤️",
      "description": "Questions about love and connection.",
      "isPremium": false,
      "questions": [
        { "id": "q_001", "text": "What was your first impression of me?" }
      ]
    }
  ]
}
```

### Daily Question JSON (`daily.json`)

```json
{
  "questions": [
    "What made you smile today?",
    "..."
  ],
  "holidays": {
    "12-25": "What is your favorite holiday tradition?",
    "01-01": "What is your intention for this new year?"
  }
}
```

**Daily question selection logic:**
1. Check `holidays` dict using key `"MM-dd"` for today's date — if found, use it.
2. Otherwise, use `(dayOfYear - 1) % questions.count` to pick deterministically from the array.

---

## Localization

The app supports **English (`en`)** and **Ukrainian (`uk`)**. The default language on first launch is **Ukrainian**.

### How it works

- `AppLanguage` enum: `.ukrainian = "uk"`, `.english = "en"`
- `LanguageClient` computes the matching `.lproj` `Bundle` via a `bundle` computed property and exposes it via `\.languageBundle` environment key and `languagePublisher` (Combine) for reactive observers.
- All `Text(...)` calls use `String(localized: "key", bundle: bundle)` — **not** the system locale, but the user-selected language bundle.
- UI strings live in `Localizable.xcstrings` (string catalog). Question JSON files are duplicated per language inside their respective `.lproj` bundles within the main app bundle.

### Rules for content files

- Keep `en.lproj/` and `uk.lproj/` in sync: same file names, same question IDs, same structure.
- Question `id` must be identical across languages (used for likes and progress tracking).
- `daily.json` holiday keys (`"MM-dd"`) must be present in both language files.

---

## Widgets (WidgetKit)

The widget extension uses **App Group** `group.com.voloshanov.talk.shared` for data sharing.

### Widget Types

| Widget | Kind | Sizes | Description |
|---|---|---|---|
| `DailyQuestionWidget` | `DailyQuestionWidget` | small, medium | Shows today's daily question; timeline covers 7 days ahead and rolls over at midnight without opening the app |
| `CoupleQuestionWidget` | `CategoryWidget_couple` | large | Interactive question browser for the Couple category |
| `FamilyQuestionWidget` | `CategoryWidget_family` | large | Interactive question browser for the Family category |
| `FriendsQuestionWidget` | `CategoryWidget_friends` | large | Interactive question browser for the Friends category |

### Data flow (App → Widget)

1. App calls `QuestionClient.loadCategories()` → writes one key per category to App Group UserDefaults:
   - `widgetCategory_{id}` — JSON-encoded `WidgetCategoryPayload { name, emoji, questions }` (questions filtered by premium status)
2. `DailyProvider` is self-sufficient: it reads `daily.json` directly from the widget bundle (language taken from the App Group `appLanguage` key) and generates 7 midnight-dated entries with an `.atEnd` reload policy. Question selection reuses the shared `DailyQuestionsPayload` logic.
3. `CategoryProvider` decodes `widgetCategory_{id}` and reads `widgetIndex_{id}` to render the current question.
4. Fallback strings shown by the widgets (`Reload`, the daily-question fallback) live in `WidgetFallback` and are localized via the widget target's String catalog (EN + UK).

### Interactive Widget (Next / Previous)

Category widgets use `AppIntent`s:
- `NextQuestionIntent` — increments `widgetIndex_{id}` in App Group UserDefaults, modulo count.
- `PrevQuestionIntent` — decrements index.

### Premium & Widgets

When `isPremium` is `false`, only non-premium subcategory questions are written to the widget payload. Every `PremiumClient.isPremium` change (purchase, restore, coupon, `Transaction.updates`) persists the flag to the App Group key `"isPremium"`, rebuilds the widget question pool via `refreshWidgetData` and calls `WidgetCenter.reloadAllTimelines()`, so category widgets show or hide the premium pool immediately.

---

## Premium & Subscriptions

Managed via **StoreKit 2** in `PremiumClient`.

### Product IDs

| Product | ID |
|---|---|
| Monthly | `com.voloshanov.talko.premium.monthly` |
| Annual | `com.voloshanov.talko.premium.annual` |

### Trial periods

- Monthly plan — 3-day free trial
- Annual plan — 7-day free trial

### Entitlement check

On every app launch, `checkPremiumStatus()` iterates `Transaction.currentEntitlements` and sets `isPremium` accordingly. A background `Task` listens for `Transaction.updates` for real-time entitlement changes (e.g. family sharing, renewals).

### Premium content

Subcategories marked `"isPremium": true` in JSON are locked for free users. Attempting to open one from `HomeView` presents `SubscriptionView` as a sheet.

---

## Persistence

All persistence uses `UserDefaults`. Two stores are used:

### `UserDefaults.standard` (app-only)

Accessed via `UserDefaultsClient` with typed `UDKey` enum:

| Key | Type | Purpose |
|---|---|---|
| `appLanguage` | `AppLanguage` | Selected UI language |
| `appTheme` | `AppTheme` | Selected color scheme |
| `likedQuestions` | `[String]` | IDs of liked questions |
| `subcategoryProgress` | `[String: Int]` | Last viewed index per subcategory |
| `didMigrateFromStorageClient` | `Bool` | One-time migration guard |

### `UserDefaults(suiteName: "group.com.voloshanov.talk.shared")` (shared with widget)

| Key | Type | Purpose |
|---|---|---|
| `isPremium` | `Bool` | **Single persisted source of truth** for premium status (read by app and widget) |
| `appLanguage` | `String` | Selected UI language (shared with widget) |
| `widgetCategory_{id}` | `Data` (JSON `WidgetCategoryPayload`) | Category name, emoji and premium-filtered question pool for the widget |
| `widgetIndex_{id}` | `Int` | Current question index in widget (mutated by widget AppIntents) |

`PremiumClient` keeps `isPremium` in memory at runtime, but the App Group is the only place it is persisted. A legacy `isPremium` value in `UserDefaults.standard` is migrated to the App Group by `MigrationClient` and the old key is deleted.

---

## Badges System

`BadgesClient.badges(for:)` is a pure function — it takes `[Category]` and returns `[String: [Badge]]` keyed by category ID.

### Badge thresholds

A badge is earned per subcategory at **10, 30, and 50** answered (liked or advanced-past) questions.

### Badge image source

Earned badge images are hosted in the public **`sashavoloshanov/Talko-content`** GitHub repository (`Badges/` folder, branch `main`) and served via jsDelivr CDN:

```
https://cdn.jsdelivr.net/gh/sashavoloshanov/Talko-content@main/Badges/{imageName}.png
```

`BadgeImageClient` (actor) downloads each image on first use, caches it on disk at `Caches/BadgeImages/`, and keeps it in memory for the session. Parallel requests for the same image are deduplicated via `inFlightTasks`. Badge images are **not** stored in the app's asset catalog (except `lockedBadgeIcon`).

### Badge image naming convention

```
badge_{subcategoryId}_{threshold}   // earned — fetched remotely by BadgeImageClient
lockedBadgeIcon                     // not yet earned — local asset
```

### Progress counting

Progress per subcategory is stored in `subcategoryProgress` UserDefaults key as `[subcategoryId: count]`.

- **Forward navigation** (`next()`) — saves `currentIndex + 1` directly.
- **Toggle like** (`toggleLike()`) — calls `incrementProgressCount()`, which uses `max(current, currentIndex + 1)` so progress never goes backwards.
- **Backward navigation** (`previous()`) — never saves progress (identical behavior in debug and release).

This means progress reflects how far into a subcategory the user has gone, not how many questions they have liked.

---

## Theming

`ThemeClient` controls the app-wide color scheme. Only **light** and **dark** are supported — there is no "system" auto mode by design.

Theme is applied at the app root via `.preferredColorScheme(themeClient.current.colorScheme)`.

All colors are defined in the `Colors` enum (`Utility/Colors.swift`) backed by the asset catalog. Never use hardcoded `Color` values — always reference `Colors.*`.

| Token | Usage |
|---|---|
| `Colors.backgroundPrimary` | Main screen backgrounds |
| `Colors.backgroundSecondary` | List rows, cards |
| `Colors.backgroundElevated` | Elevated surfaces |
| `Colors.textPrimary` | Primary text and icons |
| `Colors.textSecondary` | Secondary / muted text |
| `Colors.brandDark` | Splash background, brand accent |
| `Colors.premiumGold` | Premium CTA button, crown icon |

---

## Navigation

`AppCoordinator` manages three navigation mechanisms:

| Mechanism | Used for |
|---|---|
| `NavigationPath` (`push`) | Question flow, Liked Questions |
| `sheet` | Subscription paywall, Legal documents |
| `fullScreenCover` | Badge detail view (rendered as ZStack overlay in `TabBarView`) |

> **Note:** `AppFullScreenCover.badge` is handled manually as a `ZStack` overlay with `.zIndex(1000)` inside `TabBarView`, not via the standard `.fullScreenCover` modifier. This avoids navigation stack conflicts.

### Routes

```swift
enum AppRoute: Hashable {
    case question([CardQuestion], subcategoryId: String, title: String)
    case likedQuestions
}

enum AppSheet: Hashable, Identifiable {
    case document(DocumentItem)   // termsOfService | privacyPolicy | support
    case subscription
}

enum AppFullScreenCover: Hashable, Identifiable {
    case badge(Badge)
}
```

---

## Code Style

- Views are composed of **private computed vars** (`navigationView`, `cardView`, `buttonStackView`, etc.) — no inline body bloat.
- Always use the custom `NavigationBar` component — **never** `.navigationTitle` or system navigation bar.
- Use `String(localized: "key", bundle: bundle)` — **never** `NSLocalizedString`.
- Colors always via `Colors.*` — no hardcoded `Color(...)` values.
- Previews always provide **Dark + Light** variants inside `#if DEBUG / #endif` using `@Previewable @State`.
- No third-party dependencies — pure Apple frameworks only.

---

## Content Guidelines

When writing or editing question content:

- Questions must be **open-ended** — avoid yes/no questions.
- Keep questions under **120 characters** to display well in widgets.
- Question `id` must be **globally unique** across all files and languages. Use a consistent naming convention, e.g. `couple_romance_001`.
- Holiday keys use `"MM-dd"` format (zero-padded), e.g. `"12-25"`, `"03-08"`.
- `isPremium: true` subcategories should contain more niche or deep-dive content; free subcategories should represent the core value proposition.

---

## Adding New Content

### New subcategory

1. Add the subcategory object to the relevant `{category}.json` in **both** `en.lproj/` and `uk.lproj/`.
2. Upload badge images to the `sashavoloshanov/Talko-content` repository under `Badges/`: `badge_{subcategoryId}_10.png`, `badge_{subcategoryId}_30.png`, `badge_{subcategoryId}_50.png`.
3. No code changes required — `BadgesClient`, `BadgeImageClient`, and `QuestionClient` pick it up automatically.

### New category

1. Create `{category}.json` in both `en.lproj/` and `uk.lproj/`.
2. Add the category name to the `names` array in `QuestionClient.loadCategories()`.
3. Create a new `Widget` struct in `DailyQuestionWidget/Category/` following the existing pattern.
4. Register the widget in the widget bundle entry point.
5. Add the new `WidgetCategory` case to `WidgetCategory` enum.

### New holiday question

Add an entry to `holidays` in `daily.json` in both language bundles:

```json
"holidays": {
  "MM-DD": "Your holiday question here?"
}
```

---

## Debug Notes

- Debug and release builds behave identically — there are no `#if DEBUG` blocks that change runtime logic.
- `#if DEBUG` is used only around `#Preview` blocks (part of the project's code style).
- To test premium content in the simulator, purchase through the StoreKit sandbox or temporarily set the `isPremium` App Group key.

---

## Requirements

- Xcode 15+
- iOS 17.0+ deployment target
- Swift 5.9+
- App Group capability: `group.com.voloshanov.talk.shared` (must be enabled on both the main target and the widget extension target in the Apple Developer portal)
- In-App Purchase products configured in App Store Connect matching the product IDs above
