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

    public func fenChar(for color: PieceColor) -> Character {
        let upper: Character
        switch self {
        case .pawn: upper = "P"
        case .knight: upper = "N"
        case .bishop: upper = "B"
        case .rook: upper = "R"
        case .queen: upper = "Q"
        case .king: upper = "K"
        }
        return color == .white ? upper : Character(upper.lowercased())
    }

}
