import Foundation
import SwiftData

/// A known ingredient with optional category and aliases for normalization.
@Model
final class Ingredient: @unchecked Sendable {
    var id: UUID
    var name: String
    var categoryRawValue: String?
    var aliasesJSON: String
    var createdAt: Date
    var updatedAt: Date

    init(
        name: String,
        category: IngredientCategory? = nil,
        aliases: [String] = []
    ) {
        self.id = UUID()
        self.name = name.lowercased().trimmingCharacters(in: .whitespaces)
        self.categoryRawValue = category?.rawValue
        self.aliasesJSON = (try? String(data: JSONEncoder().encode(aliases), encoding: .utf8)) ?? "[]"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Computed Accessors

extension Ingredient {
    /// Ergonomic access to the category as a Swift enum.
    var category: IngredientCategory? {
        get {
            guard let categoryRawValue else { return nil }
            return IngredientCategory(rawValue: categoryRawValue)
        }
        set { categoryRawValue = newValue?.rawValue }
    }

    /// Alternative names for this ingredient used during normalization.
    var aliases: [String] {
        get {
            guard let data = aliasesJSON.data(using: .utf8) else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            aliasesJSON = (try? String(data: JSONEncoder().encode(newValue), encoding: .utf8)) ?? "[]"
        }
    }
}
