import Foundation
import SwiftData

/// A recipe aligned with the schema.org/Recipe standard.
@Model
final class Recipe: @unchecked Sendable {
    var id: UUID
    var name: String
    var recipeDescription: String?
    var recipeIngredientJSON: String
    var normalizedIngredientsJSON: String
    var recipeInstructionsJSON: String
    var recipeCategory: String?
    var recipeCuisine: String?
    var recipeYield: String?
    var prepTime: String?
    var cookTime: String?
    var totalTime: String?
    var keywordsJSON: String
    var author: String?
    var datePublished: Date?
    @Attribute(.externalStorage) var imageData: Data?
    var sourceType: String
    var sourceURL: String?
    var sourcePageNumber: Int?
    var notes: String?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    var book: Book?

    init(
        name: String,
        recipeDescription: String? = nil,
        recipeIngredient: [String] = [],
        normalizedIngredients: [String] = [],
        recipeInstructions: [String] = [],
        recipeCategory: String? = nil,
        recipeCuisine: String? = nil,
        recipeYield: String? = nil,
        prepTime: String? = nil,
        cookTime: String? = nil,
        totalTime: String? = nil,
        keywords: [String] = [],
        author: String? = nil,
        datePublished: Date? = nil,
        imageData: Data? = nil,
        sourceType: SourceType = .manual,
        sourceURL: String? = nil,
        sourcePageNumber: Int? = nil,
        notes: String? = nil,
        isFavorite: Bool = false,
        book: Book? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.recipeDescription = recipeDescription
        self.recipeIngredientJSON = Recipe.encode(recipeIngredient)
        self.normalizedIngredientsJSON = Recipe.encode(normalizedIngredients)
        self.recipeInstructionsJSON = Recipe.encode(recipeInstructions)
        self.recipeCategory = recipeCategory
        self.recipeCuisine = recipeCuisine
        self.recipeYield = recipeYield
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.totalTime = totalTime
        self.keywordsJSON = Recipe.encode(keywords)
        self.author = author
        self.datePublished = datePublished
        self.imageData = imageData
        self.sourceType = sourceType.rawValue
        self.sourceURL = sourceURL
        self.sourcePageNumber = sourcePageNumber
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
        self.book = book
    }
}

// MARK: - Computed Array Accessors

extension Recipe {
    /// The list of ingredients as displayed in the recipe (e.g. "400g spaghetti").
    var recipeIngredient: [String] {
        get { Recipe.decode(recipeIngredientJSON) }
        set { recipeIngredientJSON = Recipe.encode(newValue) }
    }

    /// Normalized ingredient names for matching (e.g. "spaghetti").
    var normalizedIngredients: [String] {
        get { Recipe.decode(normalizedIngredientsJSON) }
        set { normalizedIngredientsJSON = Recipe.encode(newValue) }
    }

    /// Step-by-step cooking instructions.
    var recipeInstructions: [String] {
        get { Recipe.decode(recipeInstructionsJSON) }
        set { recipeInstructionsJSON = Recipe.encode(newValue) }
    }

    /// Searchable keywords/tags for this recipe.
    var keywords: [String] {
        get { Recipe.decode(keywordsJSON) }
        set { keywordsJSON = Recipe.encode(newValue) }
    }

    /// Ergonomic access to the source type as a Swift enum.
    var source: SourceType {
        get { SourceType(rawValue: sourceType) ?? .manual }
        set { sourceType = newValue.rawValue }
    }
}

// MARK: - JSON Helpers

extension Recipe {
    static func encode(_ array: [String]) -> String {
        (try? String(data: JSONEncoder().encode(array), encoding: .utf8)) ?? "[]"
    }

    static func decode(_ json: String) -> [String] {
        guard let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
