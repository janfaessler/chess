import Foundation

public enum BoardConstants {
    public static let size = 8
    public static let halfmoveClockLimit = 100
    public static let threefoldRepetitionCount = 3

    public static let pawnStartingRowWhite = 2
    public static let pawnStartingRowBlack = 7

    public static let kingCastleQueensideFile = 3
    public static let kingCastleKingsideFile = 7

    public static let rookCastleQueensideStartFile = 1
    public static let rookCastleQueensideEndFile = 4
    public static let rookCastleKingsideStartFile = 8
    public static let rookCastleKingsideEndFile = 6

    public static let promotionRankWhite = 8
    public static let promotionRankBlack = 1
    public static let rankBeforePromotionWhite = 7
    public static let rankBeforePromotionBlack = 2
}
