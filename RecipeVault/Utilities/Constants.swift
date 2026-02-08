import Foundation

/// App-wide constants.
enum Constants {
    /// Minimum ingredient match ratio (0.0–1.0) to show a recipe in results.
    static let minimumMatchThreshold: Double = 0.3

    /// The CloudKit container identifier.
    static let cloudKitContainerID = "iCloud.com.recipevault.app"
}
