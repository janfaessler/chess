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
        guard let type = PieceType(fenChar: fenChar),
              let piece = PromotionPiece.allCases.first(where: { $0.pieceType == type }) else { return nil }
        self = piece
    }
}
