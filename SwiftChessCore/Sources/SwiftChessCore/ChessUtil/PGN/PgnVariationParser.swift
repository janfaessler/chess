import Foundation

struct PgnVariationParser {
    static func extractVariations(_ input: String) -> [String] {
        var variations: [String] = []
        var current: String = ""
        var depth = 0
        var inComment = false
        for char in input {
            if char == "{" {
                if depth > 0 { current.append(char) }
                inComment = true
            } else if char == "}" {
                if depth > 0 { current.append(char) }
                inComment = false
            } else if inComment {
                if depth > 0 { current.append(char) }
            } else if char == "(" {
                if depth > 0 { current.append(char) }
                depth += 1
            } else if char == ")" {
                depth -= 1
                if depth > 0 { current.append(char) }
                if depth == 0 {
                    variations.append(current.trimmingCharacters(in: [" "]))
                    current = ""
                }
            } else if depth > 0 {
                current.append(char)
            }
        }
        return variations
    }
}
