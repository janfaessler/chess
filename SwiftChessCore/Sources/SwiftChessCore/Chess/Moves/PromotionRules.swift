import Foundation

struct PromotionRules {

    static func rankBeforePromotion(for color: PieceColor) -> Int {
        color == .white ? BoardConstants.rankBeforePromotionWhite : BoardConstants.rankBeforePromotionBlack
    }

    static func promotionRank(for color: PieceColor) -> Int {
        color == .white ? BoardConstants.promotionRankWhite : BoardConstants.promotionRankBlack
    }

    static func isOnRankBeforePromotion(_ figure: any ChessPiece) -> Bool {
        figure.type == .pawn && figure.row == rankBeforePromotion(for: figure.color)
    }

    static func isPromotion(_ move: Move) -> Bool {
        move.piece.type == .pawn && move.row == promotionRank(for: move.piece.color)
    }

    static func isPawnBeingPromoted(_ figure: any ChessPiece, by move: Move) -> Bool {
        figure.type == .pawn && figure.color == move.piece.color && figure.row == move.row && figure.file == move.file
    }
}
