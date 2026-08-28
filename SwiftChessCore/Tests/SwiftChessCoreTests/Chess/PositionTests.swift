import Testing
@testable import SwiftChessCore

final class PositionTests: ChessTestBase {

    @Test func testStartingPosition() throws {
        for color: PieceColor in [.white, .black] {
            let row = color == .white ? 1 : 8
            assertFigureExists(PieceFactory.create("a\(row)", type: .rook, color: color)!)
            assertFigureExists(PieceFactory.create("b\(row)", type: .knight, color: color)!)
            assertFigureExists(PieceFactory.create("c\(row)", type: .bishop, color: color)!)
            assertFigureExists(PieceFactory.create("d\(row)", type: .queen, color: color)!)
            assertFigureExists(PieceFactory.create("e\(row)", type: .king, color: color)!)
            assertFigureExists(PieceFactory.create("f\(row)", type: .bishop, color: color)!)
            assertFigureExists(PieceFactory.create("g\(row)", type: .knight, color: color)!)
            assertFigureExists(PieceFactory.create("h\(row)", type: .rook, color: color)!)

            let pawnRow = color == .white ? 2 : 7
            for file in 1...8 {
                assertFigureExists(PieceFactory.create(type: .pawn, color: color, row: pawnRow, file: file))
            }
        }
    }

    @Test func testFenCreation() throws {
        let startPosition = FenBuilder.create(try PositionFactory.startingPosition())
        #expect(startPosition == PositionFactory.startingPositionFen)
    }
}
