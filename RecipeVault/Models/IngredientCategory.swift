import Foundation

/// Category classification for an ingredient.
enum IngredientCategory: String, Codable, Sendable {
    case protein
    case vegetable
    case fruit
    case dairy
    case grain
    case pantryStaple
    case herb
    case spice
    case condiment
    case other
}
