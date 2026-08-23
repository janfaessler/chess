import Foundation
import RegexBuilder

struct PgnHighlightArrowParser {
    nonisolated(unsafe) private static let cslRegex = /\[%csl ([^\]]+)\]/
    nonisolated(unsafe) private static let calRegex = /\[%cal ([^\]]+)\]/

    static func parseHighlights(_ comment: String) -> [SquareHighlight] {
        comment.matches(of: cslRegex).flatMap { match in
            String(match.1).split(separator: ",").compactMap { parseSquareHighlight(String($0)) }
        }
    }

    static func parseArrows(_ comment: String) -> [BoardArrow] {
        comment.matches(of: calRegex).flatMap { match in
            String(match.1).split(separator: ",").compactMap { parseBoardArrow(String($0)) }
        }
    }

    static func stripCommands(_ text: String) -> String? {
        var result = text
        result = result.replacing(cslRegex, with: "")
        result = result.replacing(calRegex, with: "")
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func parseSquareHighlight(_ token: String) -> SquareHighlight? {
        let t = token.trimmingCharacters(in: .whitespaces)
        guard t.count == 3,
              let colorChar = t.first,
              let color = AnnotationColor(rawValue: String(colorChar))
        else { return nil }
        return SquareHighlight(color: color, square: String(t.dropFirst()))
    }

    private static func parseBoardArrow(_ token: String) -> BoardArrow? {
        let t = token.trimmingCharacters(in: .whitespaces)
        guard t.count == 5,
              let colorChar = t.first,
              let color = AnnotationColor(rawValue: String(colorChar))
        else { return nil }
        let from = String(t.dropFirst().prefix(2))
        let to = String(t.dropFirst(3))
        return BoardArrow(color: color, from: from, to: to)
    }
}
