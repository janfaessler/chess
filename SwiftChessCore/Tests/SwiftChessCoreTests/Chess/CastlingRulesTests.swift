import Testing
@testable import SwiftChessCore

final class CastlingRulesTests: ChessTestBase {

    @Test func testWhiteKingside_cleanPath_succeeds() throws {
        loadFen("4k3/8/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssert(notation: "O-O", toField: "g1", type: .king, color: .white, moveType: .castle)
    }

    @Test func testWhiteQueenside_cleanPath_succeeds() throws {
        loadFen("4k3/8/8/8/8/8/8/R3K3 w Q - 0 1")
        try moveAndAssert(notation: "O-O-O", toField: "c1", type: .king, color: .white, moveType: .castle)
    }

    @Test func testBlackKingside_cleanPath_succeeds() throws {
        loadFen("4k2r/8/8/8/8/8/8/4K3 b k - 0 1")
        try moveAndAssert(notation: "O-O", toField: "g8", type: .king, color: .black, moveType: .castle)
    }

    @Test func testBlackQueenside_cleanPath_succeeds() throws {
        loadFen("r3k3/8/8/8/8/8/8/4K3 b q - 0 1")
        try moveAndAssert(notation: "O-O-O", toField: "c8", type: .king, color: .black, moveType: .castle)
    }

    @Test func testCastlingBlocked_kingPassesThroughAttackedSquare() throws {
        loadFen("4k3/5r2/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssertError("O-O")
    }

    @Test func testCastlingBlocked_kingInCheck() throws {
        loadFen("4k3/4r3/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssertError("O-O")
    }

    @Test func testCastlingBlocked_destinationSquareAttacked() throws {
        loadFen("4k3/6r1/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssertError("O-O")
    }

    @Test func testCastlingBlocked_kingHasMovedPreviously() throws {
        loadFen("4k3/8/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssert(from: "e1", to: "d1", type: .king, color: .white)
        try moveAndAssert(from: "e8", to: "d8", type: .king, color: .black)
        try moveAndAssert(from: "d1", to: "e1", type: .king, color: .white)
        try moveAndAssert(from: "d8", to: "e8", type: .king, color: .black)
        try moveAndAssertError("O-O")
    }

    @Test func testCastlingBlocked_kingsideRookHasMoved() throws {
        loadFen("4k3/8/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssert(from: "h1", to: "g1", type: .rook, color: .white)
        try moveAndAssert(from: "e8", to: "d8", type: .king, color: .black)
        try moveAndAssert(from: "g1", to: "h1", type: .rook, color: .white)
        try moveAndAssert(from: "d8", to: "e8", type: .king, color: .black)
        try moveAndAssertError("O-O")
    }

    @Test func testCastlingBlocked_queensideRookHasMoved() throws {
        loadFen("4k3/8/8/8/8/8/8/R3K3 w Q - 0 1")
        try moveAndAssert(from: "a1", to: "b1", type: .rook, color: .white)
        try moveAndAssert(from: "e8", to: "d8", type: .king, color: .black)
        try moveAndAssert(from: "b1", to: "a1", type: .rook, color: .white)
        try moveAndAssert(from: "d8", to: "e8", type: .king, color: .black)
        try moveAndAssertError("O-O-O")
    }

    @Test func testCastlingBlocked_kingsideRookCaptured() throws {
        loadFen("4k3/8/8/8/8/6n1/8/4K2R b K - 0 1")
        try captureAndAssert("g3", to: "h1", type: .knight, color: .black)
        try moveAndAssertError("O-O")
    }

    @Test func testCastlingBlocked_piecesBetweenKingAndRook() throws {
        loadFen("4k3/8/8/8/8/8/8/4KN1R w K - 0 1")
        try moveAndAssertError("O-O")
    }

    @Test func testAfterKingsideCastling_rookOccupiesF1() throws {
        loadFen("4k3/8/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssert(notation: "O-O", toField: "g1", type: .king, color: .white, moveType: .castle)
        let testee = try #require(testee)
        let rook = testee.figures.first { $0.type == .rook && $0.color == .white }
        #expect(rook?.file == 6, "white rook should be on f1 (file 6) after O-O")
        #expect(rook?.row == 1)
    }

    @Test func testAfterCastling_enPassantTargetIsNil() throws {
        loadFen("4k3/8/8/8/8/8/8/4K2R w K - 0 1")
        try moveAndAssert(notation: "O-O", toField: "g1", type: .king, color: .white, moveType: .castle)
        let testee = try #require(testee)
        #expect(testee.position.enPassantTarget == nil, "en passant target should be nil after castling")
    }
}
