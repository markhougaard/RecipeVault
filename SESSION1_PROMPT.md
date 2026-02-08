# Claude Code — Session 1: Project Scaffold & Data Layer

## Context

I'm building a personal iOS/macOS recipe management app called **RecipeVault**. Read `CONVENTIONS.md` in the project root for full architecture details before starting.

## Goal

Set up the Xcode project and build the complete SwiftData layer with seed data. No UI beyond a basic skeleton. This session is about getting the foundation right.

## Tasks

### 1. Create the Xcode project

- Create a new SwiftUI multiplatform app (iOS, iPadOS, macOS) called `RecipeVault`.
- Set minimum deployment to iOS 17.0, iPadOS 17.0, and macOS 14.0.
- Enable **strict concurrency checking** (`SWIFT_STRICT_CONCURRENCY=complete`) and Swift 6 language mode.
- **Do not** add iCloud (CloudKit) or Background Modes capabilities — local storage only for now.
- Set up the folder structure as defined in `CONVENTIONS.md`.
- Add a basic `ContentView.swift` using `NavigationSplitView` with a sidebar containing four sections:
  - **Recipes** (list icon)
  - **What Can I Make?** (magnifyingglass icon)
  - **Add Recipe** (plus icon)
  - **Books** (book icon)
- On iPhone, this collapses to a tab bar. On iPad/Mac, it renders as a sidebar + detail layout.
- Each section should show a placeholder view with the section name. We'll build the real views in later sessions.

### 2. Define SwiftData models

Create these three models following the conventions in `CONVENTIONS.md`:

**Recipe** (aligned with schema.org/Recipe — see `CONVENTIONS.md` for the full mapping table)
- `id: UUID` (auto-generated)
- `name: String` (schema.org: `name`)
- `recipeDescription: String?` (schema.org: `description`)
- `recipeIngredient: [String]` — raw ingredient text as written ("2 cups diced tomatoes")
- `normalizedIngredients: [String]` — app-specific: cleaned ingredient names for matching ("tomato")
- `recipeInstructions: [String]` — one string per step
- `recipeCategory: String?` — e.g., "Dinner", "Appetizer"
- `recipeCuisine: String?` — e.g., "Italian", "Asian", "Soup"
- `recipeYield: String?` — e.g., "4 servings"
- `prepTime: String?` — ISO 8601 duration, e.g., "PT15M"
- `cookTime: String?` — ISO 8601 duration, e.g., "PT30M"
- `totalTime: String?` — ISO 8601 duration, e.g., "PT45M"
- `keywords: [String]` — searchable tags, default `[]`
- `author: String?` — recipe author name
- `datePublished: Date?` — original publish date if from URL
- `imageData: Data?` — optional photo
- `sourceType: String` — raw string: "book", "url", or "manual" (use `SourceType` enum via computed property)
- `sourceURL: String?`
- `sourcePageNumber: Int?`
- `notes: String?`
- `isFavorite: Bool` (default: false)
- `createdAt: Date`
- `updatedAt: Date`
- Relationship: optional `Book`

**Important CloudKit rules:**
- Do NOT use `@Attribute(.unique)` on any property.
- `sourceType` is a raw `String`, not an enum property. Provide a computed property wrapping `SourceType` enum.
- `recipeIngredient`, `normalizedIngredients`, `recipeInstructions`, and `keywords` default to `[]`.

**Book**
- `id: UUID` (auto-generated)
- `title: String`
- `author: String?`
- `createdAt: Date`
- `updatedAt: Date`
- Relationship: `[Recipe]` (inverse of Recipe.book, default `[]`)

**Ingredient**
- `id: UUID` (auto-generated)
- `name: String` — normalized, lowercase (e.g., "tomato")
- `category: IngredientCategory?` — enum: `.protein`, `.vegetable`, `.fruit`, `.dairy`, `.grain`, `.pantryStaple`, `.herb`, `.spice`, `.condiment`, `.other`
- `aliases: [String]` — alternative names (e.g., ["capsicum"] for "bell pepper")
- `createdAt: Date`
- `updatedAt: Date`

Also create:
- `SourceType` enum (`String`, `Codable`) — cases: `book`, `url`, `manual`
- `IngredientCategory` enum (`String`, `Codable`) — cases: `protein`, `vegetable`, `fruit`, `dairy`, `grain`, `pantryStaple`, `herb`, `spice`, `condiment`, `other`

Both enums must be `String`-backed (CloudKit requirement). `SourceType` is not stored directly as a model property — it's used via a computed property on `Recipe`.

