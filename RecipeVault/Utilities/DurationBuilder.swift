import Foundation

/// Builds ISO 8601 duration strings from hours and minutes.
///
/// This is the inverse of `DurationFormatter.formatted()` which parses ISO 8601 → display string.
enum DurationBuilder {
    /// Builds an ISO 8601 duration string from hours and minutes.
    ///
    /// - Returns: A string like `"PT1H30M"`, or `nil` if both values are zero.
    static func iso8601(hours: Int, minutes: Int) -> String? {
        guard hours > 0 || minutes > 0 else { return nil }
        var result = "PT"
        if hours > 0 { result += "\(hours)H" }
        if minutes > 0 { result += "\(minutes)M" }
        return result
    }
}
