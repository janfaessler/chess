import Foundation

struct PromotionRules {

    static func rankBeforePromotion(for color: PieceColor) -> Int {
        color == .white ? 7 : 2
    }

    static func promotionRank(for color: PieceColor) -> Int {
        color == .white ? 8 : 1
    }

    static func isOnRankBeforePromotion(_ figure: any ChessFigure) -> Bool {
        figure.type == .pawn && figure.row == rankBeforePromotion(for: figure.color)
    }

    static func isPromotion(_ move: Move) -> Bool {
        move.piece.type == .pawn && move.row == promotionRank(for: move.piece.color)
    }

    static func isPawnBeingPromoted(_ figure: any ChessFigure, by move: Move) -> Bool {
        figure.type == .pawn && figure.color == move.piece.color && figure.row == move.row && figure.file == move.file
    }
}
