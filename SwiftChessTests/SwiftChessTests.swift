//
//  SwiftChessTests.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 06.03.2024.
//
import XCTest
import SwiftChess

final class SwiftChessTests: XCTestCase {
    
    private var testee:ChessBoard?

    override func setUpWithError() throws {
        testee = ChessBoard(Fen.loadStartingPosition())
    }

    func testStartingPosition() throws {
        let testee = try XCTUnwrap(testee)
        let figures = testee.getFigures()
        
        for color:PieceColor in [.white, .black] {
            let row = color == .white ? 1 : 8
            XCTAssert(figures.contains([Rook(color: color, row: row, file: 1)]))
            XCTAssert(figures.contains([Knight(color: color, row: row, file: 2)]))
            XCTAssert(figures.contains([Bishop(color: color, row: row, file: 3)]))
            XCTAssert(figures.contains([Queen(color: color, row: row, file: 4)]))
            XCTAssert(figures.contains([King(color: color, row: row, file: 5)]))
            XCTAssert(figures.contains([Bishop(color: color, row: row, file: 6)]))
            XCTAssert(figures.contains([Knight(color: color, row: row, file: 7)]))
            XCTAssert(figures.contains([Rook(color: color, row: row, file: 8)]))
            
            let pawnRow = color == .white ? 2 : 7
            for file in 1...8 {
                XCTAssert(figures.contains([Pawn(color: color, row: pawnRow, file: file)]))
            }
        }
    }
    
    func testSimplePawnCapture() throws {
        let testee = try XCTUnwrap(testee)
                
        testee.move(Move(4, 5, piece:Pawn(color: .white, row: 2, file: 5),type: .Double))
        assertFigureExists(Pawn(color: .white, row: 4, file: 5))
        XCTAssertEqual(testee.getFigures().count, 32)

        testee.move(Move(5, 4, piece:Pawn(color: .black, row: 7, file: 4),type: .Double))
        assertFigureExists(Pawn(color: .black, row: 5, file: 4))
        XCTAssertEqual(testee.getFigures().count, 32)
        
        testee.move(Move(5, 4, piece:Pawn(color: .white, row: 4, file: 5),type: .Normal))
        assertFigureExists(Pawn(color: .white, row: 5, file: 4))
        assertFigureNotExists(Pawn(color: .black, row: 5, file: 4))
        XCTAssertEqual(testee.getFigures().count, 31)
    }

    func assertFigureExists(
        _ f: Figure,
        message: (Figure) -> String = { "\($0.getColor()) \($0.getType()) at \($0.getRow()):\($0.getFile()) does not exist" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard figureExist(f) == false else { return }
        XCTFail(message(f), file: file, line: line)
    }
    
    func assertFigureNotExists(
        _ f: Figure,
        message: (Figure) -> String = { "\($0.getColor()) \($0.getType()) at \($0.getRow()):\($0.getFile()) does not exist" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard figureExist(f) == true else { return }
        XCTFail(message(f), file: file, line: line)
    }
    
    private func figureExist(_ figure: Figure) -> Bool {
        do {
            let testee = try XCTUnwrap(testee)
            return testee.getFigures().contains(where: { f in f == figure })
        } catch { return false }
    }
}
