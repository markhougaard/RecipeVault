import Testing
import Foundation
import SwiftData
@testable import RecipeVault

/// Tests for DataService CRUD operations.
@Suite("DataService Tests", .serialized)
struct DataServiceTests {

    @MainActor
    private func makeServiceWithSeedData() throws -> (DataService, ModelContainer) {
        let schema = Schema([Recipe.self, Book.self, Ingredient.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        SeedData.populate(context: container.mainContext)
        let service = DataService(context: container.mainContext)
        return (service, container)
    }

    @MainActor
    private func makeEmptyService() throws -> (DataService, ModelContainer) {
        let schema = Schema([Recipe.self, Book.self, Ingredient.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let service = DataService(context: container.mainContext)
        return (service, container)
    }

    // MARK: - allRecipes

    @Test("allRecipes returns all recipes when no filter")
    @MainActor func allRecipesNoFilter() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let recipes = try service.allRecipes(filteredBy: nil)
        #expect(recipes.count == 8)
    }

    @Test("allRecipes filters by cuisine")
    @MainActor func allRecipesFilteredByCuisine() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let italian = try service.allRecipes(filteredBy: "Italian")
        #expect(italian.count == 1)
        #expect(italian.first?.name == "Classic Tomato Pasta")

        let asian = try service.allRecipes(filteredBy: "Asian")
        #expect(asian.count == 2)
    }

    // MARK: - searchRecipes

    @Test("searchRecipes matches by name")
    @MainActor func searchByName() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let results = try service.searchRecipes(matching: "hummus")
        #expect(results.count == 1)
        #expect(results.first?.name == "Hummus from Scratch")
    }

    @Test("searchRecipes matches by keyword")
    @MainActor func searchByKeyword() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let results = try service.searchRecipes(matching: "wok")
        #expect(results.count == 2)
    }

    @Test("searchRecipes matches by ingredient")
    @MainActor func searchByIngredient() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let results = try service.searchRecipes(matching: "tahini")
        #expect(results.count == 2) // Cauliflower + Hummus
    }

    @Test("searchRecipes returns all for empty query")
    @MainActor func searchEmptyQuery() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let results = try service.searchRecipes(matching: "  ")
        #expect(results.count == 8)
    }

    // MARK: - allBooks

    @Test("allBooks returns all books sorted by title")
    @MainActor func allBooksSorted() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let books = try service.allBooks()
        #expect(books.count == 3)
        #expect(books.first?.title == "Ottolenghi Simple")
        #expect(books.last?.title == "The Wok")
    }

    // MARK: - allIngredients

    @Test("allIngredients returns all ingredients")
    @MainActor func allIngredients() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let ingredients = try service.allIngredients()
        #expect(ingredients.count > 30)
    }

    // MARK: - findIngredient

    @Test("findIngredient finds by exact name")
    @MainActor func findByName() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let garlic = try service.findIngredient(named: "garlic")
        #expect(garlic != nil)
        #expect(garlic?.name == "garlic")
    }

    @Test("findIngredient finds by alias")
    @MainActor func findByAlias() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let scallion = try service.findIngredient(named: "scallion")
        #expect(scallion != nil)
        #expect(scallion?.name == "spring onion")
    }

    @Test("findIngredient returns nil for unknown ingredient")
    @MainActor func findUnknown() throws {
        let (service, _container) = try makeServiceWithSeedData()
        let result = try service.findIngredient(named: "unicorn horn")
        #expect(result == nil)
    }

    // MARK: - Add / Delete

    @Test("addRecipe inserts a new recipe")
    @MainActor func addRecipe() throws {
        let (service, container) = try makeEmptyService()
        let recipe = Recipe(name: "New Recipe")
        service.addRecipe(recipe)

        let count = try container.mainContext.fetchCount(FetchDescriptor<Recipe>())
        #expect(count == 1)
    }

    @Test("deleteRecipe removes a recipe")
    @MainActor func deleteRecipe() throws {
        let (service, container) = try makeEmptyService()
        let recipe = Recipe(name: "To Delete")
        service.addRecipe(recipe)

        let beforeCount = try container.mainContext.fetchCount(FetchDescriptor<Recipe>())
        #expect(beforeCount == 1)

        service.deleteRecipe(recipe)

        let afterCount = try container.mainContext.fetchCount(FetchDescriptor<Recipe>())
        #expect(afterCount == 0)
    }

    @Test("addBook inserts a new book")
    @MainActor func addBook() throws {
        let (service, container) = try makeEmptyService()
        let book = Book(title: "New Book")
        service.addBook(book)

        let count = try container.mainContext.fetchCount(FetchDescriptor<Book>())
        #expect(count == 1)
    }
}
