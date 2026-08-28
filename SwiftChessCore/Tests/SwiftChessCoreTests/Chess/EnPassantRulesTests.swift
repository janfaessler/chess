import Testing
@testable import SwiftChessCore

struct EnPassantRulesTests {

    @Test func testTarget_whiteDoublePush_isSquareBehindPawn() throws {
        let pawn = PieceFactory.create("e2", type: .pawn, color: .white)!
        let move = try #require(pawn.createMove("e4", type: .double, promoteTo: .queen))
        #expect(EnPassantRules.target(afterMove: move) == Square(row: 3, file: 5))
    }

    @Test func testTarget_blackDoublePush_isSquareBehindPawn() throws {
        let pawn = PieceFactory.create("d7", type: .pawn, color: .black)!
        let move = try #require(pawn.createMove("d5", type: .double, promoteTo: .queen))
        #expect(EnPassantRules.target(afterMove: move) == Square(row: 6, file: 4))
    }

    @Test func testTarget_nonDoublePush_isNil() throws {
        let pawn = PieceFactory.create("e3", type: .pawn, color: .white)!
        let move = try #require(pawn.createMove("e4", type: .normal, promoteTo: .queen))
        #expect(EnPassantRules.target(afterMove: move) == nil)
    }

    @Test func testCanEnPassant_onTargetSquare_isTrue() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try #require(position.get(atRow: 5, atFile: 5))
        let move = try #require(pawn.createMove("d6", type: .normal, promoteTo: .queen))
        #expect(EnPassantRules.canEnPassant(move, board: position))
    }

    @Test func testCanEnPassant_withoutTarget_isFalse() throws {
        let position = try PositionFactory.startingPosition()
        let pawn = try #require(position.get(atRow: 2, atFile: 5))
        let move = try #require(pawn.createMove("e4", type: .double, promoteTo: .queen))
        #expect(!EnPassantRules.canEnPassant(move, board: position))
    }

    @Test func testIsEnPassant_captureToEmptyTarget_isTrue() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try #require(position.get(atRow: 5, atFile: 5))
        let move = try #require(pawn.createMove("d6", type: .normal, promoteTo: .queen))
        #expect(EnPassantRules.isEnPassant(move, board: position))
    }

    @Test func testIsEnPassant_ordinaryCapture_isFalse() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "d5"]))
        let pawn = try #require(position.get(atRow: 4, atFile: 5))
        let move = try #require(pawn.createMove("d5", type: .normal, promoteTo: .queen))
        #expect(!EnPassantRules.isEnPassant(move, board: position))
    }

    @Test func testCapturedPawnField_isOnOriginRowAndDestinationFile() throws {
        let pawn = PieceFactory.create("e5", type: .pawn, color: .white)!
        let move = try #require(pawn.createMove("d6", type: .normal, promoteTo: .queen))
        #expect(EnPassantRules.capturedPawnSquare(for: move) == Square(row: 5, file: 4))
    }

    @Test func testEnPassantTarget_expiredAfterOpponentPlaysElsewhere() throws {
        let pos = try #require(PositionFactory.loadPosition(["e4", "d5", "e5", "d4", "a3"]))
        #expect(pos.enPassantTarget == nil, "en passant target must expire once white plays a non-capturing move")
    }

    @Test func testEnPassantTarget_presentImmediatelyAfterDoublePush() throws {
        let pos = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        #expect(pos.enPassantTarget == Square(row: 6, file: 4), "en passant target d6 must be set immediately after black double-push d7→d5")
    }
}
