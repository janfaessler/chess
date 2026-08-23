import Foundation

public enum PromotionPiece: CaseIterable, Hashable, Sendable {
    case queen, rook, bishop, knight

    public var pieceType: PieceType {
        switch self {
        case .queen:  return .queen
        case .rook:   return .rook
        case .bishop: return .bishop
        case .knight: return .knight
        }
    }

    public init?(fenChar: Character) {
        switch fenChar.uppercased() {
        case "Q": self = .queen
        case "R": self = .rook
        case "B": self = .bishop
        case "N": self = .knight
        default: return nil
        }
    }
}
