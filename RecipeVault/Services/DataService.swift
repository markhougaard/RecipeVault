import Foundation
import SwiftData

/// Protocol for data access operations, enabling mocking in tests.
protocol DataServiceProtocol {
    func allRecipes(filteredBy cuisine: String?) throws -> [Recipe]
    func searchRecipes(matching query: String) throws -> [Recipe]
    func allBooks() throws -> [Book]
    func allIngredients() throws -> [Ingredient]
    func findIngredient(named name: String) throws -> Ingredient?
    func addRecipe(_ recipe: Recipe)
    func deleteRecipe(_ recipe: Recipe)
    func addBook(_ book: Book)
}

/// Provides CRUD operations for SwiftData models.
@MainActor
final class DataService: DataServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Fetches all recipes, optionally filtered by cuisine.
    nonisolated func allRecipes(filteredBy cuisine: String? = nil) throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.name)]
        )
        let all = try context.fetch(descriptor)
        guard let cuisine else { return all }
        return all.filter { $0.recipeCuisine?.localizedStandardContains(cuisine) == true }
    }

    /// Searches recipes by name or keywords.
    func searchRecipes(matching query: String) throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.name)]
        )
        let allRecipes = try context.fetch(descriptor)

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return allRecipes
        }

        let lowered = query.lowercased()
        return allRecipes.filter { recipe in
            recipe.name.localizedStandardContains(lowered) ||
            recipe.keywords.contains { $0.localizedStandardContains(lowered) } ||
            recipe.normalizedIngredients.contains { $0.localizedStandardContains(lowered) }
        }
    }

    /// Fetches all books sorted by title.
    func allBooks() throws -> [Book] {
        let descriptor = FetchDescriptor<Book>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try context.fetch(descriptor)
    }

    /// Fetches all ingredients sorted by name.
    func allIngredients() throws -> [Ingredient] {
        let descriptor = FetchDescriptor<Ingredient>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    /// Finds an ingredient by its normalized name.
    func findIngredient(named name: String) throws -> Ingredient? {
        let normalized = name.lowercased().trimmingCharacters(in: .whitespaces)
        let descriptor = FetchDescriptor<Ingredient>()
        let all = try context.fetch(descriptor)
        return all.first { ingredient in
            ingredient.name == normalized ||
            ingredient.aliases.contains(normalized)
        }
    }

    /// Inserts a new recipe into the store.
    func addRecipe(_ recipe: Recipe) {
        context.insert(recipe)
    }

    /// Deletes a recipe from the store.
    func deleteRecipe(_ recipe: Recipe) {
        context.delete(recipe)
    }

    /// Inserts a new book into the store.
    func addBook(_ book: Book) {
        context.insert(book)
    }
}
