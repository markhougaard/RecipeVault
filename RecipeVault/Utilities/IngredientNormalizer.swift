import Foundation

/// Extracts normalized ingredient names from raw ingredient strings and normalizes display spacing.
enum IngredientNormalizer {

    // MARK: - Public API

    /// Extracts the ingredient name from a full ingredient string.
    ///
    /// Examples:
    /// - `"2cl lemon juice"` → `"lemon juice"`
    /// - `"400g spaghetti"` → `"spaghetti"`
    /// - `"half a head of lettuce"` → `"lettuce"`
    /// - `"3 cloves garlic, minced"` → `"garlic"`
    static func normalize(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "" }

        // Strip preparation instructions after comma
        let beforeComma = trimmed.components(separatedBy: ",").first ?? trimmed

        // Tokenize
        let tokens = beforeComma.lowercased()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        // Skip leading quantity, unit, and connector tokens
        var startIndex = 0
        while startIndex < tokens.count {
            let token = tokens[startIndex]
            if isQuantity(token) || isUnit(token) || isConnector(token) {
                startIndex += 1
            } else {
                break
            }
        }

        let ingredientTokens = Array(tokens[startIndex...])
        guard !ingredientTokens.isEmpty else {
            // All tokens were quantities/units — return the whole thing lowercased
            return tokens.joined(separator: " ")
        }

        // Strip leading adjectives like "fresh", "dried" etc.
        var nameStart = 0
        while nameStart < ingredientTokens.count - 1 {
            if isAdjective(ingredientTokens[nameStart]) {
                nameStart += 1
            } else {
                break
            }
        }

        return Array(ingredientTokens[nameStart...]).joined(separator: " ")
    }

    /// Normalizes display spacing for metric units: `"400 g"` → `"400g"`, `"2 cl"` → `"2cl"`.
    ///
    /// Only collapses spacing for metric units (g, kg, mg, cl, ml, dl, l) to keep
    /// imperial units readable (e.g., "2 cups" stays as-is).
    static func normalizeDisplaySpacing(_ raw: String) -> String {
        var result = raw
        for unit in metricUnits {
            // Match: digit, whitespace, unit (followed by word boundary or end)
            let pattern = "(\\d)\\s+(\(NSRegularExpression.escapedPattern(for: unit)))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: "$1$2"
                )
            }
        }
        return result
    }

    // MARK: - Token Classification

    private static func isQuantity(_ token: String) -> Bool {
        // Pure numbers: "2", "400", "0.5"
        if Double(token) != nil { return true }
        // Fractions: "1/2", "3/4"
        if token.contains("/"), let parts = parseFraction(token), parts > 0 { return true }
        // Mixed numbers attached to units: "2cl", "400g" — extract the number part
        if startsWithDigitAndEndsWithUnit(token) { return true }
        // Word fractions
        if fractionWords.contains(token) { return true }
        return false
    }

    private static func isUnit(_ token: String) -> Bool {
        units.contains(token) || unitPlurals.contains(token)
    }

    private static func isConnector(_ token: String) -> Bool {
        connectors.contains(token)
    }

    private static func isAdjective(_ token: String) -> Bool {
        adjectives.contains(token)
    }

    private static func parseFraction(_ token: String) -> Double? {
        let parts = token.split(separator: "/")
        guard parts.count == 2,
              let num = Double(parts[0]),
              let den = Double(parts[1]),
              den != 0 else { return nil }
        return num / den
    }

    /// Detects tokens like "2cl", "400g" where a number is attached to a unit.
    private static func startsWithDigitAndEndsWithUnit(_ token: String) -> Bool {
        guard let first = token.first, first.isNumber else { return false }
        // Find where digits end
        let digitEnd = token.firstIndex(where: { !$0.isNumber && $0 != "." }) ?? token.endIndex
        let suffix = String(token[digitEnd...]).lowercased()
        return !suffix.isEmpty && (units.contains(suffix) || unitPlurals.contains(suffix))
    }

    // MARK: - Word Lists

    /// Metric units — used for both normalization and display spacing.
    private static let metricUnits: Set<String> = [
        "g", "kg", "mg", "cl", "ml", "dl", "l"
    ]

    /// All recognized units (metric + imperial + descriptive).
    private static let units: Set<String> = [
        // Metric
        "g", "kg", "mg", "cl", "ml", "dl", "l",
        // Imperial volume
        "cup", "tbsp", "tsp", "oz", "fl",
        // Imperial weight
        "lb",
        // Descriptive
        "head", "bunch", "clove", "piece", "pinch", "dash",
        "can", "slice", "sprig", "stalk", "stick", "sheet",
        "handful", "drop", "knob"
    ]

    /// Plural forms of units.
    private static let unitPlurals: Set<String> = [
        "cups", "lbs", "heads", "bunches", "cloves", "pieces",
        "pinches", "dashes", "cans", "slices", "sprigs",
        "stalks", "sticks", "sheets", "handfuls", "drops", "knobs"
    ]

    /// Words representing fractional quantities.
    private static let fractionWords: Set<String> = [
        "half", "quarter", "third"
    ]

    /// Connector words that appear between quantity/unit and ingredient name.
    private static let connectors: Set<String> = [
        "of", "a", "an", "the"
    ]

    /// Common adjectives that precede ingredient names and should be stripped.
    private static let adjectives: Set<String> = [
        "fresh", "dried", "frozen", "canned", "chopped", "diced",
        "sliced", "minced", "grated", "crushed", "whole", "large",
        "small", "medium", "fine", "coarse", "extra", "virgin",
        "organic", "raw", "cooked", "warm", "cold", "hot",
        "toasted", "roasted", "smoked"
    ]
}
