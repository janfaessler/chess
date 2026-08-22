import Foundation

public enum MoveAnnotation: String, Codable, Hashable, Sendable {
    case brilliant = "!!"
    case good = "!"
    case interesting = "!?"
    case dubious = "?!"
    case mistake = "?"
    case blunder = "??"

    public var symbol: String { rawValue }

    static func fromNAG(_ nag: String) -> MoveAnnotation? {
        switch nag {
        case "1": return .good
        case "2": return .mistake
        case "3": return .brilliant
        case "4": return .blunder
        case "5": return .interesting
        case "6": return .dubious
        default: return nil
        }
    }

    static func fromSymbol(_ symbol: String) -> MoveAnnotation? {
        MoveAnnotation(rawValue: symbol)
    }
}
