# RecipeVault — Project Conventions

## Overview

RecipeVault is a personal iOS/macOS recipe management app. It helps the user find recipes from their existing collection based on available ingredients and preferred cooking style. It supports ingesting recipes from photos (OCR) and URLs.

This is a personal utility app — not a commercial product. Prioritize simplicity and reliability over polish and scalability.

## Tech Stack

- **UI:** SwiftUI (single codebase for iOS, iPadOS, and macOS)
- **Persistence:** SwiftData (local on-device storage; iCloud CloudKit sync planned for future)
- **Minimum deployment:** iOS 17.0 / iPadOS 17.0 / macOS 14.0
- **OCR:** Apple Vision framework (`VNRecognizeTextRequest`)
- **Recipe extraction:** Claude API (direct REST calls)
- **URL recipe parsing:** JSON-LD (`schema.org/Recipe`) with Claude API fallback

## Data Storage

Data is stored **locally on each device** using SwiftData's default SQLite store. Each device (iPhone, iPad, Mac) maintains its own independent database. Data persists across app launches and updates.

Use the default `ModelConfiguration` with no CloudKit parameter. Do not add iCloud or Background Modes capabilities at this time.

### Future iCloud Sync Preparation

iCloud CloudKit sync will be enabled in a future version. To ensure a painless migration, all models follow CloudKit compatibility rules from day one:

- **No `@Attribute(.unique)`** — CloudKit does not support unique constraints. Handle deduplication at the app level if needed.
- **No optional relationships** where avoidable — use empty arrays `[]` as defaults for to-many relationships.
- **Enum properties** must be `String`-backed (`RawRepresentable` as `String`). No enums with associated values.
- **Only CloudKit-compatible types:** `String`, `Int`, `Double`, `Bool`, `Date`, `Data`, `UUID`, `[String]`, `[Int]`, `[Double]`. No custom `Codable` structs as stored properties — flatten them into the model.
- **Pass `PersistentIdentifier`** (not model objects) across concurrency boundaries, then re-fetch.

When ready to enable sync:
1. Add iCloud (CloudKit) and Background Modes (Remote notifications) capabilities to the Xcode project.
2. Change `ModelConfiguration` to use `cloudKitDatabase: .private`.

## Project Structure

```
RecipeVault/
├── App/
│   ├── RecipeVaultApp.swift          # App entry point
│   └── ContentView.swift             # Root tab navigation
├── Models/
│   ├── Recipe.swift                  # SwiftData model
│   ├── Book.swift                    # SwiftData model
│   └── Ingredient.swift              # SwiftData model
├── Views/
│   ├── RecipeList/
│   │   ├── RecipeListView.swift
│   │   └── RecipeRowView.swift
│   ├── RecipeDetail/
│   │   └── RecipeDetailView.swift
│   ├── WhatCanIMake/
│   │   ├── IngredientInputView.swift
│   │   ├── StylePickerView.swift
│   │   └── MatchResultsView.swift
│   ├── Ingestion/
│   │   ├── PhotoIngestionView.swift
│   │   ├── URLIngestionView.swift
│   │   └── RecipeReviewView.swift   # Edit before saving
│   └── Books/
│       └── BookListView.swift
├── Services/
│   ├── RecipeExtractor.swift         # Claude API integration
│   ├── OCRService.swift              # Vision framework wrapper
│   ├── URLScraper.swift              # JSON-LD + fallback
│   └── IngredientMatcher.swift       # Matching algorithm
├── Utilities/
│   ├── IngredientNormalizer.swift     # Stemming and alias mapping
│   └── Constants.swift
└── Resources/
    └── SeedData.swift                # Sample recipes for development
```

## Naming Conventions

- **Files:** PascalCase, matching the primary type they contain.
- **SwiftData models:** Singular nouns (`Recipe`, `Book`, `Ingredient`).
- **Views:** Descriptive suffix `View` (e.g., `RecipeListView`).
- **Services:** Descriptive suffix describing responsibility (e.g., `RecipeExtractor`).
- **Variables and functions:** camelCase. Be descriptive — `matchedIngredientCount` not `cnt`.

## SwiftData Models

All models use the `@Model` macro. Relationships use SwiftData's built-in relationship handling.

Key rules:
- Every model gets a `createdAt: Date` and `updatedAt: Date`.
- **Do not use `@Attribute(.unique)`** — it is incompatible with CloudKit sync.
- Ingredient names are always stored lowercase and trimmed.
- All enums are `String`-backed and `Codable`.
- To-many relationships default to empty arrays `[]`, never `nil`.

### Recipe Model — schema.org/Recipe Alignment

