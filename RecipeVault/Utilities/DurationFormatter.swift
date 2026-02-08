import Foundation

/// Formats ISO 8601 duration strings (e.g. "PT1H30M") into readable text.
enum DurationFormatter {
    /// Converts an ISO 8601 duration string to a human-readable string.
    /// Returns nil if the input is nil or unparseable.
    static func formatted(_ iso8601: String?) -> String? {
        guard let iso8601, iso8601.hasPrefix("PT") else { return nil }

        let timeString = String(iso8601.dropFirst(2))
        var hours = 0
        var minutes = 0
        var current = ""

        for char in timeString {
            switch char {
            case "H":
                hours = Int(current) ?? 0
                current = ""
            case "M":
                minutes = Int(current) ?? 0
                current = ""
            case "S":
                current = ""
            default:
                current.append(char)
            }
        }

        var parts: [String] = []
        if hours > 0 {
            parts.append("\(hours) hr\(hours > 1 ? "s" : "")")
        }
        if minutes > 0 {
            parts.append("\(minutes) min")
        }

        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
