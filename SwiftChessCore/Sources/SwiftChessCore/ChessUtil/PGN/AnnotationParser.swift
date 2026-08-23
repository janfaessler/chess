import Foundation

struct AnnotationParser {
    static func parse(_ token: String) -> MoveAnnotation? {
        if let match = token.firstMatch(of: PgnRegex.numericAnnotation) {
            let nag = String(match.output).filter(\.isNumber)
            return MoveAnnotation.fromNAG(nag)
        }
        if let match = token.firstMatch(of: PgnRegex.annotation) {
            return MoveAnnotation.fromSymbol(String(match.output))
        }
        return nil
    }

    static func strip(_ move: String) -> String {
        move.replacing(PgnRegex.annotation, with: "")
            .replacing(PgnRegex.numericAnnotation, with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}
