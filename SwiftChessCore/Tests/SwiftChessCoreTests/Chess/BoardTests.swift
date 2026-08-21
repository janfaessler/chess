import XCTest
@testable import SwiftChessCore

final class BoardTests: XCTestCase {

    func testGetReturnsFigureOnOccupiedSquare() throws {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let board = Board([rook])

        let piece = try XCTUnwrap(board.get(atRow: 1, atFile: 1))
        XCTAssertTrue(piece.equals(rook))
    }

    func testIsEmptyAndIsNotEmpty() {
        let board = Board([Figure.create(type: .rook, color: .white, row: 1, file: 1)])

        XCTAssertFalse(board.isEmpty(atRow: 1, atFile: 1))
        XCTAssertTrue(board.isNotEmpty(atRow: 1, atFile: 1))
        XCTAssertTrue(board.isEmpty(atRow: 4, atFile: 4))
        XCTAssertFalse(board.isNotEmpty(atRow: 4, atFile: 4))
    }

    func testGetNextPieceOnRowReturnsFirstBlocker() throws {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = Figure.create(type: .pawn, color: .black, row: 1, file: 3)
        let board = Board([rook, blocker])

        let next = try XCTUnwrap(board.checkNextIntersection(Move(1, 5, piece: rook)))
        XCTAssertTrue(next.equals(blocker))
    }

    func testGetNextPieceOnFileReturnsFirstBlocker() throws {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = Figure.create(type: .pawn, color: .black, row: 3, file: 1)
        let board = Board([rook, blocker])

        let next = try XCTUnwrap(board.checkNextIntersection(Move(5, 1, piece: rook)))
        XCTAssertTrue(next.equals(blocker))
    }

    func testGetNextPieceOnDiagonalReturnsFirstBlocker() throws {
        let bishop = Figure.create(type: .bishop, color: .white, row: 1, file: 1)
        let blocker = Figure.create(type: .pawn, color: .black, row: 2, file: 2)
        let board = Board([bishop, blocker])

        let next = try XCTUnwrap(board.checkNextIntersection(Move(4, 4, piece: bishop)))
        XCTAssertTrue(next.equals(blocker))
    }

    func testGetNextPieceReturnsNilForClearRay() {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let board = Board([rook])

        XCTAssertNil(board.checkNextIntersection(Move(1, 5, piece: rook)))
    }

    func testGetNextPieceFallbackReturnsPieceOnDestination() throws {
        let knight = Figure.create(type: .knight, color: .white, row: 1, file: 1)
        let target = Figure.create(type: .pawn, color: .black, row: 2, file: 3)
        let board = Board([knight, target])

        let next = try XCTUnwrap(board.checkNextIntersection(Move(2, 3, piece: knight)))
        XCTAssertTrue(next.equals(target))
    }

    func testCollisionYieldsEmptyGrid() {
        let a = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let b = Figure.create(type: .queen, color: .black, row: 1, file: 1)
        let board = Board([a, b])

        XCTAssertTrue(board.figures.isEmpty)
        XCTAssertNil(board.get(atRow: 1, atFile: 1))
    }
}
