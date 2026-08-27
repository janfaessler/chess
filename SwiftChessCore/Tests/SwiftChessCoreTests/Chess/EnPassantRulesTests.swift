import Testing
@testable import SwiftChessCore

struct EnPassantRulesTests {

    @Test func testTarget_whiteDoublePush_isSquareBehindPawn() throws {
        let pawn = Piece.create("e2", type: .pawn, color: .white)!
        let move = try #require(Move("e4", piece: pawn, type: .double))
        #expect(EnPassantRules.target(afterMove: move) == Square(row: 3, file: 5))
    }

    @Test func testTarget_blackDoublePush_isSquareBehindPawn() throws {
        let pawn = Piece.create("d7", type: .pawn, color: .black)!
        let move = try #require(Move("d5", piece: pawn, type: .double))
        #expect(EnPassantRules.target(afterMove: move) == Square(row: 6, file: 4))
    }

    @Test func testTarget_nonDoublePush_isNil() throws {
        let pawn = Piece.create("e3", type: .pawn, color: .white)!
        let move = try #require(Move("e4", piece: pawn, type: .normal))
        #expect(EnPassantRules.target(afterMove: move) == nil)
    }

    @Test func testCanEnPassant_onTargetSquare_isTrue() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try #require(position.get(atRow: 5, atFile: 5))
        let move = try #require(Move("d6", piece: pawn, type: .normal))
        #expect(EnPassantRules.canEnPassant(move, board: position))
    }

    @Test func testCanEnPassant_withoutTarget_isFalse() throws {
        let position = try PositionFactory.startingPosition()
        let pawn = try #require(position.get(atRow: 2, atFile: 5))
        let move = try #require(Move("e4", piece: pawn, type: .double))
        #expect(!EnPassantRules.canEnPassant(move, board: position))
    }

    @Test func testIsEnPassant_captureToEmptyTarget_isTrue() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try #require(position.get(atRow: 5, atFile: 5))
        let move = try #require(Move("d6", piece: pawn, type: .normal))
        #expect(EnPassantRules.isEnPassant(move, board: position))
    }

    @Test func testIsEnPassant_ordinaryCapture_isFalse() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "d5"]))
        let pawn = try #require(position.get(atRow: 4, atFile: 5))
        let move = try #require(Move("d5", piece: pawn, type: .normal))
        #expect(!EnPassantRules.isEnPassant(move, board: position))
    }

    @Test func testCapturedPawnField_isOnOriginRowAndDestinationFile() throws {
        let pawn = Piece.create("e5", type: .pawn, color: .white)!
        let move = try #require(Move("d6", piece: pawn, type: .normal))
        #expect(EnPassantRules.capturedPawnSquare(for: move) == Square(row: 5, file: 4))
    }

    @Test func testEnPassantTarget_expiredAfterOpponentPlaysElsewhere() throws {
        // After white plays a3 instead of capturing en passant, the target disappears
        let pos = try #require(PositionFactory.loadPosition(["e4", "d5", "e5", "d4", "a3"]))
        #expect(pos.enPassantTarget == nil, "en passant target must expire once white plays a non-capturing move")
    }

    @Test func testEnPassantTarget_presentImmediatelyAfterDoublePush() throws {
        // After black double-pushes d7→d5 with white pawn already on e5, en passant target d6 is set
        let pos = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        #expect(pos.enPassantTarget == Square(row: 6, file: 4), "en passant target d6 must be set immediately after black double-push d7→d5")
    }
}
