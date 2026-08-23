import Foundation

public enum MoveAnnotation: String, Codable, Hashable, Sendable, CaseIterable {
    case brilliant = "!!"
    case good = "!"
    case interesting = "!?"
    case dubious = "?!"
    case mistake = "?"
    case blunder = "??"

    public var symbol: String { rawValue }

    public var displayName: String {
        switch self {
        case .brilliant: return "Brilliant"
        case .good: return "Good"
        case .interesting: return "Interesting"
        case .dubious: return "Dubious"
        case .mistake: return "Mistake"
        case .blunder: return "Blunder"
        }
    }

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