The `Recipe` model follows the [schema.org/Recipe](https://schema.org/Recipe) standard. This ensures ingested recipes from JSON-LD sources map directly to the model, and any future export/sharing uses a universal format.

| SwiftData Property       | schema.org Property    | Type            | Notes                                      |
|--------------------------|------------------------|-----------------|--------------------------------------------|
| `name`                   | `name`                 | `String`        | Recipe title                               |
| `recipeDescription`      | `description`          | `String?`       | Short summary                              |
| `recipeIngredient`       | `recipeIngredient`     | `[String]`      | Raw ingredient lines ("2 cups diced tomato")|
| `normalizedIngredients`  | —                      | `[String]`      | App-specific: cleaned names for matching   |
| `recipeInstructions`     | `recipeInstructions`   | `[String]`      | One string per step                        |
| `recipeCategory`         | `recipeCategory`       | `String?`       | e.g., "Dinner", "Appetizer", "Dessert"     |
| `recipeCuisine`          | `recipeCuisine`        | `String?`       | e.g., "Italian", "Asian", "French"         |
| `recipeYield`            | `recipeYield`          | `String?`       | e.g., "4 servings", "1 loaf"               |
| `prepTime`               | `prepTime`             | `String?`       | ISO 8601 duration, e.g., "PT15M"           |
| `cookTime`               | `cookTime`             | `String?`       | ISO 8601 duration, e.g., "PT30M"           |
| `totalTime`              | `totalTime`            | `String?`       | ISO 8601 duration, e.g., "PT45M"           |
| `keywords`               | `keywords`             | `[String]`      | Searchable tags                            |
| `imageData`              | `image`                | `Data?`         | Stored as binary; schema.org uses URL      |
| `datePublished`          | `datePublished`        | `Date?`         | Original publish date if from URL          |
| `author`                 | `author`               | `String?`       | Recipe author name                         |
| `sourceType`             | —                      | `String`        | App-specific: "book", "url", "manual"      |
| `sourceURL`              | `url`                  | `String?`       | Original URL if scraped                    |
| `sourcePageNumber`       | —                      | `Int?`          | Page number if from a book                 |
| `notes`                  | —                      | `String?`       | Personal notes                             |
| `isFavorite`             | —                      | `Bool`          | Default: false                             |
| `createdAt`              | —                      | `Date`          |                                            |
| `updatedAt`              | —                      | `Date`          |                                            |
| `book`                   | —                      | `Book?`         | Optional relationship                      |

Properties not in schema.org (`normalizedIngredients`, `sourceType`, `sourcePageNumber`, `notes`, `isFavorite`) are app-specific extensions for matching and personal use.

`sourceType` is stored as a raw `String` (not a Swift enum property) to stay CloudKit-safe. Use a `SourceType` enum in code with a computed property for ergonomic access.

## Coding Style

- Prefer `struct` views, `@Observable` for view models if needed.
- No third-party dependencies unless absolutely necessary. Apple frameworks first.
- Keep views lean — extract logic into services or view models.
- Use `async/await` for all asynchronous work (OCR, API calls, URL fetching).
- Handle errors with meaningful user-facing messages, not silent failures.
- Use SwiftUI previews with mock data for every view.

## Ingredient Matching Logic

The matching algorithm lives in `IngredientMatcher.swift` and works as follows:

1. User inputs a comma-separated list of ingredients and optionally selects a style/cuisine.
2. Each input ingredient is normalized (lowercased, trimmed, stemmed).
3. Each recipe in the database is scored: `matchScore = matchedIngredients.count / recipe.totalIngredients.count`.
4. If a style filter is active, only recipes with that cuisine tag are considered.
5. Results are sorted by `matchScore` descending.
6. A minimum threshold of 0.3 (30% ingredient match) is applied before showing results.

## Ingredient Normalization

`IngredientNormalizer.swift` handles:
- Lowercasing and trimming whitespace.
- Removing quantity words ("2 cups of" → extract just the ingredient).
- Basic plural stripping ("tomatoes" → "tomato").
- A manual alias dictionary for common equivalents (e.g., "capsicum" → "bell pepper", "aubergine" → "eggplant").

This is a personal app — the alias dictionary only needs to cover ingredients the user actually uses. Start small and expand as needed.

## Recipe Extraction (Claude API)

`RecipeExtractor.swift` is the single service that takes raw text (from OCR or URL scrape) and returns a structured `RecipeDraft` (a plain struct, not a SwiftData model). The draft is shown to the user for review/edit before being saved.

The Claude API prompt should request JSON output using schema.org/Recipe property names:
- `name` (String)
- `description` (String)
- `recipeIngredient` (Array of strings, raw lines)
- `recipeInstructions` (Array of strings, one per step)
- `recipeCategory` (String)
- `recipeCuisine` (String)
- `recipeYield` (String)
- `prepTime` (String, ISO 8601 duration)
- `cookTime` (String, ISO 8601 duration)
- `totalTime` (String, ISO 8601 duration)
- `keywords` (Array of strings)
- `author` (String, if detectable)

This means data from JSON-LD sources and data from OCR/manual extraction go through the same struct. The `RecipeDraft → Recipe` mapping is a single, consistent code path.

## Source Tracking

Every recipe tracks its source:
- **Book:** Reference to a `Book` model + page number (optional).
- **URL:** The original URL string.
- **Manual:** No source, entered by hand.

This enables linking back to the original source in the UI.

## Future Features (NOT in v1.0)

These are planned but must not appear in the v1.0 codebase. Do not add models, views, or scaffolding for them:
- Meal planning (weekly plan, calendar integration)
- Grocery list generation from meal plan
- Sharing recipes
- iCloud sync

## Testing

- Write unit tests for `IngredientNormalizer` and `IngredientMatcher` — these are the core logic.
- Use SwiftUI previews as visual tests for all views.
- Service classes (`RecipeExtractor`, `OCRService`, `URLScraper`) should use protocols so they can be mocked in tests.

## Git Conventions

- Commit messages: imperative tense, brief (`Add ingredient matching service`, `Fix OCR text cleanup`).
- One feature per branch if working iteratively.
- Tag releases: `v1.0`, `v1.1`, etc.
