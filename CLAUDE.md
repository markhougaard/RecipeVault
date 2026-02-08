# CLAUDE.md — RecipeVault

## Project Overview

RecipeVault is a personal recipe management app for iOS, iPadOS, and macOS. It helps the user find recipes from their existing collection based on ingredients they have on hand. Built with SwiftUI and SwiftData, synced via iCloud (CloudKit).

Read `CONVENTIONS.md` for architecture details, data models, and feature scope before making changes.

## Build & Run

```bash
# Build for iOS
xcodebuild -scheme RecipeVault -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for macOS
xcodebuild -scheme RecipeVault -destination 'platform=macOS' build

# Run tests
xcodebuild -scheme RecipeVault -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Tech Stack

- **Language:** Swift 6 with strict concurrency checking enabled
- **UI:** SwiftUI (multiplatform: iOS 17+, iPadOS 17+, macOS 14+)
- **Persistence:** SwiftData (local storage; iCloud CloudKit sync planned for future)
- **OCR:** Apple Vision framework
- **Recipe extraction:** Claude API (REST)
- **No third-party dependencies** unless absolutely unavoidable

## Swift & SwiftUI Standards

- Use Swift 6 language mode. Enable strict concurrency checking (`SWIFT_STRICT_CONCURRENCY=complete`).
- All SwiftData models must be `Sendable`-safe. Use `@ModelActor` for background data operations.
- Prefer `@Observable` (Observation framework) over `@ObservableObject` / `@Published`.
- Use the modern `SwiftData` `#Predicate` and `FetchDescriptor` APIs — never use legacy `NSPredicate` strings.
- Use `async/await` and structured concurrency (`TaskGroup`, `withThrowingTaskGroup`) everywhere. No Combine, no completion handlers.
- All views must support Dynamic Type and adapt to size classes (compact/regular) for iPhone, iPad, and Mac.
- Use `NavigationSplitView` (not `NavigationView` or `NavigationStack` alone) as the root navigation pattern — this gives proper sidebar behavior on iPad and Mac while collapsing to a stack on iPhone.
- Prefer SwiftUI environment injection (`.environment`, `.modelContainer`) over singletons or service locators.
- Mark views as `@MainActor` only when they directly interact with the model context.

## Layout & Adaptive Design

- Use `ViewThatFits`, `Grid`, and adaptive `LazyVGrid` (with `GridItem(.adaptive(minimum:))`) to make layouts work across iPhone SE to iPad Pro to Mac.
- Avoid hardcoded widths or frame sizes. Use `.frame(maxWidth:)` and `.containerRelativeFrame` where appropriate.
- Test at minimum: iPhone SE (compact), iPhone 16 (compact), iPad (regular), and Mac (regular).
- Support both landscape and portrait on iPad.

## SwiftData & Storage Rules

- Data is currently stored **locally on-device** using SwiftData's default SQLite store.
- Use the default `ModelConfiguration` with no CloudKit parameter (equivalent to `cloudKitDatabase: .none`).
- **Do not** add iCloud (CloudKit) or Background Modes capabilities to the project at this time.

### Future iCloud Sync Preparation

iCloud CloudKit sync will be enabled in a future version. To ensure a painless migration, follow these CloudKit compatibility rules now — even though sync is not yet active:

- Never use `@Attribute(.unique)` on any model — CloudKit does not support unique constraints.
- Avoid optional relationships where possible — default to-many relationships to `[]`.
- Keep model property types CloudKit-compatible: `String`, `Int`, `Double`, `Bool`, `Date`, `Data`, `UUID`, `[String]`, `[Int]`, etc.
- Use `String`-backed enums only — no enums with associated values.
- Pass `PersistentIdentifier` (not model objects) across concurrency boundaries, then re-fetch.

When ready to enable sync, the only changes needed are:
1. Add iCloud (CloudKit) and Background Modes (Remote notifications) capabilities.
2. Change `ModelConfiguration` to use `cloudKitDatabase: .private`.

## File Organization

Follow the structure in `CONVENTIONS.md`. Key rules:
- One primary type per file.
- Views go in `Views/` grouped by feature.
- Services go in `Services/` — one service per responsibility.
- Keep view files lean. Extract logic into services or `@Observable` view models.

## Code Style

- Naming: PascalCase for types, camelCase for properties/functions. Be descriptive.
- Use `guard` for early returns. Avoid deeply nested `if/else`.
- Use `// MARK: -` sections in files longer than ~100 lines.
- No force unwraps (`!`) except in tests and previews with known-good data.
- All public API should have a brief doc comment (`///`).
- No `print()` statements in production code — use `os.Logger` for debug logging.

## Testing

- Write unit tests for all service/logic code (matching, normalization, extraction parsing).
- Use Swift Testing framework (`@Test`, `#expect`) — not XCTest — for all new tests.
- Mock services with protocols. Every service class conforms to a protocol.
- Use `@MainActor in` test setup when testing SwiftData operations.
- SwiftUI previews serve as visual tests — every view needs at least one preview with representative data.

## What to Avoid

- No UIKit or AppKit unless SwiftUI literally cannot do something.
- No Combine. Use `async/await` and `AsyncSequence`.
- No third-party UI libraries. Use native SwiftUI components.
- No `NavigationView` (deprecated). Use `NavigationSplitView` or `NavigationStack`.
- No `@ObservableObject` or `@Published`. Use `@Observable`.
- No `NSPredicate` format strings. Use `#Predicate`.
- No hardcoded colors without Dark Mode equivalents — use semantic colors or asset catalog colors.
- Do not add meal planning, grocery list, or sharing features. These are post-v1.

## Common Pitfalls

- **CloudKit + `.unique`:** SwiftData's `@Attribute(.unique)` causes CloudKit sync failures. Don't use it.
- **CloudKit + optional relationships:** These can cause orphaned records. Default to-many to `[]`.
- **Strict concurrency:** SwiftData model objects are not `Sendable`. Pass identifiers (`PersistentIdentifier`) across concurrency boundaries, then re-fetch in the target actor context.
- **`#Predicate` limitations:** You cannot call functions inside `#Predicate`. Do filtering with simple property comparisons, then post-filter in Swift if needed.
- **iPad split view:** If the detail column shows nothing on launch, provide a default "select something" placeholder view.
