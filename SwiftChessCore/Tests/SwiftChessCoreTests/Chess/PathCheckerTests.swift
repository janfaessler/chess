import Testing
@testable import SwiftChessCore

struct PathCheckerTests {

    private func makeChecker(_ figures: [any ChessFigure]) -> PathChecker {
        PathChecker(Board(figures))
    }

    // MARK: - Row

    @Test func testRow_blockerBeforeTarget_returnsBlocker() throws {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = Figure.create(type: .pawn, color: .black, row: 1, file: 3)
        let result = try #require(makeChecker([rook, blocker]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 1, file: 5)))
        #expect(result.equals(blocker))
    }

    @Test func testRow_backwardDirection_blockerBeforeTarget_returnsBlocker() throws {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 8)
        let blocker = Figure.create(type: .pawn, color: .black, row: 1, file: 5)
        let result = try #require(makeChecker([rook, blocker]).firstPieceOnPath(from: Field(row: 1, file: 8), to: Field(row: 1, file: 1)))
        #expect(result.equals(blocker))
    }

    @Test func testRow_clearPath_returnsNil() {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        #expect(makeChecker([rook]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 1, file: 5)) == nil)
    }

    // MARK: - File

    @Test func testFile_blockerBeforeTarget_returnsBlocker() throws {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        let blocker = Figure.create(type: .pawn, color: .black, row: 3, file: 1)
        let result = try #require(makeChecker([rook, blocker]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 5, file: 1)))
        #expect(result.equals(blocker))
    }

    @Test func testFile_clearPath_returnsNil() {
        let rook = Figure.create(type: .rook, color: .white, row: 1, file: 1)
        #expect(makeChecker([rook]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 5, file: 1)) == nil)
    }

    // MARK: - Diagonal

    @Test func testDiagonal_blockerBeforeTarget_returnsBlocker() throws {
        let bishop = Figure.create(type: .bishop, color: .white, row: 1, file: 1)
        let blocker = Figure.create(type: .pawn, color: .black, row: 2, file: 2)
        let result = try #require(makeChecker([bishop, blocker]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 4, file: 4)))
        #expect(result.equals(blocker))
    }

    @Test func testDiagonal_oneStep_returnsTargetPiece() throws {
        let bishop = Figure.create(type: .bishop, color: .white, row: 1, file: 1)
        let target = Figure.create(type: .pawn, color: .black, row: 2, file: 2)
        let result = try #require(makeChecker([bishop, target]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 2, file: 2)))
        #expect(result.equals(target))
    }

    // MARK: - Non-sliding (knight)

    @Test func testNonSliding_occupiedTarget_returnsTargetPiece() throws {
        let knight = Figure.create(type: .knight, color: .white, row: 1, file: 1)
        let target = Figure.create(type: .pawn, color: .black, row: 2, file: 3)
        let result = try #require(makeChecker([knight, target]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 2, file: 3)))
        #expect(result.equals(target))
    }

    @Test func testNonSliding_emptyTarget_returnsNil() {
        let knight = Figure.create(type: .knight, color: .white, row: 1, file: 1)
        #expect(makeChecker([knight]).firstPieceOnPath(from: Field(row: 1, file: 1), to: Field(row: 2, file: 3)) == nil)
    }
}
