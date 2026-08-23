import Testing
@testable import SwiftChessCore

struct BoardTests {

    @Test func testGetReturnsFigureOnOccupiedSquare() throws {
        let rook = Piece.create(type: .rook, color: .white, row: 1, file: 1)
        let board = Board([rook])
        let piece = try #require(board.get(atRow: 1, atFile: 1))
        #expect(piece.equals(rook))
    }

    @Test func testIsEmptyAndIsNotEmpty() {
        let board = Board([Piece.create(type: .rook, color: .white, row: 1, file: 1)])
        #expect(!board.isEmpty(atRow: 1, atFile: 1))
        #expect(board.isNotEmpty(atRow: 1, atFile: 1))
        #expect(board.isEmpty(atRow: 4, atFile: 4))
        #expect(!board.isNotEmpty(atRow: 4, atFile: 4))
    }

    @Test func testGetNextPieceOnRowReturnsFirstBlocker() throws {
        let rook = Piece.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = Piece.create(type: .pawn, color: .black, row: 1, file: 3)
        let board = Board([rook, blocker])
        let next = try #require(board.checkNextIntersection(Move(1, 5, piece: rook)))
        #expect(next.equals(blocker))
    }

    @Test func testGetNextPieceOnFileReturnsFirstBlocker() throws {
        let rook = Piece.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = Piece.create(type: .pawn, color: .black, row: 3, file: 1)
        let board = Board([rook, blocker])
        let next = try #require(board.checkNextIntersection(Move(5, 1, piece: rook)))
        #expect(next.equals(blocker))
    }

    @Test func testGetNextPieceOnDiagonalReturnsFirstBlocker() throws {
        let bishop = Piece.create(type: .bishop, color: .white, row: 1, file: 1)
        let blocker = Piece.create(type: .pawn, color: .black, row: 2, file: 2)
        let board = Board([bishop, blocker])
        let next = try #require(board.checkNextIntersection(Move(4, 4, piece: bishop)))
        #expect(next.equals(blocker))
    }

    @Test func testGetNextPieceReturnsNilForClearRay() {
        let rook = Piece.create(type: .rook, color: .white, row: 1, file: 1)
        let board = Board([rook])
        #expect(board.checkNextIntersection(Move(1, 5, piece: rook)) == nil)
    }

    @Test func testGetNextPieceFallbackReturnsPieceOnDestination() throws {
        let knight = Piece.create(type: .knight, color: .white, row: 1, file: 1)
        let target = Piece.create(type: .pawn, color: .black, row: 2, file: 3)
        let board = Board([knight, target])
        let next = try #require(board.checkNextIntersection(Move(2, 3, piece: knight)))
        #expect(next.equals(target))
    }

    @Test func testCollisionYieldsEmptyGrid() {
        let a = Piece.create(type: .rook, color: .white, row: 1, file: 1)
        let b = Piece.create(type: .queen, color: .black, row: 1, file: 1)
        let board = Board([a, b])
        #expect(board.figures.isEmpty)
        #expect(board.get(atRow: 1, atFile: 1) == nil)
    }
}
