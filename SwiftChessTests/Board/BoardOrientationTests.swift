import Testing
import SwiftUI
@testable import SwiftChess
import SwiftChessCore

struct BoardOrientationTests {
    
    @Test func visualFile_notFlipped_returnsFile() {
        let o = BoardOrientation(isFlipped: false)
        #expect(o.visualFile(1) == 1)
        #expect(o.visualFile(5) == 5)
        #expect(o.visualFile(8) == 8)
    }

    @Test func visualFile_flipped_mirrorsAroundCenter() {
        let o = BoardOrientation(isFlipped: true)
        #expect(o.visualFile(1) == 8)
        #expect(o.visualFile(5) == 4)
        #expect(o.visualFile(8) == 1)
    }

    @Test func visualRow_notFlipped_invertsRow() {
        let o = BoardOrientation(isFlipped: false)
        #expect(o.visualRow(1) == 8)
        #expect(o.visualRow(5) == 4)
        #expect(o.visualRow(8) == 1)
    }

    @Test func visualRow_flipped_returnsRow() {
        let o = BoardOrientation(isFlipped: true)
        #expect(o.visualRow(1) == 1)
        #expect(o.visualRow(5) == 5)
        #expect(o.visualRow(8) == 8)
    }

    @Test func deltaMultipliers_notFlipped() {
        let o = BoardOrientation(isFlipped: false)
        #expect(o.deltaRowMultiplier == -1)
        #expect(o.deltaFileMultiplier == 1)
    }

    @Test func deltaMultipliers_flipped() {
        let o = BoardOrientation(isFlipped: true)
        #expect(o.deltaRowMultiplier == 1)
        #expect(o.deltaFileMultiplier == -1)
    }

    @Test func logicalRow_notFlipped_convertsScreenY() {
        let o = BoardOrientation(isFlipped: false)
        #expect(o.logicalRow(y: 0, fieldSize: 60) == 9)   // top of board → rank 8 (clamped: Int(9-0)=9)
        #expect(o.logicalRow(y: 60, fieldSize: 60) == 8)  // one field down → rank 8 exactly
        #expect(o.logicalRow(y: 420, fieldSize: 60) == 2) // near bottom → rank 2
    }

    @Test func logicalRow_flipped_convertsScreenY() {
        let o = BoardOrientation(isFlipped: true)
        #expect(o.logicalRow(y: 0, fieldSize: 60) == 1)   // top of board → rank 1
        #expect(o.logicalRow(y: 60, fieldSize: 60) == 2)  // one field down → rank 2
        #expect(o.logicalRow(y: 420, fieldSize: 60) == 8) // near bottom → rank 8
    }

    @Test func toggleOrientation_flipsIsFlipped() {
        let board = BoardModel()
        #expect(board.orientation.isFlipped == false)
        board.toggleOrientation()
        #expect(board.orientation.isFlipped == true)
        board.toggleOrientation()
        #expect(board.orientation.isFlipped == false)
    }

    @Test func calculateDeltaRow_notFlipped_negatesHeight() {
        let board = BoardModel()
        let figure = board.figures[0]
        #expect(figure.calculateDeltaRow(100, fieldSize: 50) == -2)
    }

    @Test func calculateDeltaRow_flipped_keepsSign() {
        let board = BoardModel()
        board.toggleOrientation()
        let figure = board.figures[0]
        #expect(figure.calculateDeltaRow(100, fieldSize: 50) == 2)
    }

    @Test func calculateDeltaFile_notFlipped_keepsSign() {
        let board = BoardModel()
        let figure = board.figures[0]
        #expect(figure.calculateDeltaFile(100, fieldSize: 50) == 2)
    }

    @Test func calculateDeltaFile_flipped_negatesWidth() {
        let board = BoardModel()
        board.toggleOrientation()
        let figure = board.figures[0]
        #expect(figure.calculateDeltaFile(100, fieldSize: 50) == -2)
    }

    @Test func getOffsetX_notFlipped_usesFileDirectly() throws {
        let board = BoardModel()
        let king = try #require(board.figures.first(where: { $0.type == .king && $0.color == .white }))
        let fieldSize: CGFloat = 60
        // White King starts at e1 → file=5, visualFile=5, offset = 60*(5-1) = 240
        #expect(king.getOffsetX(fieldSize: fieldSize) == 240)
    }

    @Test func getOffsetX_flipped_mirrorsFile() throws {
        let board = BoardModel()
        board.toggleOrientation()
        let king = try #require(board.figures.first(where: { $0.type == .king && $0.color == .white }))
        let fieldSize: CGFloat = 60
        // file=5, flipped → visualFile=9-5=4, offset = 60*(4-1) = 180
        #expect(king.getOffsetX(fieldSize: fieldSize) == 180)
    }

    @Test func getOffsetY_notFlipped_invertsRow() throws {
        let board = BoardModel()
        let king = try #require(board.figures.first(where: { $0.type == .king && $0.color == .white }))
        let fieldSize: CGFloat = 60
        // White King at row=1, visualRow=9-1=8, offset = 60*(8-1) = 420
        #expect(king.getOffsetY(fieldSize: fieldSize) == 420)
    }

    @Test func getOffsetY_flipped_usesRowDirectly() throws {
        let board = BoardModel()
        board.toggleOrientation()
        let king = try #require(board.figures.first(where: { $0.type == .king && $0.color == .white }))
        let fieldSize: CGFloat = 60
        // row=1, flipped → visualRow=1, offset = 60*(1-1) = 0
        #expect(king.getOffsetY(fieldSize: fieldSize) == 0)
    }
}
