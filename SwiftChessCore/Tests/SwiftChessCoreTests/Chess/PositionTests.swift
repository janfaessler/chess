import Testing
@testable import SwiftChessCore

final class PositionTests: ChessTestBase {

    @Test func testStartingPosition() throws {
        for color: PieceColor in [.white, .black] {
            let row = color == .white ? 1 : 8
            assertFigureExists(Piece.create("a\(row)", type: .rook, color: color)!)
            assertFigureExists(Piece.create("b\(row)", type: .knight, color: color)!)
            assertFigureExists(Piece.create("c\(row)", type: .bishop, color: color)!)
            assertFigureExists(Piece.create("d\(row)", type: .queen, color: color)!)
            assertFigureExists(Piece.create("e\(row)", type: .king, color: color)!)
            assertFigureExists(Piece.create("f\(row)", type: .bishop, color: color)!)
            assertFigureExists(Piece.create("g\(row)", type: .knight, color: color)!)
            assertFigureExists(Piece.create("h\(row)", type: .rook, color: color)!)

            let pawnRow = color == .white ? 2 : 7
            for file in 1...8 {
                assertFigureExists(Piece.create(type: .pawn, color: color, row: pawnRow, file: file))
            }
        }
    }

    @Test func testFenCreation() throws {
        let startPosition = FenBuilder.create(PositionFactory.startingPosition())
        #expect(startPosition == PositionFactory.startingPositionFen)
    }
}
