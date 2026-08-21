import Testing
@testable import SwiftChessCore

struct EnPassantRulesTests {

    @Test func testTarget_whiteDoublePush_isSquareBehindPawn() throws {
        let pawn = Figure.create("e2", type: .pawn, color: .white)!
        let move = try #require(Move("e4", piece: pawn, type: .Double))
        #expect(EnPassantRules.target(afterMove: move) == Field(row: 3, file: 5))
    }

    @Test func testTarget_blackDoublePush_isSquareBehindPawn() throws {
        let pawn = Figure.create("d7", type: .pawn, color: .black)!
        let move = try #require(Move("d5", piece: pawn, type: .Double))
        #expect(EnPassantRules.target(afterMove: move) == Field(row: 6, file: 4))
    }

    @Test func testTarget_nonDoublePush_isNil() throws {
        let pawn = Figure.create("e3", type: .pawn, color: .white)!
        let move = try #require(Move("e4", piece: pawn, type: .Normal))
        #expect(EnPassantRules.target(afterMove: move) == nil)
    }

    @Test func testCanEnPassant_onTargetSquare_isTrue() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try #require(position.get(atRow: 5, atFile: 5))
        let move = try #require(Move("d6", piece: pawn, type: .Normal))
        #expect(EnPassantRules.canEnPassant(move, position: position))
    }

    @Test func testCanEnPassant_withoutTarget_isFalse() throws {
        let position = PositionFactory.startingPosition()
        let pawn = try #require(position.get(atRow: 2, atFile: 5))
        let move = try #require(Move("e4", piece: pawn, type: .Double))
        #expect(!EnPassantRules.canEnPassant(move, position: position))
    }

    @Test func testIsEnPassant_captureToEmptyTarget_isTrue() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try #require(position.get(atRow: 5, atFile: 5))
        let move = try #require(Move("d6", piece: pawn, type: .Normal))
        #expect(EnPassantRules.isEnPassant(move, position: position))
    }

    @Test func testIsEnPassant_ordinaryCapture_isFalse() throws {
        let position = try #require(PositionFactory.loadPosition(["e4", "d5"]))
        let pawn = try #require(position.get(atRow: 4, atFile: 5))
        let move = try #require(Move("d5", piece: pawn, type: .Normal))
        #expect(!EnPassantRules.isEnPassant(move, position: position))
    }

    @Test func testCapturedPawnField_isOnOriginRowAndDestinationFile() throws {
        let pawn = Figure.create("e5", type: .pawn, color: .white)!
        let move = try #require(Move("d6", piece: pawn, type: .Normal))
        #expect(EnPassantRules.capturedPawnField(for: move) == Field(row: 5, file: 4))
    }
}
