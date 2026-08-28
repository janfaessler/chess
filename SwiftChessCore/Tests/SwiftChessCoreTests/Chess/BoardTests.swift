import Testing
@testable import SwiftChessCore

struct BoardTests {

    @Test func testGetReturnsFigureOnOccupiedSquare() throws {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let board = Board([rook])
        let piece = try #require(board.get(atRow: 1, atFile: 1))
        #expect(piece.equals(rook))
    }

    @Test func testIsEmptyAndIsNotEmpty() {
        let board = Board([PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)])
        #expect(!board.isEmpty(atRow: 1, atFile: 1))
        #expect(board.isNotEmpty(atRow: 1, atFile: 1))
        #expect(board.isEmpty(atRow: 4, atFile: 4))
        #expect(!board.isNotEmpty(atRow: 4, atFile: 4))
    }

    @Test func testGetNextPieceOnRowReturnsFirstBlocker() throws {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 1, file: 3)
        let board = Board([rook, blocker])
        let next = try #require(board.checkNextIntersection(rook.createMove(1, 5)!))
        #expect(next.equals(blocker))
    }

    @Test func testGetNextPieceOnFileReturnsFirstBlocker() throws {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 3, file: 1)
        let board = Board([rook, blocker])
        let next = try #require(board.checkNextIntersection(rook.createMove(5, 1)!))
        #expect(next.equals(blocker))
    }

    @Test func testGetNextPieceOnDiagonalReturnsFirstBlocker() throws {
        let bishop = PieceFactory.create(type: .bishop, color: .white, row: 1, file: 1)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 2, file: 2)
        let board = Board([bishop, blocker])
        let next = try #require(board.checkNextIntersection(bishop.createMove(4, 4)!))
        #expect(next.equals(blocker))
    }

    @Test func testGetNextPieceReturnsNilForClearRay() {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let board = Board([rook])
        #expect(board.checkNextIntersection(rook.createMove(1, 5)!) == nil)
    }

    @Test func testGetNextPieceFallbackReturnsPieceOnDestination() throws {
        let knight = PieceFactory.create(type: .knight, color: .white, row: 1, file: 1)
        let target = PieceFactory.create(type: .pawn, color: .black, row: 2, file: 3)
        let board = Board([knight, target])
        let next = try #require(board.checkNextIntersection(knight.createMove(2, 3)!))
        #expect(next.equals(target))
    }

    @Test func testCollisionYieldsEmptyGrid() {
        let a = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let b = PieceFactory.create(type: .queen, color: .black, row: 1, file: 1)
        let board = Board([a, b])
        #expect(board.figures.isEmpty)
        #expect(board.get(atRow: 1, atFile: 1) == nil)
    }
}
