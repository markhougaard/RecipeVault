import Testing
import Foundation
import SwiftData
@testable import RecipeVault

/// Tests for SwiftData model creation and relationships.
@Suite("Model Tests", .serialized)
struct ModelTests {

    /// Creates an in-memory model container for testing.
    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Recipe.self, Book.self, Ingredient.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @Test("Recipe initializes with correct defaults")
    @MainActor func recipeDefaults() throws {
        let recipe = Recipe(name: "Test Recipe")

        #expect(recipe.name == "Test Recipe")
        #expect(recipe.recipeIngredient.isEmpty)
        #expect(recipe.normalizedIngredients.isEmpty)
        #expect(recipe.recipeInstructions.isEmpty)
        #expect(recipe.keywords.isEmpty)
        #expect(recipe.isFavorite == false)
        #expect(recipe.source == .manual)
        #expect(recipe.sourceType == "manual")
        #expect(recipe.book == nil)
    }

    @Test("Recipe source computed property maps correctly")
    @MainActor func recipeSourceComputed() throws {
        let recipe = Recipe(name: "Book Recipe", sourceType: .book)
        #expect(recipe.source == .book)
        #expect(recipe.sourceType == "book")

        recipe.source = .url
        #expect(recipe.sourceType == "url")
        #expect(recipe.source == .url)
    }

    @Test("Book initializes with empty recipes array")
    @MainActor func bookDefaults() throws {
        let book = Book(title: "Test Book", author: "Author")

        #expect(book.title == "Test Book")
        #expect(book.author == "Author")
        #expect(book.recipes.isEmpty)
    }

    @Test("Recipe-Book relationship links correctly")
    @MainActor func recipeBookRelationship() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let book = Book(title: "My Cookbook", author: "Chef")
        context.insert(book)

        let recipe = Recipe(name: "My Recipe", sourceType: .book, book: book)
        context.insert(recipe)

        #expect(recipe.book === book)
        #expect(book.recipes.contains { $0.name == "My Recipe" })
    }

    @Test("Ingredient normalizes name to lowercase")
    @MainActor func ingredientNormalization() throws {
        let ingredient = Ingredient(name: "  Bell Pepper  ", category: .vegetable, aliases: ["capsicum"])

        #expect(ingredient.name == "bell pepper")
        #expect(ingredient.category == .vegetable)
        #expect(ingredient.aliases == ["capsicum"])
    }

    @Test("Ingredient category computed property maps correctly")
    @MainActor func ingredientCategoryComputed() throws {
        let ingredient = Ingredient(name: "basil", category: .herb)
        #expect(ingredient.category == .herb)
        #expect(ingredient.categoryRawValue == "herb")

        ingredient.category = .spice
        #expect(ingredient.categoryRawValue == "spice")
    }
}