### 3. Set up the ModelContainer (local storage)

Configure the `ModelContainer` in `RecipeVaultApp.swift`:
- Use the default `ModelConfiguration` with no CloudKit parameter (local on-device storage).
- Register all three model types (`Recipe`, `Book`, `Ingredient`).
- Follow CloudKit compatibility rules from `CONVENTIONS.md` in all models — this ensures a painless migration to iCloud sync later.

### 4. Create seed data

Create `SeedData.swift` in Resources/ with a static function that populates the database with sample data for development:

**Books (3):**
1. "Salt, Fat, Acid, Heat" by Samin Nosrat
2. "The Wok" by J. Kenji López-Alt
3. "Ottolenghi Simple" by Yotam Ottolenghi

**Recipes (8, mix of sources):**
1. Classic Tomato Pasta — Italian, from "Salt, Fat, Acid, Heat" p.234, ingredients: spaghetti, tomatoes, garlic, olive oil, basil, parmesan, salt, black pepper
2. Chicken Stir-Fry — Asian, from "The Wok" p.112, ingredients: chicken breast, soy sauce, ginger, garlic, broccoli, bell pepper, rice, sesame oil, cornstarch
3. Roasted Cauliflower with Tahini — Mediterranean, from "Ottolenghi Simple" p.78, ingredients: cauliflower, tahini, lemon, garlic, olive oil, parsley, cumin, salt
4. Quick Black Bean Soup — Soup, URL source "https://example.com/bean-soup", ingredients: black beans, onion, garlic, cumin, chicken stock, lime, cilantro, sour cream
5. Egg Fried Rice — Asian, from "The Wok" p.89, ingredients: rice, eggs, soy sauce, sesame oil, spring onion, garlic, peas, carrot
6. Hummus from Scratch — Mediterranean, manual entry, ingredients: chickpeas, tahini, lemon, garlic, olive oil, cumin, salt, paprika
7. Duck Breast with Cherry Sauce — French, URL source "https://example.com/duck-cherry", ingredients: duck breast, cherries, red wine, butter, thyme, salt, black pepper, sugar
8. Caesar Salad — American, manual entry, ingredients: romaine lettuce, parmesan, croutons, eggs, anchovies, garlic, lemon, olive oil, dijon mustard

For each recipe, populate both `recipeIngredient` (with quantities, e.g., "400g spaghetti") and `normalizedIngredients` (just the ingredient name, e.g., "spaghetti"). Use ISO 8601 durations for time fields (e.g., `prepTime: "PT10M"`, `cookTime: "PT20M"`).

**Ingredients (populate the Ingredient table):**
Extract all unique normalized ingredients from the recipes above and create `Ingredient` entries with appropriate categories. Add a few common aliases (e.g., spring onion → ["scallion", "green onion"]).

### 5. Seed data loading

Call the seed data function from `RecipeVaultApp.swift` on first launch only. Use a simple check — if the Recipe count is 0, run the seeder.

### 6. Add basic CRUD helpers

Create extension methods on `ModelContext` or a simple `DataService` class:

- `allRecipes(filteredBy cuisine: String?) -> [Recipe]`
- `searchRecipes(matching query: String) -> [Recipe]`
- `allBooks() -> [Book]`
- `allIngredients() -> [Ingredient]`
- `findIngredient(named: String) -> Ingredient?`
- `addRecipe(_ recipe: Recipe)`
- `deleteRecipe(_ recipe: Recipe)`
- `addBook(_ book: Book)`

### 7. Write unit tests

Create test targets with tests for:
- Model creation and relationships (Recipe ↔ Book)
- Seed data completeness (correct count of recipes, books, ingredients)
- CRUD operations (add, fetch, delete)

## What NOT to do

- Do not build any real UI beyond the tab skeleton with placeholder views.
- Do not add any networking, API, or OCR code.
- Do not add any third-party dependencies.
- Do not scaffold meal planning or grocery list features.

## Verification

When complete, the app should:
1. Build and run on iOS Simulator (iPhone and iPad) and macOS.
2. Show adaptive navigation: sidebar on iPad/Mac, tab bar on iPhone.
3. The `ModelConfiguration` uses default local storage (no CloudKit).
4. All models follow CloudKit compatibility rules (no `.unique`, `String`-backed enums, etc.) for future migration.
5. On first launch, populate the database with seed data.
6. All unit tests pass.
7. Strict concurrency checking produces no warnings.
