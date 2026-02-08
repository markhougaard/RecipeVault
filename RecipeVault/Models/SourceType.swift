import Foundation

/// The origin type for a recipe — how it was added to the collection.
enum SourceType: String, Codable, Sendable {
    case book
    case url
    case manual
}
