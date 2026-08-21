import XCTest
@testable import SwiftChessCore

final class EnPassantRulesTests: XCTestCase {

    func testTarget_whiteDoublePush_isSquareBehindPawn() throws {
        let pawn = Figure.create("e2", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e4", piece: pawn, type: .Double))
        XCTAssertEqual(EnPassantRules.target(afterMove: move), Field(row: 3, file: 5))
    }

    func testTarget_blackDoublePush_isSquareBehindPawn() throws {
        let pawn = Figure.create("d7", type: .pawn, color: .black)!
        let move = try XCTUnwrap(Move("d5", piece: pawn, type: .Double))
        XCTAssertEqual(EnPassantRules.target(afterMove: move), Field(row: 6, file: 4))
    }

    func testTarget_nonDoublePush_isNil() throws {
        let pawn = Figure.create("e3", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("e4", piece: pawn, type: .Normal))
        XCTAssertNil(EnPassantRules.target(afterMove: move))
    }

    func testCanEnPassant_onTargetSquare_isTrue() throws {
        let position = try XCTUnwrap(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try XCTUnwrap(position.get(atRow: 5, atFile: 5))
        let move = try XCTUnwrap(Move("d6", piece: pawn, type: .Normal))
        XCTAssertTrue(EnPassantRules.canEnPassant(move, position: position))
    }

    func testCanEnPassant_withoutTarget_isFalse() throws {
        let position = PositionFactory.startingPosition()
        let pawn = try XCTUnwrap(position.get(atRow: 2, atFile: 5))
        let move = try XCTUnwrap(Move("e4", piece: pawn, type: .Double))
        XCTAssertFalse(EnPassantRules.canEnPassant(move, position: position))
    }

    func testIsEnPassant_captureToEmptyTarget_isTrue() throws {
        let position = try XCTUnwrap(PositionFactory.loadPosition(["e4", "a6", "e5", "d5"]))
        let pawn = try XCTUnwrap(position.get(atRow: 5, atFile: 5))
        let move = try XCTUnwrap(Move("d6", piece: pawn, type: .Normal))
        XCTAssertTrue(EnPassantRules.isEnPassant(move, position: position))
    }

    func testIsEnPassant_ordinaryCapture_isFalse() throws {
        let position = try XCTUnwrap(PositionFactory.loadPosition(["e4", "d5"]))
        let pawn = try XCTUnwrap(position.get(atRow: 4, atFile: 5))
        let move = try XCTUnwrap(Move("d5", piece: pawn, type: .Normal))
        XCTAssertFalse(EnPassantRules.isEnPassant(move, position: position))
    }

    func testCapturedPawnField_isOnOriginRowAndDestinationFile() throws {
        let pawn = Figure.create("e5", type: .pawn, color: .white)!
        let move = try XCTUnwrap(Move("d6", piece: pawn, type: .Normal))
        XCTAssertEqual(EnPassantRules.capturedPawnField(for: move), Field(row: 5, file: 4))
    }
}
