import Foundation

/// A single row in a dynamic form list (ingredient or instruction).
struct FormItem: Identifiable {
    let id: UUID = UUID()
    var text: String = ""
}

/// Manages all mutable state for the Add/Edit Recipe form.
///
/// Pure logic — no SwiftData dependency. The view is responsible for
/// creating or updating `Recipe` objects using the data from this view model.
@Observable
final class RecipeFormViewModel {

    // MARK: - Required Fields

    var title: String = ""

    // MARK: - Dynamic Lists

    var ingredients: [FormItem] = [FormItem()]
    var instructions: [FormItem] = [FormItem()]

    // MARK: - Tags

    var tags: [String] = []
    var currentTagInput: String = ""

    // MARK: - Optional Fields

    var recipeDescription: String = ""
    var cuisine: String = ""
    var category: String = ""
    var servings: String = ""
    var prepHours: Int = 0
    var prepMinutes: Int = 0
    var cookHours: Int = 0
    var cookMinutes: Int = 0
    var notes: String = ""

    // MARK: - Validation

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Ingredient Management

    /// Adds a new ingredient row after the given item and returns the new item's ID.
    @discardableResult
    func addIngredient(after item: FormItem? = nil) -> UUID {
        let newItem = FormItem()
        if let item, let index = ingredients.firstIndex(where: { $0.id == item.id }) {
            ingredients.insert(newItem, at: index + 1)
        } else {
            ingredients.append(newItem)
        }
        return newItem.id
    }

    func removeIngredients(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        if ingredients.isEmpty {
            ingredients.append(FormItem())
        }
    }

    // MARK: - Instruction Management

    /// Adds a new instruction row after the given item and returns the new item's ID.
    @discardableResult
    func addInstruction(after item: FormItem? = nil) -> UUID {
        let newItem = FormItem()
        if let item, let index = instructions.firstIndex(where: { $0.id == item.id }) {
            instructions.insert(newItem, at: index + 1)
        } else {
            instructions.append(newItem)
        }
        return newItem.id
    }

    func removeInstructions(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
        if instructions.isEmpty {
            instructions.append(FormItem())
        }
    }

    // MARK: - Tag Management

    /// Commits the current tag input. Returns `true` if a tag was added.
    @discardableResult
    func commitTag() -> Bool {
        let cleaned = currentTagInput
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")

        guard !cleaned.isEmpty, !tags.contains(cleaned) else {
            currentTagInput = ""
            return false
        }

        tags.append(cleaned)
        currentTagInput = ""
        return true
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    // MARK: - Build Recipe

    /// Creates a new `Recipe` from the current form state.
    func buildRecipe() -> Recipe {
        let cleanIngredients = strippedItems(ingredients)
        let displayIngredients = cleanIngredients.map {
            IngredientNormalizer.normalizeDisplaySpacing($0)
        }
        let normalizedIngredients = cleanIngredients.map {
            IngredientNormalizer.normalize($0)
        }
        let cleanInstructions = strippedItems(instructions)

        return Recipe(
            name: title.trimmingCharacters(in: .whitespaces),
            recipeDescription: emptyToNil(recipeDescription),
            recipeIngredient: displayIngredients,
            normalizedIngredients: normalizedIngredients,
            recipeInstructions: cleanInstructions,
            recipeCategory: emptyToNil(category),
            recipeCuisine: emptyToNil(cuisine),
            recipeYield: emptyToNil(servings),
            prepTime: DurationBuilder.iso8601(hours: prepHours, minutes: prepMinutes),
            cookTime: DurationBuilder.iso8601(hours: cookHours, minutes: cookMinutes),
            totalTime: computedTotalTime(),
            keywords: tags,
            sourceType: .manual
        )
    }

    /// Applies the current form state to an existing recipe (for edit mode).
    func applyChanges(to recipe: Recipe) {
        let cleanIngredients = strippedItems(ingredients)
        let displayIngredients = cleanIngredients.map {
            IngredientNormalizer.normalizeDisplaySpacing($0)
        }
        let normalizedIngredients = cleanIngredients.map {
            IngredientNormalizer.normalize($0)
        }
        let cleanInstructions = strippedItems(instructions)

        recipe.name = title.trimmingCharacters(in: .whitespaces)
        recipe.recipeDescription = emptyToNil(recipeDescription)
        recipe.recipeIngredient = displayIngredients
        recipe.normalizedIngredients = normalizedIngredients
        recipe.recipeInstructions = cleanInstructions
        recipe.recipeCategory = emptyToNil(category)
        recipe.recipeCuisine = emptyToNil(cuisine)
        recipe.recipeYield = emptyToNil(servings)
        recipe.prepTime = DurationBuilder.iso8601(hours: prepHours, minutes: prepMinutes)
        recipe.cookTime = DurationBuilder.iso8601(hours: cookHours, minutes: cookMinutes)
        recipe.totalTime = computedTotalTime()
        recipe.keywords = tags
        recipe.notes = emptyToNil(notes)
        recipe.updatedAt = Date()
    }

    // MARK: - Populate (Edit Mode)

    /// Fills the form from an existing recipe for editing.
    func populate(from recipe: Recipe) {
        title = recipe.name
        recipeDescription = recipe.recipeDescription ?? ""
        cuisine = recipe.recipeCuisine ?? ""
        category = recipe.recipeCategory ?? ""
        servings = recipe.recipeYield ?? ""
        notes = recipe.notes ?? ""

        ingredients = recipe.recipeIngredient.map { FormItem(text: $0) }
        if ingredients.isEmpty { ingredients.append(FormItem()) }

        instructions = recipe.recipeInstructions.map { FormItem(text: $0) }
        if instructions.isEmpty { instructions.append(FormItem()) }

        tags = recipe.keywords

        // Parse ISO 8601 durations back into hours/minutes
        parseDuration(recipe.prepTime, hours: &prepHours, minutes: &prepMinutes)
        parseDuration(recipe.cookTime, hours: &cookHours, minutes: &cookMinutes)
    }

    // MARK: - Private Helpers

    /// Strips trailing empty items and returns the text of non-empty items.
    private func strippedItems(_ items: [FormItem]) -> [String] {
        items
            .map { $0.text.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func emptyToNil(_ string: String) -> String? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Computes total time from prep + cook.
    private func computedTotalTime() -> String? {
        let totalMinutes = (prepHours * 60 + prepMinutes) + (cookHours * 60 + cookMinutes)
        guard totalMinutes > 0 else { return nil }
        return DurationBuilder.iso8601(hours: totalMinutes / 60, minutes: totalMinutes % 60)
    }

    /// Parses an ISO 8601 duration string into hours and minutes.
    private func parseDuration(_ iso: String?, hours: inout Int, minutes: inout Int) {
        guard let iso, iso.hasPrefix("PT") else {
            hours = 0
            minutes = 0
            return
        }
        let timeString = String(iso.dropFirst(2))
        var current = ""
        for char in timeString {
            switch char {
            case "H":
                hours = Int(current) ?? 0
                current = ""
            case "M":
                minutes = Int(current) ?? 0
                current = ""
            case "S":
                current = ""
            default:
                current.append(char)
            }
        }
    }
}

