import Foundation

enum PieceType {
    case pawn, bishop, knight, rook, queen, king
}

extension PieceType {

    init?(fenChar: Character) {
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

    func fenChar(for color: PieceColor) -> Character {
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

    var sanIdent: String {
        switch self {
        case .pawn: return ""
        case .knight: return "N"
        case .bishop: return "B"
        case .rook: return "R"
        case .queen: return "Q"
        case .king: return "K"
        }
    }
}
