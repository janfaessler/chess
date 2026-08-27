import Foundation

public enum PieceType : Sendable {
    case pawn, bishop, knight, rook, queen, king
}

extension PieceType {

    public init?(fenChar: Character) {
        switch fenChar.uppercased() {
        case "P": self = .pawn
        case "N": self = .knight
        case "B": self = .bishop
        case "R": self = .rook
        case "Q": self = .queen
        case "K": self = .king
        default: return nil
        }
    }

    public var char: Character {
        switch self {
        case .pawn:   return "P"
        case .knight: return "N"
        case .bishop: return "B"
        case .rook:   return "R"
        case .queen:  return "Q"
        case .king:   return "K"
        }
    }

    public func fenChar(for color: PieceColor) -> Character {
        color == .white ? char : Character(char.lowercased())
    }

}
