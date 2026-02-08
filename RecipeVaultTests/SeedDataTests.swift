import Testing
import Foundation
import SwiftData
@testable import RecipeVault

/// Tests for seed data completeness and correctness.
@Suite("Seed Data Tests", .serialized)
struct SeedDataTests {

    @MainActor
    private func makeSeededContainer() throws -> ModelContainer {
        let schema = Schema([Recipe.self, Book.self, Ingredient.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        SeedData.populate(context: container.mainContext)
        return container
    }

    @Test("Seed data creates 8 recipes")
    @MainActor func recipeCount() throws {
        let container = try makeSeededContainer()
        let count = try container.mainContext.fetchCount(FetchDescriptor<Recipe>())
        #expect(count == 8)
    }

    @Test("Seed data creates 3 books")
    @MainActor func bookCount() throws {
        let container = try makeSeededContainer()
        let count = try container.mainContext.fetchCount(FetchDescriptor<Book>())
        #expect(count == 3)
    }

    @Test("Seed data creates correct number of ingredients")
    @MainActor func ingredientCount() throws {
        let container = try makeSeededContainer()
        let count = try container.mainContext.fetchCount(FetchDescriptor<Ingredient>())
        #expect(count > 30)
    }

    @Test("Book recipes are linked correctly")
    @MainActor func bookRecipesLinked() throws {
        let container = try makeSeededContainer()
        let books = try container.mainContext.fetch(FetchDescriptor<Book>())

        let theWok = books.first { $0.title == "The Wok" }
        #expect(theWok != nil)
        #expect(theWok!.recipes.count == 2)

        let sfah = books.first { $0.title == "Salt, Fat, Acid, Heat" }
        #expect(sfah != nil)
        #expect(sfah!.recipes.count == 1)

        let ottolenghi = books.first { $0.title == "Ottolenghi Simple" }
        #expect(ottolenghi != nil)
        #expect(ottolenghi!.recipes.count == 1)
    }

    @Test("Recipes have all required fields populated")
    @MainActor func recipesHaveRequiredFields() throws {
        let container = try makeSeededContainer()
        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        for recipe in recipes {
            #expect(!recipe.name.isEmpty, "Recipe name should not be empty")
            #expect(!recipe.recipeIngredient.isEmpty, "Recipe \(recipe.name) should have ingredients")
            #expect(!recipe.normalizedIngredients.isEmpty, "Recipe \(recipe.name) should have normalized ingredients")
            #expect(!recipe.recipeInstructions.isEmpty, "Recipe \(recipe.name) should have instructions")
            #expect(recipe.recipeCategory != nil, "Recipe \(recipe.name) should have a category")
            #expect(recipe.recipeCuisine != nil, "Recipe \(recipe.name) should have a cuisine")
        }
    }

    @Test("URL-sourced recipes have sourceURL set")
    @MainActor func urlRecipesHaveSource() throws {
        let container = try makeSeededContainer()
        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())
        let urlRecipes = recipes.filter { $0.source == .url }

        #expect(urlRecipes.count == 2)
        for recipe in urlRecipes {
            #expect(recipe.sourceURL != nil, "URL recipe \(recipe.name) should have a sourceURL")
        }
    }

    @Test("Book-sourced recipes have page numbers")
    @MainActor func bookRecipesHavePageNumbers() throws {
        let container = try makeSeededContainer()
        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())
        let bookRecipes = recipes.filter { $0.source == .book }

        #expect(bookRecipes.count == 4)
        for recipe in bookRecipes {
            #expect(recipe.sourcePageNumber != nil, "Book recipe \(recipe.name) should have a page number")
            #expect(recipe.book != nil, "Book recipe \(recipe.name) should be linked to a book")
        }
    }
}
