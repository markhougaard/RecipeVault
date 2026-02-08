import Foundation
import SwiftData

/// A cookbook or recipe book that can contain multiple recipes.
@Model
final class Book: @unchecked Sendable {
    var id: UUID
    var title: String
    var author: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Recipe.book)
    var recipes: [Recipe]

    init(
        title: String,
        author: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.createdAt = Date()
        self.updatedAt = Date()
        self.recipes = []
    }
}
