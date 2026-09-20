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

    private static let zobristPieceCount = 12
    private static let zobristSquareCount = size * size
    private static let zobristCastlingCount = 4
    private static let zobristEnPassantFileCount = size

    private static let zobristValues: [UInt64] = {
        var rng = SplitMix64(seed: 0x9E3779B97F4A7C15)
        let total = zobristSquareCount * zobristPieceCount + 1 + zobristCastlingCount + zobristEnPassantFileCount
        return (0..<total).map { _ in rng.next() }
    }()

    static let zobristPieces: [[UInt64]] = (0..<zobristSquareCount).map { square in
        let base = square * zobristPieceCount
        return Array(zobristValues[base..<(base + zobristPieceCount)])
    }

    static let zobristBlackToMove: UInt64 = zobristValues[zobristSquareCount * zobristPieceCount]

    static let zobristCastling: [UInt64] = {
        let base = zobristSquareCount * zobristPieceCount + 1
        return Array(zobristValues[base..<(base + zobristCastlingCount)])
    }()

    static let zobristEnPassant: [UInt64] = {
        let base = zobristSquareCount * zobristPieceCount + 1 + zobristCastlingCount
        return Array(zobristValues[base..<(base + zobristEnPassantFileCount)])
    }()

    static func zobristValue(square: Int, type: PieceType, color: PieceColor) -> UInt64 {
        zobristPieces[square][type.zobristTypeIndex * 2 + (color == .black ? 1 : 0)]
    }
}

private struct SplitMix64 {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
