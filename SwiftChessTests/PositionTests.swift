import XCTest
import SwiftChess

final class PositionTests: ChessTestBase {

    func testStartingPosition() throws {
        for color:PieceColor in [.white, .black] {
            let row = color == .white ? 1 : 8
            assertFigureExists(Figure.create("a\(row)", type: .rook, color: color)!)
            assertFigureExists(Figure.create("b\(row)", type: .knight, color: color)!)
            assertFigureExists(Figure.create("c\(row)", type: .bishop, color: color)!)
            assertFigureExists(Figure.create("d\(row)", type: .queen, color: color)!)
            assertFigureExists(Figure.create("e\(row)", type: .king, color: color)!)
            assertFigureExists(Figure.create("f\(row)", type: .bishop, color: color)!)
            assertFigureExists(Figure.create("g\(row)", type: .knight, color: color)!)
            assertFigureExists(Figure.create("h\(row)", type: .rook, color: color)!)

            let pawnRow = color == .white ? 2 : 7
            for file in 1...8 {
                assertFigureExists(Figure.create(type: .pawn, color: color, row:pawnRow, file: file))
            }
        }
    }

}
