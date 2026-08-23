import Foundation

public struct CastlingRights: Equatable, Hashable, Sendable {
    public let whiteKingside: Bool
    public let whiteQueenside: Bool
    public let blackKingside: Bool
    public let blackQueenside: Bool

    public static let all  = CastlingRights(whiteKingside: true,  whiteQueenside: true,  blackKingside: true,  blackQueenside: true)
    public static let none = CastlingRights(whiteKingside: false, whiteQueenside: false, blackKingside: false, blackQueenside: false)

    public var isEmpty: Bool {
        !whiteKingside && !whiteQueenside && !blackKingside && !blackQueenside
    }

    public func canCastle(kingside: Bool, for color: PieceColor) -> Bool {
        switch (color, kingside) {
        case (.white, true):  return whiteKingside
        case (.white, false): return whiteQueenside
        case (.black, true):  return blackKingside
        case (.black, false): return blackQueenside
        }
    }

    public func revoking(kingside: Bool, for color: PieceColor) -> CastlingRights {
        switch (color, kingside) {
        case (.white, true):
            return CastlingRights(whiteKingside: false, whiteQueenside: whiteQueenside, blackKingside: blackKingside, blackQueenside: blackQueenside)
        case (.white, false):
            return CastlingRights(whiteKingside: whiteKingside, whiteQueenside: false, blackKingside: blackKingside, blackQueenside: blackQueenside)
        case (.black, true):
            return CastlingRights(whiteKingside: whiteKingside, whiteQueenside: whiteQueenside, blackKingside: false, blackQueenside: blackQueenside)
        case (.black, false):
            return CastlingRights(whiteKingside: whiteKingside, whiteQueenside: whiteQueenside, blackKingside: blackKingside, blackQueenside: false)
        }
    }

    public func revoking(for color: PieceColor) -> CastlingRights {
        switch color {
        case .white: return CastlingRights(whiteKingside: false, whiteQueenside: false, blackKingside: blackKingside, blackQueenside: blackQueenside)
        case .black: return CastlingRights(whiteKingside: whiteKingside, whiteQueenside: whiteQueenside, blackKingside: false, blackQueenside: false)
        }
    }
}
