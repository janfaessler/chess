import Testing
@testable import SwiftChessCore

struct PathCheckerTests {

    private func makeChecker(_ figures: [any ChessPiece]) -> PathChecker {
        PathChecker(Board(figures))
    }

    @Test func testRow_blockerBeforeTarget_returnsBlocker() throws {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 1, file: 3)
        let result = try #require(makeChecker([rook, blocker]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 1, file: 5)!))
        #expect(result.equals(blocker))
    }

    @Test func testRow_backwardDirection_blockerBeforeTarget_returnsBlocker() throws {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 8)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 1, file: 5)
        let result = try #require(makeChecker([rook, blocker]).firstPieceOnPath(from: Square(row: 1, file: 8)!, to: Square(row: 1, file: 1)!))
        #expect(result.equals(blocker))
    }

    @Test func testRow_clearPath_returnsNil() {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        #expect(makeChecker([rook]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 1, file: 5)!) == nil)
    }

    @Test func testFile_blockerBeforeTarget_returnsBlocker() throws {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 3, file: 1)
        let result = try #require(makeChecker([rook, blocker]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 5, file: 1)!))
        #expect(result.equals(blocker))
    }

    @Test func testFile_clearPath_returnsNil() {
        let rook = PieceFactory.create(type: .rook, color: .white, row: 1, file: 1)
        #expect(makeChecker([rook]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 5, file: 1)!) == nil)
    }

    @Test func testDiagonal_blockerBeforeTarget_returnsBlocker() throws {
        let bishop = PieceFactory.create(type: .bishop, color: .white, row: 1, file: 1)
        let blocker = PieceFactory.create(type: .pawn, color: .black, row: 2, file: 2)
        let result = try #require(makeChecker([bishop, blocker]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 4, file: 4)!))
        #expect(result.equals(blocker))
    }

    @Test func testDiagonal_oneStep_returnsTargetPiece() throws {
        let bishop = PieceFactory.create(type: .bishop, color: .white, row: 1, file: 1)
        let target = PieceFactory.create(type: .pawn, color: .black, row: 2, file: 2)
        let result = try #require(makeChecker([bishop, target]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 2, file: 2)!))
        #expect(result.equals(target))
    }

    @Test func testNonSliding_occupiedTarget_returnsTargetPiece() throws {
        let knight = PieceFactory.create(type: .knight, color: .white, row: 1, file: 1)
        let target = PieceFactory.create(type: .pawn, color: .black, row: 2, file: 3)
        let result = try #require(makeChecker([knight, target]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 2, file: 3)!))
        #expect(result.equals(target))
    }

    @Test func testNonSliding_emptyTarget_returnsNil() {
        let knight = PieceFactory.create(type: .knight, color: .white, row: 1, file: 1)
        #expect(makeChecker([knight]).firstPieceOnPath(from: Square(row: 1, file: 1)!, to: Square(row: 2, file: 3)!) == nil)
    }
}
